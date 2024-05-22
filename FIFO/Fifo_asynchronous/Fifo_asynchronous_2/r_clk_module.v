module r_clk_module (
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

output reg r_empty;
output [(ADDRESS_SIZE): 0] r_ptr;
output [(ADDRESS_SIZE-1): 0] r_addr;





//Conditional incrementation

wire [(ADDRESS_SIZE): 0] r_bin;
wire [(ADDRESS_SIZE): 0] r_bnext;

wire r_en_dly;



d_ff_async #(.SIZE(1))
	r_enable_reg (.clk(r_clk),
		      .rst(!rrst_n),
		      .d(r_en),
		      .q(r_en_dly));
		      




assign r_bnext = (r_en_dly & (!r_empty)) ? (r_bin + 1'b1) : r_bin ;    /*delay control signal (r_en_dly), so that r_bnext 
									doesn't increment before the r_clk posedge 
									and r_addr increments correctly.*/



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
wire [(ADDRESS_SIZE): 0] r_gnext_less;
wire [(ADDRESS_SIZE): 0] r_bnext_less;

assign r_bnext_less = (r_bnext - 1'b1);


binary_to_gray #(.N(ADDRESS_SIZE +1))
	r_bnext_less_conv (.binary(r_bnext_less),
			   .gray(r_gnext_less));


assign r_empty_temp = (r_gnext_less == rq2_wptr);		       

		     
always@(posedge r_clk) begin
	if(!rrst_n) r_empty <= 1'b1;	/*reset r_empty to 1*/
	else r_empty <= r_empty_temp;   
end  
			   



endmodule
