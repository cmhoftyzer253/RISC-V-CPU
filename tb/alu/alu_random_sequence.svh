class alu_random_sequence extends uvm_sequence #(alu_command_transaction);
    `uvm_object_utils(alu_random_sequence)

    int unsigned num_tests = 1000;

    function new(string name = "alu_random_sequence");
        super.new(name);
    endfunction : new

    task body();
        alu_command_transaction cmd;

        repeat (num_tests) begin
            cmd = alu_command_transaction::type_id::create("cmd");
            start_item(cmd);
            assert(cmd.randomize());
            finish_item(cmd);
        end
    endtask : body

endclass : alu_random_sequence