module r_clk_module (
r_clk,
r_en,
rrst_n,
r_ptr,
w_ptr,
r_empty,
r_addr);

<<<<<<< HEAD:FIFO/Fifo_asynchronous/r_clk_module.v
=======
parameter MEMORY_DEPTH;
>>>>>>> temp_branch:FIFO/Fifo_asynchronous/Fifo_asynchronous_1/r_clk_module.v
parameter ADDRESS_SIZE;


input r_clk;
input r_en;
input rrst_n;
input [(ADDRESS_SIZE): 0] w_ptr;

output r_empty;
output [(ADDRESS_SIZE): 0] r_ptr;
output [(ADDRESS_SIZE-1): 0] r_addr;




<<<<<<< HEAD:FIFO/Fifo_asynchronous/r_clk_module.v

//Conditional incrementation

wire [(ADDRESS_SIZE): 0] r_bin;
=======
//Gray to Binary

wire [(ADDRESS_SIZE): 0] rbin;

gray_to_binary #(.N(ADDRESS_SIZE +1))
	r_gray_to_binary_conv (.gray(r_ptr),
			     .binary(rbin));
			     
	
			     
	
			     

//Conditional incrementation

>>>>>>> temp_branch:FIFO/Fifo_asynchronous/Fifo_asynchronous_1/r_clk_module.v
wire [(ADDRESS_SIZE): 0] r_bnext;


assign r_bnext = (r_en & (!r_empty)) ? (r_bin + 1'b1) : r_bin;






//Read address 

<<<<<<< HEAD:FIFO/Fifo_asynchronous/r_clk_module.v


d_ff_async #(.SIZE(ADDRESS_SIZE +1))
	r_bin_reg (.clk(r_clk),
		   .rst(!rrst_n),
		   .d(r_bnext),
		   .q(r_bin));


assign r_addr = r_bin[(ADDRESS_SIZE-1): 0];	

       
   
       
=======
wire [(ADDRESS_SIZE): 0] r_gnext;

binary_to_gray # (.N(ADDRESS_SIZE +1))
	r_binary_to_gray_conv (.binary(r_bnext),
			       .gray(r_gnext));
			       
			       
			       
	
			       
>>>>>>> temp_branch:FIFO/Fifo_asynchronous/Fifo_asynchronous_1/r_clk_module.v
	
//rptr generation

wire [(ADDRESS_SIZE): 0] r_gnext ;

<<<<<<< HEAD:FIFO/Fifo_asynchronous/r_clk_module.v
binary_to_gray # (.N(ADDRESS_SIZE +1))
	r_binary_to_gray_conv (.binary(r_bnext),
			       .gray(r_gnext));


d_ff_async #(.SIZE(ADDRESS_SIZE+1))
	r_gray_reg (.clk(r_clk),
=======
d_ff_async #(.SIZE(ADDRESS_SIZE +1))
	w_ptr_reg (.clk(r_clk),
>>>>>>> temp_branch:FIFO/Fifo_asynchronous/Fifo_asynchronous_1/r_clk_module.v
		   .rst(!rrst_n),
		   .d(r_gnext),
		   .q(r_ptr));

<<<<<<< HEAD:FIFO/Fifo_asynchronous/r_clk_module.v
			  
=======





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
			       
>>>>>>> temp_branch:FIFO/Fifo_asynchronous/Fifo_asynchronous_1/r_clk_module.v
			       
			       
	
			       
			       
			       
//Synchronisation of wptr to rclk

wire [(ADDRESS_SIZE): 0] rq2_wptr;
<<<<<<< HEAD:FIFO/Fifo_asynchronous/r_clk_module.v

two_ff_synchronizer #(.SYNCHRONIZER_SIZE(ADDRESS_SIZE +1 ))
=======
2
2_ff_synchronizer #(.SYNCHRONIZER_SIZE(ADDRESS_SIZE +1 ))
>>>>>>> temp_branch:FIFO/Fifo_asynchronous/Fifo_asynchronous_1/r_clk_module.v
	sync_w2r (.clk(r_clk),
		  .rst_n(rrst_n),
		  .in(w_ptr),
		  .out(rq2_wptr)
		  );





//Empty signal generation

wire r_empty_temp;

assign r_empty_temp = (r_gnext == rq2_wptr);

d_ff_async #(.SIZE(1))
	r_empty_reg (.clk(r_clk),
	 	    .rst(!rrst_n),
		    .d(r_empty_temp),
		    .q(r_empty));	



endmodule
