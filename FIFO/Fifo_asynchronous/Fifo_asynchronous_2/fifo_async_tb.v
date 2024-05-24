//`define CLK_PERIOD 10
`timescale 1ns/1ps

module fifo_async_tb ();

parameter MEMORY_WIDTH = 4;
parameter MEMORY_DEPTH = 4;

parameter ADDRESS_SIZE = 2;

parameter CLK_PERIOD = 10;

integer i;

reg w_clk;
reg w_en;
reg wrst_n;
reg r_clk;
reg r_en;
reg rrst_n;
reg [(MEMORY_WIDTH-1): 0] wdata;

wire r_empty;
wire w_full;
wire [(MEMORY_WIDTH-1): 0] rdata;



//`include "design.v";



fifo_async_top_module #(.MEMORY_DEPTH(MEMORY_DEPTH),
			.MEMORY_WIDTH(MEMORY_WIDTH),
	     		.ADDRESS_SIZE(ADDRESS_SIZE))
  fifo_asynchronous (.w_clk(w_clk),
		     .w_en(w_en),
		     .wrst_n(wrst_n),
		     .r_clk(r_clk),
		     .r_en(r_en),
		     .rrst_n(rrst_n),
		     .wdata(wdata),
		     .r_empty(r_empty),
		     .w_full(w_full),
		     .rdata(rdata));

initial
begin
	w_clk = 1'b0;
	r_clk = 1'b0;
	
	wrst_n = 1'b0;
	rrst_n = 1'b0;
	
	w_en = 1'b0;
	r_en = 1'b0;
	
	wdata = {MEMORY_WIDTH{1'b0}};
	
	#13;
	
	wrst_n = 1'b1;
	rrst_n = 1'b1;
	
	main;
	
	$stop;
end





always #(CLK_PERIOD/2)  w_clk = ~ w_clk;
always #(CLK_PERIOD)  r_clk = ~ r_clk;



task main; 
begin
	
	Write;
	Read;
	Write;
	Read;
	Write;
	Read;
	Write;
	Read;
	Write;
	Read;

end
endtask



  
task Write;
begin
		#10;
		w_en = 1'b1;
		for(i=0; i < 5; i = i +1) begin
		@(posedge w_clk)
		begin
			wdata = wdata + 1'b1;
		end
		end
		#20;
		w_en = 1'b0;

end
endtask

task Read;
begin
		#3;
		r_en = 1'b1;

		#100;
		r_en = 1'b0;

end
endtask




endmodule
