class alu_env extends uvm_env;
    `uvm_component_utils(alu_env)

    alu_coverage            alu_coverage_h;
    alu_scoreboard          alu_scoreboard_h;
    alu_agent               alu_agent_h;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        alu_agent_h             =   alu_agent::type_id::create("alu_agent_h", this);
        alu_coverage_h          =   alu_coverage::type_id::create("alu_coverage_h", this);
        alu_scoreboard_h        =   alu_scoreboard::type_id::create("alu_scoreboard_h", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        alu_agent_h.instr_mon_ap.connect(alu_coverage_h.analysis_export);
        alu_agent_h.instr_mon_ap.connect(alu_scoreboard_h.instr_fifo.analysis_export);
        alu_agent_h.result_ap.connect(alu_scoreboard_h.analysis_export);
    endfunction : connect_phase

endclass : alu_env