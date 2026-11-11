set_false_path -from [get_ports resetn_i]
set_false_path -to [get_ports ddr3_reset_n]

set_false_path -from [get_ports uart_rx_i]
set_false_path -to [get_ports uart_tx_o]

#gpio inputs
set gpio_sync_d [get_pins -filter {REF_PIN_NAME == D} -of_objects [get_cells u_bus/u_gpio/gpio_in_q_reg*]]
set_false_path -from [get_ports {gpio_io[*]}] -to $gpio_sync_d

#gpio outputs
set gpio_ctrl_regs [get_cells -hier -filter {\
    NAME =~ u_bus/u_gpio/OUTPUT_VAL_REG_reg*    || \
    NAME =~ u_bus/u_gpio/OUT_XOR_REG_reg*       || \
    NAME =~ u_bus/u_gpio/OUTPUT_EN_REG_reg*     || \
    NAME =~ u_bus/u_gpio/IOF_EN_REG_reg*}]
set_false_path -from $gpio_ctrl_regs -to [get_ports {gpio_io[*]}]

set_false_path -to [get_pins -filter {REF_PIN_NAME == D} -of_objects \
    [get_cells -hier -filter {NAME =~ *u_resetn_sync_*/aresetn_q_reg*}]]