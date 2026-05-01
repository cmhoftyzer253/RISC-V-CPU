class alu_random_sequence extends uvm_sequence #(alu_command_transaction);
    `uvm_object_utils(alu_random_sequence)

    alu_command_transaction instr;

    function new(string name = "alu_random_sequence");
        super.new(name);
    endfunction : new

    task body();
        repeat (1000) begin : random_loop
            instr = alu_command_transaction::type_id::create("instr");
            start_item(instr);
            assert(instr.randomize());
            finish_item(instr);
        end : random_loop
    endtask : body

endclass : alu_random_sequence