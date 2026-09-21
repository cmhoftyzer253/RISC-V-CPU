class divide_command_sequence extends uvm_sequence #(divide_command_transaction);
    `uvm_object_utils(divide_command_sequence)

    int unsigned num_tests = 100;

    function new(string name = "divide_command_sequence");
        super.new(name);
    endfunction : new

    task body();
        divide_command_transaction cmd;

        repeat (num_tests) begin
            cmd = divide_command_transaction::type_id::create("cmd");
            start_item(cmd);
            if (!cmd.randomize())
                `uvm_fatal("COMMAND_SEQUENCE", "randomize failed")
            finish_item(cmd);
        end
    endtask : body
endclass : divide_command_sequence