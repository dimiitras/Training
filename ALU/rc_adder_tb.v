`timescale 1ns/1ps
module rc_adder_tb();

parameter DATA_SIZE = 16;
parameter CLK_PERIOD = 10;

reg clk;
reg rst_n;
reg [(DATA_SIZE-1) :0] add_1;
reg [(DATA_SIZE-1) :0] add_2;
reg c_in;

reg [(DATA_SIZE-1) :0] s;
reg c_out;


rca_1_bit_reg 
      rca_dut  (.clk(clk),
                .rst_n(rst_n),
                .add_1(add_1),
                .add_2(add_2),
                .c_in(c_in),
                .s(s),
                .c_out(c_out));


always #(CLK_PERIOD/2)  clk = ~ clk;

initial
begin
     clk = 1'b0;
	rst_n = 1'b0;

    #13;
    add_1 = 16'h2A;
    add_2 = 16'hC9;
    //add_1 = 4'b1010;
    //add_2 = 4'b1011;   //0110 1110
    valid_f_data = 1'b1;
    ready_f_res = 1'b1;

    #13;
    rst_n = 1'b1;

    
    //@(posedge clk) valid_f_in = 1'b0;

    #100;
    valid_f_data = 1'b0;
    ready_f_res = 1'b0;

    #10;
    a_in = 4'b1000;
    b_in = 4'b0110;  //0011 0000
    valid_f_data = 1'b1;

    #50;
    ready_f_res = 1'b1;
    #500;
    $stop;


end



endmodule           
