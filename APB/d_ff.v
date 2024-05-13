module d_ff (
clk,
d,
resetn,
q);

parameter D_SIZE = 1;

input clk;
input resetn;
input [(D_SIZE-1) : 0] d;
output reg [(D_SIZE-1) : 0] q;

always@(posedge clk, negedge resetn) begin
	if(!resetn) q <= {D_SIZE{1'b0}};
	else q <= d;
end

endmodule