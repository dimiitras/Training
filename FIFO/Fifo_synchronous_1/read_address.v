module read_address(
clk,
rst_n,
cr_en,
r_ptr);

parameter MEMORY_DEPTH = 4;
parameter ADDRESS_SIZE = 2;

input clk;
input rst_n;
input cr_en;

output [(ADDRESS_SIZE-1):0] r_ptr;


//Counter for r_ptr

reg [(ADDRESS_SIZE-1):0] count_r_in;


d_ff_async_en  #(.SIZE(ADDRESS_SIZE))
 counter_read_address(.clk(clk),
		      .rst(!rst_n),
		      .en(cr_en),       //the counter increments only during reading operation
		      .d(count_r_in),
		      .q(r_ptr));
	

wire r_max;
assign r_max = (r_ptr == (MEMORY_DEPTH -1));   //for restarting the counter when it reaches the maximum value (the depth of the memory)


always@(*) begin
	if(r_max)
		count_r_in = {ADDRESS_SIZE{1'b0}};
	else
		count_r_in = r_ptr + 1'b1;
end


endmodule