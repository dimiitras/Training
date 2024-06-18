`timescale 1ns/1ps
module mul_fsm_tb();


parameter DATA_SIZE = 4;
parameter COUNTER_SIZE = ($clog2(DATA_SIZE)+1); 

parameter CLK_PERIOD = 10;

reg                       clk;
reg                       rst_n;
reg [(DATA_SIZE-1):0]     a_in;
reg [(DATA_SIZE-1):0]     b_in;
reg                       valid_f_data;
reg                       ready_f_res;

wire                       valid_f_res;
wire [((2*DATA_SIZE)-1):0] result;
wire                       ready_f_data;
  

mul_fsm #(.DATA_SIZE(DATA_SIZE),
          .COUNTER_SIZE(COUNTER_SIZE))
    mul_dut(.clk(clk),
            .rst_n(rst_n),
            .a_in(a_in),
            .b_in(b_in),
            .valid_f_data(valid_f_data),
            .ready_f_res(ready_f_res),
            .valid_f_res(valid_f_res),
            .result(result),
            .ready_f_data(ready_f_data));


initial 
begin
    clk = 1'b0;
	rst_n = 1'b0;

    #13;
    //a_in = 16'h2A;
    //b_in = 16'hC9;
    a_in = 4'b1010;
    b_in = 4'b1011;   //0110 1110
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


always #(CLK_PERIOD/2)  clk = ~ clk;





endmodule
