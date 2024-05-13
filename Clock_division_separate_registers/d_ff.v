module d_ff (
clk,
d,
reset,
q);

parameter D_SIZE;

input clk;
input reset;
input [(D_SIZE-1) : 0] d;
output reg [(D_SIZE-1) : 0] q;

always@(posedge clk) begin
	if(reset) q <= {D_SIZE{1'b0}};
	else q <= d;
end

endmodule