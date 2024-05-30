//`define CLK_PERIOD 10
`timescale 1ns/1ps

module fifo_async_tb ();

parameter MEMORY_WIDTH = 4;
parameter MEMORY_DEPTH = 4;

parameter ADDRESS_SIZE = 2;

parameter REAL_MEM = 0;   // 0 -> Memory IP , 1 -> memory array
parameter READ_REG = 1;	  // 0 -> no ff at read output, 1 -> rdata goes through a ff

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



//For EDA PLAYGROUND :
//`include "fifo_async_top_module.v";



fifo_async_top_module #(.MEMORY_DEPTH(MEMORY_DEPTH),
						.MEMORY_WIDTH(MEMORY_WIDTH),
						.ADDRESS_SIZE(ADDRESS_SIZE),
						.REAL_MEM(REAL_MEM),
						.READ_REG(READ_REG))
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
	
	#100; //Vivado simulation (post-synthesis) :GSR deasserts after 100ns
	
	main;
	//R_W;
	
	#20;
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
		#5;
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

		#200;
		r_en = 1'b0;

end
endtask

task R_W;
begin
	
	wdata = 4'b0001;
	#7;
	w_en = 1'b1;
	#2;
	w_en = 1'b0;
	r_en = 1'b1;
	#10;
	r_en = 1'b0;
	wdata = 4'b0010;
	w_en = 1'b1;
	#5;
	w_en = 1'b0;
	r_en = 1'b1;
	#16;
	r_en = 1'b0;
	w_en = 1'b1;
	wdata = 4'b0100;
	#5;
	w_en = 1'b0;
	r_en = 1'b1;

	
end
endtask


endmodule
