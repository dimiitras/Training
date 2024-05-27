module two_ff_synchronizer (
clk,
rst_n,
in,
out);

parameter SYNCHRONIZER_SIZE;


input clk;
input rst_n;
input [(SYNCHRONIZER_SIZE-1):0] in;

output [(SYNCHRONIZER_SIZE-1):0] out;

wire [(SYNCHRONIZER_SIZE-1):0] in2;


//For EDA PLAYGROUND :
// `include "d_ff_async.v";

d_ff_async #(.SIZE(SYNCHRONIZER_SIZE))
	synchronizer_ff_1 (.clk(clk),
			   .rst(!rst_n),
			   .d(in),
			   .q(in2));
			   
d_ff_async #(.SIZE(SYNCHRONIZER_SIZE))
	synchronizer_ff_2 (.clk(clk),
			   .rst(!rst_n),
			   .d(in2),
			   .q(out));			   
			   
			   
endmodule
