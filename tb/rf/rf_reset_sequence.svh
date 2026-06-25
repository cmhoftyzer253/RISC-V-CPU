class rf_reset_sequence extends uvm_sequence #(rf_reset_transaction);
    `uvm_object_utils(rf_reset_sequence)

    function new(string name = "rf_reset_sequence");
        super.new(name);
    endfunction : new

    task body();
        rf_reset_transaction reset;

        forever begin
            reset = rf_reset_transaction::type_id::create("reset");
            start_item(reset);
            if (!reset.randomize()) 
                `uvm_fatal("RESET_SEQUENCE", "randomize failed")
            finish_item(reset);
        end
    endtask : body

endclass : rf_reset_sequence