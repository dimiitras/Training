module d_ff_async_r1 (
clk,
rst,
d,
q);

parameter SIZE = 1;

input clk;
input rst;
input [(SIZE-1):0] d;
output reg [(SIZE-1):0] q;



always@(posedge clk, posedge rst) begin
	if(rst) 
		q <= {SIZE{1'b1}};
	else
		q <= d;
end

endmodule
