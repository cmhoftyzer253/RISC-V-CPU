class multiply_ready_sequence extends uvm_sequence #(multiply_ready_transaction);
    `uvm_object_utils(multiply_ready_sequence)

    function new(string name = "multiply_ready_sequence");
        super.new(name);
    endfunction : new

    task body();
        multiply_ready_transaction ready;

        forever begin
            ready = multiply_ready_transaction::type_id::create("ready");
            start_item(ready);
            if (!ready.randomize())
                `uvm_fatal("READY_SEQUENCE", "randomize failed")
            finish_item(ready);
        end
    endtask : body

endclass : multiply_ready_sequence