module debouncer_1(
input clk,
input en,
input reset,
output reg en_d
);

parameter C3_size;
parameter C3_max ; 

reg [(C3_size-1):0] counter;
reg q;

//count 10 cycles
always@(posedge clk, posedge reset) begin
	if(reset) counter <= 0;
	//else if(q == en) counter <= 0;
	else begin
		if(counter == (C3_max-1)) counter <= 0;
		else if(en) counter <= counter + 1'b1;
		else if(!en) counter <= 0;
	end
end

//output en_d
always@(posedge clk, posedge reset) begin
	if(reset) en_d <= 0;
	else begin
		if(counter == (C3_max-1)) en_d <= 1'b1;
		else if(!en) en_d <= 1'b0;
	end
end

/*assign en_d = (counter == (C3_max -1)) ? 1'b1 : 
				(!en) ? 1'b0 : 1'b0;*/


endmodule