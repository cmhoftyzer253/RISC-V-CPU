set repo_root       [file normalize [file join [file dirname [info script]] ..]]
cd $repo_root

set proj_name       riscv_cpu
set proj_xpr        [file join $repo_root build vivado $proj_name.xpr]
set project_tcl     [file join $repo_root scripts project.tcl]
set report_dir      [file join $repo_root build reports]

proc default_jobs {} {
    if {[info exists ::env(NUMBER_OF_PROCESSORS)]} {
        return $::env(NUMBER_OF_PROCESSORS)
    }
    if {![catch {exec nproc} n] && [string is integer -strict $n]} {
        return $n
    }
    return 4
}

# -----------------------------------------------------------------------------
# Arguments
# -----------------------------------------------------------------------------
set build_to            bit
set build_jobs          [default_jobs]
set allow_timing_fail   0
set skip_uptodate       0

if {[info exists argv]} {
    set remaining $argv
    while {[llength $remaining] > 0} {
        set remaining [lassign $remaining opt]
        switch -- $opt {
            -to {
                set remaining [lassign $remaining build_to]
                if {$build_to ni {synth impl bit}} {
                    error "build.tcl: -to must be synth, impl, or bit (got '$build_to')"
                }
            }
            -jobs {
                set remaining [lassign $remaining build_jobs]
                if {![string is integer -strict $build_jobs] || $build_jobs < 1} {
                    error "build.tcl: -jobs needs a positive integer"
                }
            }
            -allow_timing_fail  { set allow_timing_fail 1 } 
            -skip_uptodate      { set skip_uptodate 1 }
            default             { error "build.tcl: unknown option '$opt'" }
        }
    }
}

puts "build.tcl: stage=$build_to jobs=$build_jobs skip_uptodate=$skip_uptodate allow_timing_fail=$allow_timing_fail"

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------
proc elapsed {t0} {
    set s [expr {[clock seconds] - $t0}]
    return [format %d:%02d [expr {$s / 60}] [expr {$s % 60}]]
}

proc print_log_errors {log} {
    if {![file exists $log]} {
        return
    }
    set fh [open $log r]
    set errs [regexp -all -inline -line {^(?:ERROR|CRITICAL WARNING):.*$} [read $fh]]
    close $fh
    if {[llength $errs] == 0} {
        return
    }
    puts "---- errors from $log ----"
    foreach e $errs {
        puts $e
    }
    puts "--------------------------"
}

proc check_run {run} {
    set r           [get_runs $run]
    set status      [get_property STATUS $r]
    set progress    [get_property PROGRESS $r]
    puts "build.tcl: $run -> $status ($progress)"

    if {$progress eq "100%" && ![regexp -nocase {error} $status]} {
        return
    }

    set log [file join [get_property DIRECTORY $r] runme.log]
    print_log_errors $log

    foreach other [get_runs -quiet -filter {IS_SYNTHESIS}] {
        if {$other ne $run && [regexp -nocase {error|fail} [get_property STATUS $other]]} {
            set other_log [file join [get_property DIRECTORY $other] runme.log]
            puts "build.tcl: run $other failed: $other_log"
            print_log_errors $other_log
        }
    }
    error "build.tcl: $run did not complete ($status). See $log"
}

set flow_steps {
    synth_design
    init_design opt_design power_opt_design place_design
    post_place_power_opt_design phys_opt_design route_design
    post_route_phys_opt_design write_bitstream
}

proc step_index {step} {
    return [lsearch -exact $::flow_steps $step]
}

proc target_step {r to_step} {
    if {[get_property IS_SYNTHESIS $r]} {
        return synth_design
    }
    if {$to_step ne ""} {
        return $to_step
    }
    if {[get_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED $r]} {
        return post_route_phys_opt_design
    }
    return route_design
}

proc completed_step {r} {
    if {[get_property NEEDS_REFRESH $r]} {
        return -1
    } 
    set status [get_property STATUS $r]
    if {[regexp -nocase {error} $status]} {
        return -1
    }
    if {![regexp {^(\w+) Complete} $status -> step]} {
        return -1
    }
    return [step_index $step]
}

proc run_stage {run jobs skip_uptodate {to_step ""}} {
    set r       [get_runs $run]
    set target  [target_step $r $to_step]
    set done    [expr {$skip_uptodate ? [completed_step $r] : -1}]
    
    if {$done >= 0 && $done >= [step_index $target]} {
        puts "build.tcl: $run already complete through $target, skipping"
        return
    } elseif {$done >= 0} {
        puts "build.tcl: $run complete through [lindex $::flow_steps $done], continuing to $target"
    } else { 
        reset_run $run
    }

    if {$to_step ne ""} {
        launch_runs $run -to_step $to_step -jobs $jobs
    } else { 
        launch_runs $run -jobs $jobs
    }
    wait_on_run $run
    check_run $run
}

proc util_summary {} {
    set rpt [report_utilization -return_string]
    foreach row {{Slice LUTs} {Slice Registers} {Block RAM Tile} {DSPs}} {
        if {[regexp -line "^\\|\\s*${row}\\*?\\s*\\|.*\$" $rpt line]} {
            set cols {} 
            foreach c [split [string trim $line " |"] |] {
                lappend cols [string trim $c]
            }
            puts [format "    %-16s %7s / %-7s (%s%%)" \
                [string trimright [lindex $cols 0] *] [lindex $cols 1] \
                [lindex $cols end-1] [lindex $cols end]]
        }
    }
}

proc write_reports {stage dir} {
    file mkdir $dir
    report_utilization          -file [file join $dir ${stage}_utilization.rpt]
    report_utilization          -hierarchical -hierarchical_depth 4 \
                                -file [file join $dir ${stage}_utilization_hier.rpt]
    report_timing_summary       -max_paths 20 -report_unconstrained -warn_on_violation \
                                -file [file join $dir ${stage}_timing_summary.rpt]
    report_clock_interaction    -file [file join $dir ${stage}_clock_interaction.rpt]
    report_cdc                  -details -file [file join $dir ${stage}_cdc.rpt]
    report_methodology          -file [file join $dir ${stage}_methodology.rpt]
    report_drc                  -file [file join $dir ${stage}_drc.rpt]
    if {$stage eq "impl"} {
        report_power            -file [file join $dir ${stage}_power.rpt]
        report_io               -file [file join $dir ${stage}_io.rpt]
        report_route_status     -file [file join $dir ${stage}_route_status.rpt]
    }
}

proc worst_slack {} {
    set setup [get_timing_paths -quiet -delay_type max -max_paths 1 -nworst 1]
    set hold [get_timing_paths -quiet -delay_type min -max_paths 1 -nworst 1]
    set wns [expr {[llength $setup] ? [get_property SLACK $setup] : ""}]
    set whs [expr {[llength $hold] ? [get_property SLACK $hold] : ""}]
    return [list $wns $whs]
}

proc timing_met {} {
    set ts [report_timing_summary -no_detailed_paths -return_string]
    return [string match "*All user specified timing constraints are met*" $ts]
}

proc check_timing_issues {} {
    set ts [report_timing_summary -no_detailed_paths -return_string]
    set issues {} 
    foreach {- name n} [regexp -all -inline {checking (\w+) \((\d+)\)} $ts] {
        if {$n > 0} { lappend issues "$name=$n" }
    }
    return $issues
}

# -----------------------------------------------------------------------------
# Open/Create project
# -----------------------------------------------------------------------------
if {[llength [get_projects -quiet]] == 0} {
    if {[file exists $proj_xpr]} {
        open_project $proj_xpr
    } else { 
        puts "build.tcl: $proj_xpr not found - running project.tcl"
        source $project_tcl
    }
} elseif {[get_property NAME [current_project]] ne $proj_name} {
    error "build.tcl: project '[get_property NAME [current_project]]' is open, expected '$proj_name'"
}

set actual_dir [file normalize [get_property DIRECTORY [current_project]]]
set expected_dir [file normalize [file dirname $proj_xpr]]
if {$tcl_platform(platform) eq "windows"} { 
    set same_dir [string equal $actual_dir $expected_dir]
}
if {!$same_dir} {
    error "build.tcl: open_project is at '$actual_dir', expected 'expected_dir'. Close it (close_project) and re-run."
}

update_compile_order -fileset sources_1
foreach d [get_designs -quiet] {
    current_design $d
    close_design
}

set impl_strategy Performance_ExplorePostRoutePhysOpt 
set impl_run [get_runs impl_1]
if {[get_property STRATEGY $impl_run] ne $impl_strategy} {
    puts "build.tcl: setting impl_1 strategy to $impl_strategy"
    set_property STRATEGY $impl_strategy $impl_run
}

set t_start [clock seconds]

# -----------------------------------------------------------------------------
# Synthesis 
# -----------------------------------------------------------------------------
run_stage synth_1 $build_jobs $skip_uptodate

if {$build_to eq "synth"} {
    open_run synth_1 -name synth_1
    write_reports synth $report_dir
    puts "build.tcl: synthesis utilization"
    util_summary
    lassign [worst_slack] wns whs
    puts "build.tcl: estimated WNS: $wns ns (pre-placement)"
    puts "build.tcl: done in [elapsed $t_start]. Reports in $report_dir"
    return 
}

# -----------------------------------------------------------------------------
# Implementation
# -----------------------------------------------------------------------------
if {$build_to eq "bit"} {
    run_stage impl_1 $build_jobs $skip_uptodate write_bitstream
} else { 
    run_stage impl_1 $build_jobs $skip_uptodate
}

open_run impl_1 -name impl_1
write_reports impl $report_dir

# -----------------------------------------------------------------------------
# Check Timing
# -----------------------------------------------------------------------------
lassign [worst_slack] wns whs
set timing_ok [expr {$wns ne "" && $whs ne "" && $wns >= 0 && $whs >= 0 && [timing_met]}]

set issues [check_timing_issues]

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
puts ""
puts "==================== build summary ===================="
puts "  stage   : $build_to"
puts "  time    : [elapsed $t_start]"
puts "  wns     : $wns ns"
puts "  whs     : $whs ns"
puts "  timing  : [expr {$timing_ok ? "met" : "NOT_MET"}]"
puts "  checks  : [expr {[llength $issues] ? [join $issues] : "clean"}]"
puts "  util    : "
util_summary
puts "  reports : $report_dir"
if {$build_to eq "bit"} {
    set bit [lindex [glob -nocomplain -directory [get_property DIRECTORY [get_runs impl_1]] *.bit] 0]
    puts "  bitfile : $bit[expr {$timing_ok ? "" : "    (timing failed - don't program)"}]"
}
puts "======================================================="

if {!$timing_ok} {
    set msg "build.tcl: timing not met (WNS=$wns WHS=$whs) - see impl_timing_summary.rpt"
    if {$allow_timing_fail} {
        puts "WARNING: $msg"
    } else { 
        error $msg
    }
}