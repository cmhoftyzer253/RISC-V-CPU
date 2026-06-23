class multiply_flush_sequence extends uvm_sequence #(multiply_flush_transaction);
    `uvm_object_utils(multiply_flush_sequence)

    function new(string name = "multiply_flush_sequence");
        super.new(name);
    endfunction : new

    task body();
        multiply_flush_transaction flush;

        forever begin
            flush = multiply_flush_transaction::type_id::create("flush");
            start_item(flush);
            if (!flush.randomize())
                `uvm_fatal("FLUSH_SEQUENCE", "randomize failed")
            finish_item(flush);
        end
    endtask : body

endclass : multiply_flush_sequence