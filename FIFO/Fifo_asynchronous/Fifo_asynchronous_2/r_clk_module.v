module r_clk_module (
r_clk,
r_en,
rrst_n,
r_ptr,
w_ptr,
r_empty,
r_addr);



parameter ADDRESS_SIZE = 1;

parameter REAL_MEM = 0;
parameter READ_REG = 0;

input r_clk;
input r_en;
input rrst_n;
(* ASYNC_REG = "TRUE" *)input [(ADDRESS_SIZE): 0] w_ptr;


output r_empty;
output [(ADDRESS_SIZE): 0] r_ptr;
output [(ADDRESS_SIZE-1): 0] r_addr;


//For EDA PLAYGROUND :
/*`include "d_ff_asyn.v";
`include "d_ff_asyn_en.v";
`include "two_ff_synchronizer.v";
*/




//v2 => Put mux after binary register (smaller critical path)

//Binary register (v2)

wire [(ADDRESS_SIZE): 0] r_bin;
wire [(ADDRESS_SIZE): 0] r_bnext;


d_ff_async #(.SIZE(ADDRESS_SIZE+1))
	r_binary_reg (.clk(r_clk),
		      .rst(!rrst_n),
		      .d(r_bnext),
		      .q(r_bin));		


assign r_addr = r_bin[(ADDRESS_SIZE-1):0];	      		      



//Conditional incrementation (v2)

								
wire r_en_temp;    //if read happens combinationally, r_en needs to go through a register		
wire r_empty_1;
	   
	       		       
assign r_bnext = (r_en_temp & (!r_empty_1)) ? (r_bin + 1'b1) : r_bin ;    			      




//Binary to Gray logic

wire [(ADDRESS_SIZE): 0] r_gnext;

binary_to_gray #(.N(ADDRESS_SIZE +1))
	r_binary_to_gray_conv (.binary(r_bnext),
			       .gray(r_gnext));
			       


			       		       
//Synchronisation of wptr to rclk

wire [(ADDRESS_SIZE): 0] rq2_wptr;

two_ff_synchronizer #(.SYNCHRONIZER_SIZE(ADDRESS_SIZE+1))
        sync_w2r (.clk(r_clk),
                  .rst_n(rrst_n),
				  .in(w_ptr),
				  .out(rq2_wptr)
		  );

	      
		    

//Gray register

d_ff_async #(.SIZE(ADDRESS_SIZE+1))
	r_gray_reg (.clk(r_clk),
		    .rst(!rrst_n),
		    .d(r_gnext),
		    .q(r_ptr));
		      		       
			       
			     
			  
			  

//empty signal generation

wire r_empty_temp;

assign r_empty_temp = (r_gnext == rq2_wptr);	  

    

d_ff_async_r1 #(.SIZE(1))
			r_empty_1_reg (.clk(r_clk),
						 .rst(!rrst_n),
						 .d(r_empty_temp),
						 .q(r_empty_1));



generate 
	if((REAL_MEM == 0) && (READ_REG == 1)) begin
		d_ff_async #(.SIZE(1))
			r_empty_reg (.clk(r_clk),
						 .rst(!rrst_n),
						 .d(r_empty_1),
						 .q(r_empty));
			
	end
	else 
	begin
		assign r_empty = r_empty_1;
	end

endgenerate



//Read / r_en

generate
	if(READ_REG == 0) begin
		wire r_en_dly;                               //delay control signal (r_en_dly), so that r_bnext 
		d_ff_async #(.SIZE(1))						//doesn't increment before the r_clk posedge 
			r_enable_reg (.clk(r_clk),      	   //and r_addr increments correctly.	    
					.rst(!rrst_n),
					.d(r_en),
					.q(r_en_dly));
		assign r_en_temp = r_en_dly;
	end
	else if(READ_REG == 1) begin
		assign r_en_temp = r_en;

	end

endgenerate



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
