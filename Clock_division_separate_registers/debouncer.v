module debouncer_1(
input clk,
input en,
input reset,
output en_d
);

parameter C3_size;
parameter C3_max ; 

wire [(C3_size-1):0] counter;
reg D1;
reg [(C3_size-1):0] D;


//count 10 cycles
d_ff #(.D_SIZE(C3_size))
	counter_10(
			.clk(clk),
			.reset(reset),
			.d(D),
			.q(counter));

always@(*) begin
		if(D == (C3_max-1)) D = 0;
		else if(en) D = counter + 1'b1;
		else if(!en) D = 0;
end

//output en_d
d_ff #(.D_SIZE(1))
	enable_debounce(
			.clk(clk),
			.reset(reset),
			.d(D1),
			.q(en_d));


always@(*) begin
		if(counter == (C3_max-1)) D1 = 1'b1;
		else if(!en) D1 = 1'b0;
end

/*assign en_d = (counter == (C3_max -1)) ? 1'b1 : 
				(!en) ? 1'b0 : 1'b0;*/


endmodule