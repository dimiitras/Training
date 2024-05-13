module registers(
 clk,
 reset,
 d,
 q
);

parameter Flop_size;

input clk;
input reset;
input [(Flop_size-1) : 0] d;
output reg [(Flop_size-1) : 0] q;


always@(posedge clk, posedge reset) begin
	if(reset) q <= 0;
	else q <= d;
end

endmodule