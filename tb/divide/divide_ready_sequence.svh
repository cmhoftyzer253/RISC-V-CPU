class divide_ready_sequence extends uvm_sequence #(divide_ready_transaction);
    `uvm_object_utils(divide_ready_sequence)

    function new(string name = "divide_ready_sequence");
        super.new(name);
    endfunction : new

    task body();
        divide_ready_transaction ready;

        forever begin
            ready = divide_ready_transaction::type_id::create("ready");
            start_item(ready);
            if (!ready.randomize())
                `uvm_fatal("READY_SEQUENCE", "randomize failed")
            finish_item(ready);
        end
    endtask : body

endclass : divide_ready_sequence