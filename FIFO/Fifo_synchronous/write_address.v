module write_address(
clk,
rst_n,
cw_en,
w_ptr,
cw_max);

parameter MEMORY_DEPTH = 4;
parameter ADDRESS_SIZE = 2;

input clk;
input rst_n;
input cw_en;

output [(ADDRESS_SIZE-1):0] w_ptr;
output cw_max;


//Counter for w_ptr


reg [(ADDRESS_SIZE-1):0] count_w_in;


assign cw_max = (w_ptr == (MEMORY_DEPTH -1));   //for restarting the counter when it reaches the maximum value (the depth of the memory)


d_ff_async_en  #(.SIZE(ADDRESS_SIZE))
 counter_write_address(.clk(clk),
		       .rst(!rst_n),
		       .en(cw_en),     //the counter increments only during writing operation
		       .d(count_w_in),
		       .q(w_ptr));
		
always@(*) begin
	if(cw_max) 
		count_w_in = {ADDRESS_SIZE{1'b0}};
	else 
		count_w_in = w_ptr + 1'b1;        //cw_max could not have been an enable signal for the counter, because as soon as the counter counts to the last value
										  //the counter restarts, before outputting the last value.
	
end

endmodule