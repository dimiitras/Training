module top_module1 (
clk,
reset,
en,
out
);

parameter C1_size = 5;
parameter Compare = 5;
parameter C2_max = 2'b11;
parameter C2_size = 2;
parameter C3_max = 4'b1010; 
parameter C3_size = 4;


input clk;
input reset;
input en;
output [(C2_size-1):0] out;


wire clk_div;
wire en_d;
//wire [(C2_size-1):0] count;

//clock divider
clock_divide #(.C1_size(C1_size),.Compare(Compare)) 
	 i1(
	.clk(clk), 
	.reset(reset), 
	.clk_div(clk_div));

//counter 2 bit
counter #(.C2_max(C2_max),.C2_size(C2_size)) 
	i2(
	.clk(clk),
	.enable(clk_div), 
	.reset(reset),
	.en_d(en_d),
	.count(out));


//debouncer
debouncer_1 #(.C3_size(C3_size), .C3_max(C3_max))
	i3(
	.clk(clk),
	.reset(reset),
	.en(en),
	.en_d(en_d));

/*mux
mux #(.C2_size(C2_size)) 
	i4(
	.sel(en_d),
	.count(count),
	.out(out));*/
	

endmodule