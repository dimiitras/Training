`timescale 1ns / 1ps
module tm_1_tb();

parameter C1_size = 5;
parameter Compare = 5;
parameter C2_max = 2'b11;
parameter C2_size = 2;
parameter C3_max = 4'b1010; 
parameter C3_size = 4;
/* 5*10^7 => 26'h2faf080 */

reg clk;
reg reset;
reg en;
wire [(C2_size-1):0] out;

top_module1 #(.C1_size(C1_size), .Compare(Compare), .C2_max(C2_max), .C2_size(C2_size), .C3_max(C3_max) ,.C3_size(C3_size)) 
		dut1(
		.clk(clk), 
		.reset(reset), 
		.en(en), 
		.out(out));

//clock
initial begin 
clk= 1'b0;
forever #5 clk=~clk;
end

//reset
initial begin
 reset = 1'b1;
 #10;
 reset = 1'b0;
end

//enable
initial begin
en = 1'b1;
#730; 
en = 1'b0;
#325;
en = 1'b1;
end

endmodule