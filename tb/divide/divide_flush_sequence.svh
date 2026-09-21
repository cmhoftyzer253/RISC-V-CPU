class divide_flush_sequence extends uvm_sequence #(divide_flush_transaction);
    `uvm_object_utils(divide_flush_sequence)

    function new(string name = "divide_flush_sequence");
        super.new(name);
    endfunction : new

    task body();
        divide_flush_transaction flush;

        forever begin
            flush = divide_flush_transaction::type_id::create("flush");
            start_item(flush);
            if (!flush.randomize())
                `uvm_fatal("FLUSH_SEQUENCE", "randomize failed")
            finish_item(flush);
        end
    endtask : body

endclass : divide_flush_sequence