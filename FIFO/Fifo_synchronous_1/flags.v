module flags(
clk,
rst_n,
w_ptr,
r_ptr,
cw_max,
r_en,
w_en,
cw_en,
cr_en,
full,
empty
);

parameter MEMORY_DEPTH = 4;
parameter ADDRESS_SIZE = 2;

input clk;
input rst_n;
input [(ADDRESS_SIZE-1):0] w_ptr;
input [(ADDRESS_SIZE-1):0] r_ptr;
input cw_max;
input r_en;
input w_en;

output cw_en;
output cr_en;
output full;
output empty;



//FULL signal generation

wire cw_max_in;
assign cw_max_in = (cw_max & w_en);   

wire cw_max_out;

wire r_w_eq;
assign r_w_eq = (w_ptr == r_ptr);	

d_ff_async_en  #(.SIZE(1'b1))
	d_ff_full(.clk(clk),
		  .rst(!rst_n),
		  .en((!r_w_eq)),
		  .d(cw_max_in),
		  .q(cw_max_out)); 


assign full = (r_w_eq & cw_max_out);   //The FIFO is full if new data have been written at every slot (cw_max_in) 
									   //and the w_ptr has circled back to the same value as r_ptr

assign cw_en = (w_en & (!full));

//EMPTY signal generation

assign empty = (!cw_max_out & r_w_eq); //The FIFO is empty if all data have been read (!cw_max_out, since w_ptr has not changed during reading) 
									   //and the r_ptr has circled back to the same value as w_ptr

assign cr_en = (r_en & (!empty));


endmodule