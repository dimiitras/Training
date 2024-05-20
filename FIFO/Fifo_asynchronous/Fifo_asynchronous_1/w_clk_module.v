module w_clk_module (
w_clk,
w_en,
wrst_n,
r_ptr,
w_ptr,
w_full,
w_addr);

parameter ADDRESS_SIZE;

parameter ADDRESS_SIZE;


input w_clk;
input w_en;
input wrst_n;
input [(ADDRESS_SIZE): 0] r_ptr;

output w_full;
output [(ADDRESS_SIZE): 0] w_ptr;
output [(ADDRESS_SIZE-1): 0] w_addr;





<<<<<<< HEAD:FIFO/Fifo_asynchronous/w_clk_module.v
//Conditional incrementation

wire [(ADDRESS_SIZE): 0] w_bin;
=======
//Gray to Binary

wire [(ADDRESS_SIZE): 0] wbin;

gray_to_binary #(.N(ADDRESS_SIZE +1))
	w_gray_to_binary_conv (.gray(w_ptr),
			     .binary(bin));
			     
	
			     
	
			     

//Conditional incrementation

>>>>>>> temp_branch:FIFO/Fifo_asynchronous/Fifo_asynchronous_1/w_clk_module.v
wire [(ADDRESS_SIZE): 0] w_bnext;

assign w_bnext = (w_en & (!w_full)) ? (w_bin + 1'b1) : w_bin;






//Write address 

<<<<<<< HEAD:FIFO/Fifo_asynchronous/w_clk_module.v


d_ff_async #(.SIZE(ADDRESS_SIZE +1))
	w_bin_reg (.clk(w_clk),
		   .rst(!wrst_n),
		   .d(w_bnext),
		   .q(w_bin));
		   

assign w_addr = w_bin[(ADDRESS_SIZE-1): 0];	

       
       
       
=======
wire [(ADDRESS_SIZE): 0] w_gnext;

binary_to_gray # (.N(ADDRESS_SIZE +1))
	w_binary_to_gray_conv (.binary(w_bnext),
			       .gray(w_gnext));
			       
			       
			       
	
			       
>>>>>>> temp_branch:FIFO/Fifo_asynchronous/Fifo_asynchronous_1/w_clk_module.v
	
//wptr generation


<<<<<<< HEAD:FIFO/Fifo_asynchronous/w_clk_module.v
wire [(ADDRESS_SIZE): 0] w_gnext;

binary_to_gray # (.N(ADDRESS_SIZE+1))
	w_binary_to_gray_conv (.binary(w_bnext),
			       .gray(w_gnext));


d_ff_async #(.SIZE(ADDRESS_SIZE +1))
	w_gray_reg (.clk(w_clk),
=======
d_ff_async #(.SIZE(ADDRESS_SIZE+1))
	w_ptr_reg (.clk(w_clk),
>>>>>>> temp_branch:FIFO/Fifo_asynchronous/Fifo_asynchronous_1/w_clk_module.v
		   .rst(!wrst_n),
		   .d(w_gnext),
		   .q(w_ptr));



<<<<<<< HEAD:FIFO/Fifo_asynchronous/w_clk_module.v
		       
=======



//Write address generation

wire w_msbnext ;
wire addr_msb;

assign w_msbnext = ( w_gnext[(ADDRESS_SIZE)] ^ w_gnext[(ADDRESS_SIZE -1)] ) ;

d_ff_async #(.SIZE(1))
	w_addr_reg (.clk(w_clk),
		   .rst(!wrst_n),
		   .d(w_msbnext),
		   .q(addr_msb));       
			      
assign w_addr = {addr_msb , w_ptr[(ADDRESS_SIZE-2): 0]};			       
			       
			       
			       
	
			       
			       
>>>>>>> temp_branch:FIFO/Fifo_asynchronous/Fifo_asynchronous_1/w_clk_module.v
			       
//Synchronisation of rptr to wclk

wire [(ADDRESS_SIZE): 0] wq2_rptr;
<<<<<<< HEAD:FIFO/Fifo_asynchronous/w_clk_module.v

two_ff_synchronizer #(.SYNCHRONIZER_SIZE(ADDRESS_SIZE +1 ))
=======
2
2_ff_synchronizer #(.SYNCHRONIZER_SIZE(ADDRESS_SIZE +1 ))
>>>>>>> temp_branch:FIFO/Fifo_asynchronous/Fifo_asynchronous_1/w_clk_module.v
	sync_r2w (.clk(w_clk),
		  .rst_n(wrst_n),
		  .in(r_ptr),
		  .out(wq2_rptr)
		  );



//full signal generation

  
wire f1;
wire f2;
wire f3;

<<<<<<< HEAD:FIFO/Fifo_asynchronous/w_clk_module.v
assign f1 = (wq2_rptr[ADDRESS_SIZE] !== w_gnext[ADDRESS_SIZE]) ;
assign f2 = (wq2_rptr[ADDRESS_SIZE-1] !== w_gnext[ADDRESS_SIZE-1]) ;
=======
assign f1 = (!(wq2_rptr[ADDRESS_SIZE] == w_gnext[ADDRESS_SIZE]));
assign f2 = (!(wq2_rptr[ADDRESS_SIZE-1] == w_gnext[ADDRESS_SIZE-1]));
>>>>>>> temp_branch:FIFO/Fifo_asynchronous/Fifo_asynchronous_1/w_clk_module.v
assign f3 = (wq2_rptr[(ADDRESS_SIZE-2) :0] == w_gnext[(ADDRESS_SIZE-2) :0]);


assign w_full_temp = (f1 && f2 && f3);


			   
d_ff_async #(.SIZE(1))
	w_full_reg (.clk(w_clk),
	 	    .rst(!wrst_n),
		    .d(w_full_temp),
		    .q(w_full));	


endmodule
