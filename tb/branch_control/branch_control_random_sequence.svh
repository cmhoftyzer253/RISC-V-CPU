class branch_control_random_sequence extends uvm_sequence #(branch_control_command_transaction);
    `uvm_object_utils(branch_control_random_sequence)

    int unsigned num_tests = 1000;

    function new(string name "branch_control_random_sequence");
        super.new(name);
    endfunction : new

    task body();
        branch_control_command_transaction cmd;

        repeat (num_tests) begin
            cmd = branch_control_command_transaction::type_id::create("cmd");
            start_item(cmd);
            assert(cmd.randomize());
            finish_item(cmd);
        end
    endtask : body

endclass : branch_control_random_sequence