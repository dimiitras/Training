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
output reg [(C2_size-1):0] count;

reg enable_dly;
wire pedge;

// 2-bit counter
always@(posedge clk, posedge reset) begin
	if(reset) count <= 0;
	else begin
		if(pedge) begin
			if(count == (C2_max )) count <= 2'b01;
			else begin
				if(en_d) count <= count + 1'b1;
				else count <= 0;
			end
		end
	end
end

//positive edge detection for enable (clk_div)
always@(posedge clk) begin
	enable_dly <= enable;
end

assign pedge = ((enable_dly ==0) && (enable==1));

endmodule