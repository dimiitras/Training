module fifo_sync (
clk,
rst,
w_en,
r_en,
WR,
FULL,
EMPTY,
RD);


parameter MEMORY_WIDTH = 4;
parameter MEMORY_DEPTH = 4;

parameter ADDRESS_SIZE;

input clk;
input rst;
input w_en;
input r_en;
input [(MEMORY_WIDTH-1):0] WR;

output FULL;
output EMPTY;
output [(MEMORY_WIDTH-1):0] RD;




//Counter for w_ptr

wire cw_en ;
assign cw_en = (w_en & (!FULL));

reg [(MEMORY_DEPTH-1):0] count_w_in;
wire [(MEMORY_DEPTH-1):0] w_ptr; /*count_out*/


wire w_max;
assign w_max = (w_ptr == (ADDRESS_SIZE -1));

wire w_wrap_up ;
assign w_wrap_up = ( w_max);

d_ff_async_en  #(.SIZE(ADDRESS_SIZE))
 counter_write_address(.clk(clk),
		       .rst(rst),
		       .en(cw_en),
		       .d(count_w_in),
		       .q(w_ptr));
	
always@(*) begin
	if(w_wrap_up) 
		count_w_in = {ADDRESS_SIZE{1'b0}};
	else 
		count_w_in = w_ptr + 1'b1;
	
end




//Counter for r_ptr

wire [(ADDRESS_SIZE-1):0] r_ptr;

wire cr_en = (r_en & (!EMPTY));

reg [(ADDRESS_SIZE-1):0] count_r_in;


d_ff_async_en  #(.SIZE(ADDRESS_SIZE))
 counter_read_address(.clk(clk),
		      .rst(rst),
		      .en(cr_en),
		      .d(count_r_in),
		      .q(r_ptr));
	

wire r_max;
assign r_max = (r_ptr == (ADDRESS_SIZE -1));

wire r_wrap_up ;
assign r_wrap_up = (rst | r_max);

always@(*) begin
	if(r_wrap_up)
		count_r_in = {ADDRESS_SIZE{1'b0}};
	else
		count_r_in = r_ptr + 1'b1;
end





//FULL signal generation

wire D;
assign D = (w_max & w_en);

wire Q;

wire eq;
assign eq = (w_ptr == r_ptr);	

d_ff_async_en  #(.SIZE(1'b1))
	d_ff_full(.clk(clk),
		  .rst(rst),
		  .en((!eq)),
		  .d(D),
		  .q(Q)); 



assign FULL = (eq & Q);




//EMPTY signal generation

assign EMPTY = (!Q & eq);





//Memory

reg [(MEMORY_WIDTH -1) :0] memory [(MEMORY_DEPTH -1) :0];

/*wire read;
assign read = (r_en & (!FULL));*/



always@(posedge clk) begin
	if(cw_en) 
		memory[w_ptr] <= WR;		
	
end

//Read 

d_ff_async_en #(.SIZE(MEMORY_WIDTH))
	read_out(.clk(clk),
		 .rst(rst),
		 .en((r_en & (!EMPTY))),
		 .d(memory[r_ptr]),
		 .q(RD));
	


endmodule
