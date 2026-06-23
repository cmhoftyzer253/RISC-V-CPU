class multiply_reset_sequence extends uvm_sequence #(multiply_reset_transaction);
    `uvm_object_utils(multiply_reset_sequence)

    function new(string name = "multiply_reset_sequence");
        super.new(name);
    endfunction : new

    task body();
        multiply_reset_transaction reset;

        forever begin
            reset = multiply_reset_transaction::type_id::create("reset");
            start_item(reset);
            if (!reset.randomize())
                `uvm_fatal("RESET_SEQUENCE", "randomize failed")
            finish_item(reset);
        end
    endtask : body

endclass : multiply_reset_sequence