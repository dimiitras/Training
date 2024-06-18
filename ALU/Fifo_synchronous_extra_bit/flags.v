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
input [(ADDRESS_SIZE):0] w_ptr;
input [(ADDRESS_SIZE):0] r_ptr;
input cw_max;
input r_en;
input w_en;

output cw_en;
output cr_en;
output full;
output empty;



//FULL signal generation

wire msb_ptr;
assign msb_ptr = (w_ptr[ADDRESS_SIZE] !== r_ptr[ADDRESS_SIZE]);

wire addr_eq;
assign addr_eq = (w_ptr[(ADDRESS_SIZE-1):0] == r_ptr[(ADDRESS_SIZE-1):0]);

wire full_temp;
assign full_temp = (msb_ptr & addr_eq);  


d_ff_async #(.SIZE(1),
			 .RESET_VALUE(1'b0))
		full_reg(.clk(clk),
		      .rst(!rst_n),       
		      .d(full_temp),
		      .q(full));


assign cw_en = (w_en & (!full_temp));

//EMPTY signal generation


wire empty_temp;
assign empty_temp = (w_ptr == r_ptr); 

d_ff_async #(.SIZE(1),
			 .RESET_VALUE(1'b1))
		empty_reg(.clk(clk),
		      .rst(!rst_n),       
		      .d(empty_temp),
		      .q(empty));


assign cr_en = (r_en & (!empty_temp));


endmodule