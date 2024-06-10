module fifo_synch (
clk,
rst_n,
w_en,
r_en,
wdata,
full,
empty,
rdata);


parameter MEMORY_WIDTH = 4;
parameter MEMORY_DEPTH = 4;

parameter ADDRESS_SIZE = 2;

parameter MEM_IP = 1;

input clk;
input rst_n;
input w_en;
input r_en;
input [(MEMORY_WIDTH-1):0] wdata;

output full;
output empty;
output [(MEMORY_WIDTH-1):0] rdata;



wire cw_en;
wire [(ADDRESS_SIZE-1):0] w_ptr;
wire cw_max;


write_address #(.MEMORY_DEPTH(MEMORY_DEPTH),
				.ADDRESS_SIZE(ADDRESS_SIZE))
  write_module (.clk(clk),
	    	   .rst_n(rst_n),
	    	   .cw_en(cw_en),
			   .w_ptr(w_ptr),
			   .cw_max(cw_max));


wire cr_en;
wire [(ADDRESS_SIZE-1):0] r_ptr;


read_address #(.MEMORY_DEPTH(MEMORY_DEPTH),
				.ADDRESS_SIZE(ADDRESS_SIZE))
  read_module  (.clk(clk),
	    	   .rst_n(rst_n),
	    	   .cr_en(cr_en),
			   .r_ptr(r_ptr));


flags #(.MEMORY_DEPTH(MEMORY_DEPTH),
		.ADDRESS_SIZE(ADDRESS_SIZE))
	flags_module (.clk(clk),
				  .rst_n(rst_n),
				  .w_ptr(w_ptr),
                  .r_ptr(r_ptr),
                  .cw_max(cw_max),
				  .r_en(r_en),
                  .w_en(w_en),
                  .cw_en(cw_en),
                  .cr_en(cr_en),
                  .full(full),
                  .empty(empty));
	

memory #(.MEMORY_DEPTH(MEMORY_DEPTH),
		.MEMORY_WIDTH(MEMORY_WIDTH),
		.ADDRESS_SIZE(ADDRESS_SIZE),
		.MEM_IP(MEM_IP))
	memory_module (.clk(clk),
	               .rst_n(rst_n),
				   .cw_en(cw_en),
				   .cr_en(cr_en),
				   .wdata(wdata),
				   .w_ptr(w_ptr),
				   .r_ptr(r_ptr),
				   .rdata(rdata));

	
endmodule  