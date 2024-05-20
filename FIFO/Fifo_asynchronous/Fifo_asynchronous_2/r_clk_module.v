module r_clk_module (
r_clk,
r_en,
rrst_n,
r_ptr,
w_ptr,
r_empty,
r_addr);

parameter MEMORY_DEPTH;
parameter ADDRESS_SIZE;


input r_clk;
input r_en;
input rrst_n;
input [(ADDRESS_SIZE): 0] w_ptr;

output r_empty;
output [(ADDRESS_SIZE): 0] r_ptr;
output [(ADDRESS_SIZE-1): 0] r_addr;




//Gray to Binary

wire [(ADDRESS_SIZE): 0] rbin;

gray_to_binary #(.N(ADDRESS_SIZE +1))
	r_gray_to_binary_conv (.gray(r_ptr),
			     .binary(rbin));
			     
	
			     
	
			     

//Conditional incrementation

wire [(ADDRESS_SIZE): 0] r_bnext;

assign r_bnext = (r_en & (!r_empty)) ? (rbin + 1'b1) : rbin;






//Binary to Gray

wire [(ADDRESS_SIZE): 0] r_gnext;

binary_to_gray # (.N(ADDRESS_SIZE +1))
	r_binary_to_gray_conv (.binary(r_bnext),
			       .gray(r_gnext));
			       
			       
			       
	
			       
	
//rptr generation


d_ff_async #(.SIZE(ADDRESS_SIZE +1))
	w_ptr_reg (.clk(r_clk),
		   .rst(!rrst_n),
		   .d(r_gnext),
		   .q(r_ptr));






//Read address generation

wire r_msbnext ;
wire addr_msb;

assign r_msbnext = ( r_gnext[(ADDRESS_SIZE)] ^ r_gnext[(ADDRESS_SIZE -1)] ) ;

d_ff_async #(.SIZE(1))
	r_addr_reg (.clk(r_clk),
		   .rst(!rrst_n),
		   .d(r_msbnext),
		   .q(addr_msb)
		   );       
			      
assign r_addr = {addr_msb , r_ptr[(ADDRESS_SIZE-2): 0]};			       
			       
			       
			       
	
			       
			       
			       
//Synchronisation of wptr to rclk

wire [(ADDRESS_SIZE): 0] rq2_wptr;

wire r_empty_temp;

two_ff_synchronizer #(.SYNCHRONIZER_SIZE(ADDRESS_SIZE +1 ))
	sync_w2r (.clk(r_clk),
		  .rst_n(rrst_n),
		  .in(w_ptr),
		  .out(rqw_wptr)
		  );



//empty signal generation


assign r_empty = (r_gnext == rq2_wptr);


d_ff_async #(SIZE(SYNCHRONIZER_SIZE))
	r_empty_reg (.clk(r_clk),
			.rst(!rrst_n),
			   .d(r_empty_temp),
			   .q(r_empty));			   
			   



endmodule
