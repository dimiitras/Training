module r_clk_module (
r_clk,
r_en,
rrst_n,
r_ptr,
w_ptr,
r_empty,
r_addr);

parameter MEMORY_DEPTH;


input r_clk;
input r_en;
input rrst_n;
input [(MEMORY_DEPTH): 0] w_ptr;

output r_empty;
output [(MEMORY_DEPTH): 0] r_ptr;
output [(MEMORY_DEPTH-1): 0] r_addr;




//Gray to Binary

wire [(MEMORY_DEPTH): 0] rbin;

gray_to_binary #(.N(MEMORY_DEPTH +1))
	r_gray_to_binary_conv (.gray(r_ptr),
			     .binary(rbin));
			     
	
			     
	
			     

//Conditional incrementation

wire [(MEMORY_DEPTH): 0] r_bnext;

assign r_bnext = (w_en & (!r_empty)) ? (rbin + 1'b1) : rbin;






//Binary to Gray

wire [(MEMORY_DEPTH): 0] r_gnext;

binary_to_gray # (.N(MEMORY_DEPTH +1))
	r_binary_to_gray_conv (.binary(r_bnext),
			       .gray(r_gnext));
			       
			       
			       
	
			       
	
//rptr generation


d_ff_async #(SIZE(MEMORY_DEPTH +1))
	w_ptr_reg (.clk(r_clk),
		   .rst(!rrst_n),
		   .d(r_gnext),
		   .q(r_ptr));






//Read address generation

wire r_msbnext ;
wire addr_msb;

assign r_msbnext = ( r_gnext[(MEMORY_DEPTH)] ^ r_gnext[(MEMORY_DEPTH -1)] ) ;

d_ff_async #(SIZE(1))
	r_addr_reg (.clk(r_clk),
		   .rst(!rrst_n),
		   .d(r_msbnext),
		   .q(addr_msb)
		   );       
			      
assign r_addr = {addr_msb , r_ptr[(MEMORY_DEPTH-2): 0]};			       
			       
			       
			       
	
			       
			       
			       
//Synchronisation of wptr to rclk

wire [(MEMORY_DEPTH): 0] rq2_wptr;
2
2_ff_synchronizer #(.SYNCHRONIZER_SIZE(MEMORY_DEPTH +1 ))
	sync_w2r (.clk(r_clk),
		  .rst_n(rrst_n),
		  .in(w_ptr),
		  .out(rqw_wptr)
		  );



//empty signal generation


assign r_empty = (r_gnext == rq2_wptr);




endmodule
