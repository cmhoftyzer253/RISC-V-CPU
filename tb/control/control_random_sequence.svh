class control_random_sequence extends uvm_sequence #(control_command_transaction);
    `uvm_object_utils(control_random_sequence)

    int unsigned num_tests = 1000;

    function new(string name = "control_random_sequence");
        super.new(name);
    endfunction : new

    task body();
        control_command_transaction cmd;

        repeat (num_tests) begin
            cmd = control_command_transaction::type_id::create("cmd");
            start_item(cmd);
            assert(cmd.randomize())
            finish_item(cmd);
        end
    endtask : body

endclass : control_random_sequence