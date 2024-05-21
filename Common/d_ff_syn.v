module d_ff_sync (
clk,
rst,
d,
q);

parameter SIZE = 1'b1;

input clk;
input rst;
input [(SIZE-1):0] d;
output reg [(SIZE-1):0] q;


always@(posedge clk) begin
	if(rst) 
		q <= {SIZE{1'b0}};
	else
		q <= d;
end

endmodule


