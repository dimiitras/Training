module w_clk_module_1 (
w_clk,
w_en,
wrst_n,
r_ptr,
w_ptr,
w_full,
w_addr);

parameter ADDRESS_SIZE;


input w_clk;
input w_en;
input wrst_n;
input [(ADDRESS_SIZE): 0] r_ptr;

output w_full;
output [(ADDRESS_SIZE): 0] w_ptr;
output [(ADDRESS_SIZE-1): 0] w_addr;



/*`include "d_ff_asyn.v";
`include "d_ff_asyn_en.v";
`include "two_ff_synchronizer.v";*/



//Gray to Binary

wire [(ADDRESS_SIZE): 0] w_bin;


gray_to_binary #(.N(ADDRESS_SIZE +1))
	w_gray_to_binary_conv (.gray(w_ptr),
			       .binary(w_bin));
			    

			     
	
			     

//Conditional incrementation

wire [(ADDRESS_SIZE): 0] w_bnext;

assign w_bnext = (w_en & (!w_full)) ? (w_bin + 1'b1) : w_bin;






//Binary to Gray

wire [(ADDRESS_SIZE): 0] w_gnext;

binary_to_gray #(.N(ADDRESS_SIZE +1))
	w_binary_to_gray_conv (.binary(w_bnext),
			       .gray(w_gnext));
			       
			       
			       
	
			       
	
//wptr generation


d_ff_async_en #(.SIZE(ADDRESS_SIZE +1))
	w_ptr_reg (.clk(w_clk),
		   .rst(!wrst_n),
		   .en(w_en & (!w_full)),
		   .d(w_gnext),
		   .q(w_ptr));






//Write address generation

wire w_msbnext ;
wire addr_msb;
wire [(ADDRESS_SIZE): 0] w_addr_g;

assign w_msbnext = ( w_gnext[(ADDRESS_SIZE)] ^ w_gnext[(ADDRESS_SIZE -1)] ) ;

d_ff_async #(.SIZE(1))
	w_addrmsb_reg (.clk(w_clk),
		   .rst(!wrst_n),
		   .d(w_msbnext),
		   .q(addr_msb));       
		   
			      
assign w_addr_g = {addr_msb , w_ptr[(ADDRESS_SIZE-2): 0]};

		       

gray_to_binary #(.N(ADDRESS_SIZE))
	w_addr_gray_to_binary (.gray(w_addr_g),
			       .binary(w_addr));
			    			       
			       
			       
	
			       
			       
			       
//Synchronisation of rptr to wclk

wire [(ADDRESS_SIZE): 0] wq2_rptr;

two_ff_synchronizer #(.SYNCHRONIZER_SIZE(ADDRESS_SIZE +1 ))
	sync_r2w (.clk(w_clk),
		  .rst_n(wrst_n),
		  .in(r_ptr),
		  .out(wq2_rptr)
		  );





//full signal generation

  
wire w_full_temp;

assign f1 = (!(wq2_rptr[ADDRESS_SIZE] == w_gnext[ADDRESS_SIZE]));
assign f2 = (!(wq2_rptr[ADDRESS_SIZE-1] == w_gnext[ADDRESS_SIZE-1]));
assign f3 = (wq2_rptr[(ADDRESS_SIZE-2) :0] == w_gnext[(ADDRESS_SIZE-2) :0]);


assign w_full_temp = (f1 & f2 & f3);

d_ff_async_en #(.SIZE(1))
	w_full_reg (.clk(w_clk),
		    .rst(!wrst_n),
		    .en(w_en),
		    .d(w_full_temp),
	            .q(w_full));	



/*
//Simulation

property full_flag_rise;
@(posedge w_clk) (f1 & f2 & f3) |=> w_full;
endproperty

  assert property (full_flag_rise)
    display ("full flag");
    else ("full flag didn't rise");
 

property w_en_fall;
@(posedge w_clk) w_full |=> (!w_en);
endproperty

assert property (w_en_fall) else $error("w_en didn't fall after full flag");
*/

endmodule
