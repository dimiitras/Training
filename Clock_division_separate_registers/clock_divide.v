module clock_divide (
input clk,
input reset,
output clk_div
);

parameter C1_size;
parameter Compare;

reg [(C1_size-1):0] D;
wire [(C1_size-1):0] Q1;
wire Q2;
reg D2;
wire C;


//counter for clk division
d_ff #(.D_SIZE(C1_size))
	counter1(
		.clk(clk),
		.d(D), 
		.reset(reset),
		.q(Q1));

	
always@(*)begin
		if((Q1+1'b1) == (Compare)) D = {{(C1_size-1){1'b0}}, {1'b1}};
		else D = Q1 + 1'b1;
end


//comparator
assign C = (Q1 == (Compare - 1'b1));


//D ff
d_ff #(.D_SIZE(1))
	d_flip_flop (
		.clk(clk),
		.reset(reset),
		.d(D2),
		.q(Q2));
		
always@(*)begin
		if(C) D2 = (~Q2);
		else D2 = Q2;
end

assign clk_div = Q2;

endmodule