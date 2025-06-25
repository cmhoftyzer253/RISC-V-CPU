`timescale 1ns/1ps
import cpu_consts::*;

module tb_register_file;

    logic        clk;
    logic        reset;
    logic [4:0]  rs1_addr_i;
    logic [4:0]  rs2_addr_i;
    logic [63:0] rs1_data_o;
    logic [63:0] rs2_data_o;
    logic [4:0]  rd_addr_i;
    logic        wr_en_i;
    logic [63:0] wr_data_i;

    register_file dut(
        .clk        (clk),
        .reset      (reset),
        .rs1_addr_i (rs1_addr_i),
        .rs2_addr_i (rs2_addr_i),
        .rs1_data_o (rs1_data_o),
        .rs2_data_o (rs2_data_o),
        .rd_addr_i  (rd_addr_i),
        .wr_en_i    (wr_en_i),
        .wr_data_i  (wr_data_i)
    );

    typedef struct packed {
        logic        reset;
        logic [4:0]  rs1_addr;
        logic [4:0]  rs2_addr;
        logic [4:0]  rd_addr;
        logic        wr_en;
        logic        wr_data;
        logic [63:0] rs1_data_expected;
        logic [63:0] rs2_data_expected;
    } test_vect_t;

    test_vect_t test_vect [0:38]= '{

        //---------------------- Hold reset with varying inputs ----------------------
        '{
            reset : 1'b1,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  //all inputs low

        '{
            reset : 1'b1,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b11100,
            wr_en : 1'b0,
            wr_data : 64'h5608_8782_558F_9642,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },    //addresses, data input

        '{
            reset : 1'b1,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b10101,
            wr_en : 1'b1,
            wr_data : 64'h75F7_8563_EC85_6640,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },    //addresses, data input, write enable

        '{
            reset : 1'b1,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b10011,
            wr_en : 1'b1,
            wr_data : 64'h5BB4_0158_27A5_1E00,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },    //addresses, data input, write enable

        //---------------------- Sample outputs ----------------------
        // rs1 : previously written registers
        // rs2 : random registers
        '{
            reset : 1'b0,
            rs1_addr : 5'b11100,
            rs2_addr : 5'b00001,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },    

        '{
            reset : 1'b0,
            rs1_addr : 5'b10101,
            rs2_addr : 5'b10000,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },    

        '{
            reset : 1'b0,
            rs1_addr : 5'b10011,
            rs2_addr : 5'b01011,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  

        //---------------------- Write values with write enable low ----------------------  
        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b11001,
            wr_en : 1'b0,
            wr_data : 64'h2A37_4483_A923_C00E,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b11110,
            wr_en : 1'b0,
            wr_data : 64'h8AD2_3D5A_10F2_3F27,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        }, 

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b11011,
            wr_en : 1'b0,
            wr_data : 64'h3E6B_7730_07F8_6981,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        }, 

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b11010,
            wr_en : 1'b0,
            wr_data : 64'h4EBC_E89F_A6B4_B832,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        }, 

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b00111,
            wr_en : 1'b0,
            wr_data : 64'hC25D_6CE9_5E10_63BD,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        }, 

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b01101,
            wr_en : 1'b0,
            wr_data : 64'hEB70_98D0_91CD_7F13,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        }, 

        //---------------------- Sample outputs ----------------------  
        '{
            reset : 1'b0,
            rs1_addr : 5'b11001,
            rs2_addr : 5'b11110,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  //written registers

        '{
            reset : 1'b0,
            rs1_addr : 5'b11011,
            rs2_addr : 5'b11010,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  //written registers

        '{
            reset : 1'b0,
            rs1_addr : 5'b00111,
            rs2_addr : 5'b01101,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  //written registers

        '{
            reset : 1'b0,
            rs1_addr : 5'b00101,
            rs2_addr : 5'b10101,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  //random registers

        //---------------------- Write values with write enable high ----------------------
        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b10011,
            wr_en : 1'b1,
            wr_data : 64'h6EAD_167F_1B70_A1B8,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b01110,
            wr_en : 1'b1,
            wr_data : 64'h4232_6A16_56FB_41AA,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b00000,
            wr_en : 1'b1,
            wr_data : 64'hD689_EA30_5AC4_9816,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  //write zero register

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b01100,
            wr_en : 1'b1,
            wr_data : 64'h4CB4_8A11_9DF1_2C30,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b10111,
            wr_en : 1'b1,
            wr_data : 64'hEA75_7776_3B95_FCE8,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  

        //---------------------- Sample outputs ----------------------  
        '{
            reset : 1'b0,
            rs1_addr : 5'b10011,
            rs2_addr : 5'b01110,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h6EAD_167F_1B70_A1B8,
            rs2_data_expected : 64'h4232_6A16_56FB_41AA
        },  

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b01100,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h4CB4_8A11_9DF1_2C30
        },  

        '{
            reset : 1'b0,
            rs1_addr : 5'b10111,
            rs2_addr : 5'b11100,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'hEA75_7776_3B95_FCE8,
            rs2_data_expected : 64'h9D54_D65E_205B_0741
        },  

        //---------------------- Overwrite some registers ----------------------  
        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b01100,
            wr_en : 1'b1,
            wr_data : 64'h5297_12B8_836A_F757,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b10111,
            wr_en : 1'b1,
            wr_data : 64'h7A30_D33E_C927_0388,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b11100,
            wr_en : 1'b1,
            wr_data : 64'hB56B_762E_ADC5_ECBC,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  

        //---------------------- Sample outputs ----------------------  
        '{
            reset : 1'b0,
            rs1_addr : 5'b10011,
            rs2_addr : 5'b01110,
            rd_addr : 5'b00000,
            wr_en : 1'b1,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h6EAD_167F_1B70_A1B8,
            rs2_data_expected : 64'h4232_6A16_56FB_41AA
        },  

        '{
            reset : 1'b0,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b01100,
            rd_addr : 5'b00000,
            wr_en : 1'b1,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h5297_12B8_836A_F757
        },  

        '{
            reset : 1'b0,
            rs1_addr : 5'b10111,
            rs2_addr : 5'b11100,
            rd_addr : 5'b00000,
            wr_en : 1'b1,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h7A30_D33E_C927_0388,
            rs2_data_expected : 64'hB56B_762E_ADC5_ECBC
        },  

        //---------------------- Reset ----------------------  
        '{
            reset : 1'b1,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b00000,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        },  

        
        //---------------------- Sample Outputs ----------------------  
        '{
            reset : 1'b1,
            rs1_addr : 5'b10011,
            rs2_addr : 5'b01110,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        }, 

        '{
            reset : 1'b1,
            rs1_addr : 5'b00000,
            rs2_addr : 5'b01100,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        }, 

        '{
            reset : 1'b1,
            rs1_addr : 5'b10111,
            rs2_addr : 5'b11100,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        }, 

        '{
            reset : 1'b1,
            rs1_addr : 5'b00110,
            rs2_addr : 5'b11011,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        }, 

        '{
            reset : 1'b1,
            rs1_addr : 5'b01001,
            rs2_addr : 5'b11111,
            rd_addr : 5'b00000,
            wr_en : 1'b0,
            wr_data : 64'h0000_0000_0000_0000,
            rs1_data_expected : 64'h0000_0000_0000_0000,
            rs2_data_expected : 64'h0000_0000_0000_0000
        }, 
    };

    typedef struct packed {
        logic [63:0] rs1_data_got;
        logic [63:0] rs2_data_got;
    } got_vect_t;

    got_vect_t got_vect;

    typedef struct packed {
        logic [63:0] rs1_data_expected;
        logic [63:0] rs2_data_expected;
    } exp_vect_t;

    exp_vect_t exp_vect;

    //generate clock signal
    initial begin
         clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("-------- Starting Register File Tests --------");
        @(posedge clk);

        foreach(test_vect[i]) begin
            //drive inputs
            reset       = test_vect[i].reset;
            rs1_addr_i  = test_vect[i].rs1_addr,
            rs2_addr_i  = test_vect[i].rs2_addr,
            rd_addr_i   = test_vect[i].rd_addr,
            wr_en_i     = test_vect[i].wr_en,
            wr_data_i   = test_vect[i].wr_data

            //update expected values
            exp_vect = '{
                test_vect[i].rs1_data_expected,
                test_vect[i].rs2_data_expected
            };

            @(posedge clk);
            #1ns;   //TODO - TBD

            got_vect = '{
                rs1_data_o,
                rs2_data_o
            };


            if(got_vect !== exp_vect) begin
                $error("FAILED TESTCASE [%0d]:\n    got: %p\n   expected: %p\n",
                        i, got_vect, exp_vect);
            end else begin
                $display("PASSED TESTCASE [%0d]", i);
            end

        end

        $display("-------- Register File Tests Finished --------");
    end
    
endmodule