class divide_reset_sequence extends uvm_sequence #(divide_reset_transaction);
    `uvm_object_utils(divide_reset_sequence)

    function new(string name = "divide_reset_sequence");
        super.new(name);
    endfunction : new

    task body();
        divide_reset_transaction reset;

        forever begin
            reset = divide_reset_transaction::type_id::create("reset");
            start_item(reset);
            if (!reset.randomize())
                `uvm_fatal("RESET_SEQUENCE", "randomize failed")
            finish_item(reset);
        end
    endtask : body

endclass : divide_reset_sequence