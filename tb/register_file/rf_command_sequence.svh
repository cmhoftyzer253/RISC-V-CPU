class rf_command_sequence extends uvm_sequence #(rf_command_transaction);
    `uvm_object_utils(rf_command_sequence)

    int unsigned num_tests = 1000;

    function new(string name = "rf_command_sequence");
        super.new(name);
    endfunction : new

    task body();
        rf_command_transaction cmd;

        repeat (num_tests) begin
            cmd = rf_command_transaction::type_id::create("cmd");
            start_item(cmd);
            if (!cmd.randomize())
                `uvm_fatal("COMMAND_SEQUENCE", "randomize failed")
            finish_item(cmd);
        end
    endtask : body

endclass : rf_command_sequence