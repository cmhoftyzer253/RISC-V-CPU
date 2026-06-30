class alu_random_sequence extends uvm_sequence #(alu_command_transaction);
    `uvm_object_utils(alu_random_sequence)

    int unsigned num_tests = 1000;

    function new(string name = "alu_random_sequence");
        super.new(name);
    endfunction : new

    task body();
        alu_command_transaction cmd;

        `uvm_info("SEQ", "sequence body started", UVM_HIGH)
        repeat (num_tests) begin
            cmd = alu_command_transaction::type_id::create("cmd");
            start_item(cmd);
            assert(cmd.randomize());
            `uvm_info("SEQ", $sformatf("sending: %s", cmd.convert2string()), UVM_HIGH)
            finish_item(cmd);
        end
        `uvm_info("SEQ", "sequence body done", UVM_HIGH)
    endtask : body

endclass : alu_random_sequence