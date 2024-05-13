module counter (
 clk,
 enable,
 reset,
 en_d,
 count
);

parameter C2_max , C2_size;

input clk;
input enable;
input reset;
input en_d;
output [(C2_size-1):0] count;

reg [(C2_size-1):0] D;
reg enable_dly;
wire pedge;


// 2-bit counter
d_ff #(.D_SIZE(C2_size))
		counter(
			.clk(clk), 
			.reset(reset),
			.d(D), 
			.q(count));

always@(*) begin
		if(pedge) begin
			if(D == (C2_max)) D = 2'b01;
			else begin
				if(en_d) D = count + 1'b1;
				else D = {26{1'b0}};
			end
		end
	end


//positive edge detection for enable (clk_div)
d_ff #(.D_SIZE(1))
		edge_detector(
			.clk(clk), 
			.reset(reset),
			.d(enable_dly), 
			.q(enable));

assign pedge = ((enable_dly == 1'b0) && (enable == 1'b1));

endmodule