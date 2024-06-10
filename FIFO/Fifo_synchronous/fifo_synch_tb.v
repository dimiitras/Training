`timescale 1ns/1ps
//`define CLK_PERIOD 10


module fifo_sync_tb ();

parameter MEMORY_WIDTH = 4;
parameter MEMORY_DEPTH = 4;

parameter ADDRESS_SIZE = 4;

parameter MEM_IP = 1;

parameter CLK_PERIOD = 10;

integer i;

reg clk;
reg rst_n;
reg w_en;
reg r_en;
reg [(MEMORY_WIDTH-1):0] wdata;

wire full;
wire empty;
wire [(MEMORY_WIDTH-1):0] rdata;



fifo_synch #(.MEMORY_WIDTH(MEMORY_WIDTH),
	    .MEMORY_DEPTH(MEMORY_DEPTH),
	    .ADDRESS_SIZE(ADDRESS_SIZE),
		.MEM_IP(MEM_IP))
  fifo_synchronous (.clk(clk),
	    	   .rst_n(rst_n),
	    	   .w_en(w_en),
	    	   .r_en(r_en),
	   	   .wdata(wdata),
	    	   .full(full),
	   	   .empty(empty),
	    	   .rdata(rdata));

initial
begin
	clk = 1'b0;
	rst_n = 1'b0;
	
	w_en = 1'b0;
	r_en = 1'b0;
	
	wdata = {MEMORY_WIDTH{1'b0}};
	
	#13;
	
	rst_n = 1'b1;
	main;
	
	#1500; 
	$stop;
end


always #(CLK_PERIOD/2)  clk = ~ clk;


task main; 
begin
	
	Write;
	Read;
	Write;
	Read;
end
endtask



  
task Write;
begin
		#5;
		w_en = 1'b1;
		for(i=0; i < 5; i = i +1) begin
		@(posedge clk)
		begin
		    #3;
			wdata = wdata + 1'b1;
		end
		end
		#3;
		w_en = 1'b0;

end
endtask

task Read;
begin
		r_en = 1'b1;
		#(CLK_PERIOD *6)
		r_en = 1'b0;


end
endtask

/*task Write_Read;
begin

	w_en = 1'b1;
	@(posedge clk);
	WR= 1;
	@(posedge clk);
	r_en = 1'b1;
	@(posedge clk);
	@(posedge clk);
	w_en = 1'b1;
	WR = 2;
	@(posedge clk);
	@(posedge clk);
	r_en = 1'b1;
end
endtask*/



endmodule
