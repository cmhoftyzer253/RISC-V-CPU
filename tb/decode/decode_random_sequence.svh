class decode_random_sequence extends uvm_sequence #(decode_command_transaction);
    `uvm_object_utils(decode_random_sequence)

    int unsigned num_tests  =   1000;

    int weight_r            =   10;
    int weight_i            =   10;
    int weight_s            =   10;
    int weight_b            =   10;
    int weight_u            =   5;
    int weight_j            =   5;
    int weight_system       =   5;
    int weight_exc          =   5;

    function new(string name = "decode_random_sequence");
        super.new(name);
    endfunction : new

    task body();
        repeat (num_tests) begin
            randcase
                weight_r        : send_r_type();
                weight_i        : send_i_type();
                weight_s        : send_s_type();
                weight_b        : send_b_type();
                weight_u        : send_u_type();
                weight_j        : send_j_type();
                weight_system   : send_system_type();
                weight_exc      : send_exc();
            endcase
        end
    endtask : body

    task send_r_type();
        decode_r_type_command_transaction cmd;
        cmd = decode_r_type_command_transaction::type_id::create("cmd");

        start_item(cmd);
        if (!cmd.randomize())
            `uvm_fatal(get_type_name(), "Randomize failed for r_type")
        finish_item(cmd);
    endtask : send_r_type

    task send_i_type();
        decode_i_type_command_transaction cmd;
        cmd = decode_i_type_command_transaction::type_id::create("cmd");

        start_item(cmd);
        if (!cmd.randomize())
            `uvm_fatal(get_type_name(), "Randomize failed for i_type")
        finish_item(cmd);
    endtask : send_i_type

    task send_s_type();
        decode_s_type_command_transaction cmd;
        cmd = decode_s_type_command_transaction::type_id::create("cmd");

        start_item(cmd);
        if (!cmd.randomize())
            `uvm_fatal(get_type_name(), "Randomize failed for s_type")
        finish_item(cmd);
    endtask : send_s_type

    task send_b_type();
        decode_b_type_command_transaction cmd;
        cmd = decode_b_type_command_transaction::type_id::create("cmd");

        start_item(cmd);
        if (!cmd.randomize())
            `uvm_fatal(get_type_name(), "Randomize failed for b_type")
        finish_item(cmd);
    endtask : send_b_type

    task send_u_type();
        decode_u_type_command_transaction cmd;
        cmd = decode_u_type_command_transaction::type_id::create("cmd");

        start_item(cmd);
        if (!cmd.randomize())
            `uvm_fatal(get_type_name(), "Randomize failed for u_type")
        finish_item(cmd);
    endtask : send_u_type

    task send_j_type();
        decode_j_type_command_transaction cmd;
        cmd = decode_j_type_command_transaction::type_id::create("cmd");

        start_item(cmd);
        if (!cmd.randomize())
            `uvm_fatal(get_type_name(), "Randomize failed for j_type")
        finish_item(cmd);
    endtask : send_j_type

    task send_system_type();
        decode_system_type_command_transaction cmd;
        cmd = decode_system_type_command_transaction::type_id::create("cmd");

        start_item(cmd);
        if (!cmd.randomize())
            `uvm_fatal(get_type_name(), "Randomize failed for system_type")
        finish_item(cmd);
    endtask : send_system_type

    task send_exc();
        decode_exc_type_command_transaction cmd;
        cmd = decode_exc_type_command_transaction::type_id::create("cmd");

        start_item(cmd);
        if (!cmd.randomize())
            `uvm_fatal(get_type_name(), "Randomize failed for exc_type")
        finish_item(cmd);
    endtask : send_exc

endclass : decode_random_sequence