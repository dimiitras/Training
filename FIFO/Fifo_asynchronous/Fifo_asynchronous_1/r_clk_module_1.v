module r_clk_module_1 (
r_clk,
r_en,
rrst_n,
r_ptr,
w_ptr,
r_empty,
r_addr);


parameter ADDRESS_SIZE;


input r_clk;
input r_en;
input rrst_n;
input [(ADDRESS_SIZE): 0] w_ptr;

output r_empty;
output [(ADDRESS_SIZE): 0] r_ptr;
output [(ADDRESS_SIZE-1): 0] r_addr;

/*`include "d_ff_asyn.v";
`include "d_ff_asyn_en.v";
`include "two_ff_synchronizer.v";
*/


//Gray to Binary

wire [(ADDRESS_SIZE): 0] r_bin;

gray_to_binary #(.N(ADDRESS_SIZE +1))
	r_gray_to_binary_conv (.gray(r_ptr),
			     .binary(r_bin));
			     
		     
	
			     

//Conditional incrementation

wire [(ADDRESS_SIZE): 0] r_bnext;
wire r_en_dly;


d_ff_async #(.SIZE(1))
	r_en_reg (.clk(r_clk),
		   .rst(!rrst_n),
		   .d(r_en),
		   .q(r_en_dly));
		   

assign r_bnext = (r_en_dly & (!r_empty)) ? (r_bin + 1'b1) : r_bin;





//Binary to Gray

wire [(ADDRESS_SIZE): 0] r_gnext;

binary_to_gray # (.N(ADDRESS_SIZE +1))
	r_binary_to_gray_conv (.binary(r_bnext),
			       .gray(r_gnext));
			       
			       
			       
	
			       
	
//rptr generation


d_ff_async_en #(.SIZE(ADDRESS_SIZE +1))
	w_ptr_reg (.clk(r_clk),
		   .rst(!rrst_n),
		   .en(r_en & (!r_empty)),
		   .d(r_gnext),
		   .q(r_ptr));






//Read address generation

wire r_msbnext;
wire addr_msb;
wire [(ADDRESS_SIZE): 0] r_addr_g;

assign r_msbnext = ( r_gnext[(ADDRESS_SIZE)] ^ r_gnext[(ADDRESS_SIZE -1)] ) ;

d_ff_async #(.SIZE(1))
	r_addrmsb_reg (.clk(r_clk),
		   .rst(!rrst_n),
		   .d(r_msbnext),
		   .q(addr_msb)
		   );       
			      
			      
assign r_addr_g = {addr_msb , r_ptr[(ADDRESS_SIZE-2): 0]};

		       

gray_to_binary #(.N(ADDRESS_SIZE))
	r_addr_gray_to_binary (.gray(r_addr_g),
			       .binary(r_addr));
			    			    
			       
			       
			       
//Synchronisation of wptr to rclk

wire [(ADDRESS_SIZE): 0] rq2_wptr;

two_ff_synchronizer #(.SYNCHRONIZER_SIZE(ADDRESS_SIZE +1 ))
	sync_w2r (.clk(r_clk),
		  .rst_n(rrst_n),
		  .in(w_ptr),
		  .out(rq2_wptr)
		  );



//empty signal generation

wire r_empty_temp;

assign r_empty_temp = (r_gnext == rq2_wptr);


d_ff_async #(.SIZE(1))
	r_empty_reg (.clk(r_clk),
		     .rst(!rrst_n),
		     .d(r_empty_temp),
		     .q(r_empty));
			   

/*
//Simulation

  property empty_flag_rise;
@(posedge r_clk) disable iff(!rrst_n) (r_gnext == rq2_wptr) |=> r_empty;
endproperty

assert property (empty_flag_rise) else $error("empty flag didn't rise immediately after last read");

  
property r_en_fall;
@(posedge r_clk) r_empty |=> (!r_en);
endproperty

  assert property (r_en_fall) else $error("r_en didn't fall after empty flag");

*/

endmodule
