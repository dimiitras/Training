module d_ff_sync_en (
clk,
rst,
en,
d,
q);

parameter SIZE = 1'b1;

input clk;
input rst;
input en;
input [(SIZE-1):0] d;
output reg [(SIZE-1):0] q;

always@(posedge clk) begin
	if(rst) 
		q <= {SIZE{1'b0}};
	else if(en)
		q <= d;
end

endmodule
