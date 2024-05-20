module d_ff_async_en (
clk,
rst,
en,
d,
q);

parameter SIZE = 1;

input clk;
input rst;
input en;
input [(SIZE-1) :0]d;

output reg [(SIZE-1) :0] q;


always@(posedge clk, posedge rst) begin
	if(rst) q <= {SIZE{1'b0}};
	else if(en) q <= d;

end

endmodule
