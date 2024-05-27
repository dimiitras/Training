module r_clk_module (
r_clk,
r_en,
rrst_n,
r_ptr,
w_ptr,
r_empty,
r_almost_empty,
r_addr);



parameter ADDRESS_SIZE;


input r_clk;
input r_en;
input rrst_n;
input [(ADDRESS_SIZE): 0] w_ptr;


output reg r_empty;
output r_almost_empty;
output [(ADDRESS_SIZE): 0] r_ptr;
output [(ADDRESS_SIZE-1): 0] r_addr;


//For EDA PLAYGROUND :
/*`include "d_ff_asyn.v";
`include "d_ff_asyn_en.v";
`include "two_ff_synchronizer.v";
*/


//Conditional incrementation

wire [(ADDRESS_SIZE): 0] r_bin;
wire [(ADDRESS_SIZE): 0] r_bnext;

wire r_en_dly;



d_ff_async #(.SIZE(1))
	r_enable_reg (.clk(r_clk),
		      .rst(!rrst_n),
		      .d(r_en),
		      .q(r_en_dly));
		      




assign r_bnext = (r_en_dly & (!r_empty)) ? (r_bin + 1'b1) : r_bin ;    
									//delay control signal (r_en_dly), so that r_bnext 
									//doesn't increment before the r_clk posedge 
									//and r_addr increments correctly.




//Binary register (saves the next binary value for read address)

d_ff_async #(.SIZE(ADDRESS_SIZE+1))
	r_binary_reg (.clk(r_clk),
		      .rst(!rrst_n),
		      .d(r_bnext),
		      .q(r_bin));
		      
		      
assign r_addr = r_bin[(ADDRESS_SIZE-1):0];	      		      
		      


		      
		      
//Binary to Gray logic

wire [(ADDRESS_SIZE): 0] r_gnext;

binary_to_gray #(.N(ADDRESS_SIZE +1))
	r_binary_to_gray_conv (.binary(r_bnext),
			       .gray(r_gnext));
			       





//Gray register

d_ff_async #(.SIZE(ADDRESS_SIZE+1))
	r_gray_reg (.clk(r_clk),
		    .rst(!rrst_n),
		    .d(r_gnext),
		    .q(r_ptr));
		      		       
			       
			     
			       
	
			       		       
			       
			       
//Synchronisation of wptr to rclk

wire [(ADDRESS_SIZE): 0] rq2_wptr;



two_ff_synchronizer #(.SYNCHRONIZER_SIZE(ADDRESS_SIZE+1))
	sync_w2r (.clk(r_clk),
              .rst_n(rrst_n),
		  .in(w_ptr),
		  .out(rq2_wptr)
		  );






//empty signal generation

wire r_empty_temp;


assign r_empty_temp = (r_gnext == rq2_wptr);	     //or r_g2next

//If I remove the r_empty register, then the flag begins with 0 (doesn't reset to 1)

		     
always@(posedge r_clk) begin
	if(!rrst_n) r_empty <= 1'b1;	//reset r_empty to 1
	else r_empty <= r_empty_temp;   
end  





			   
//almost empty flag (since the empty flag rises one clock cycle late)

wire [(ADDRESS_SIZE): 0] r_bnext_less;
wire [(ADDRESS_SIZE): 0] r_gnext_less;
assign r_bnext_less = r_bnext + 1'b1;

binary_to_gray #(.N(ADDRESS_SIZE +1))
	rbnext_less_conv (.binary(r_bnext_less),
			  .gray(r_gnext_less));
			       

assign r_almost_empty = ((r_gnext_less == rq2_wptr) & r_en);






/*
//Assertions

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
