module w_clk_module (
w_clk,
w_en,
wrst_n,
r_ptr,
w_ptr,
w_full,
w_addr);

parameter MEMORY_DEPTH;


input w_clk;
input w_en;
input wrst_n;
input [(MEMORY_DEPTH): 0] r_ptr;

output w_full;
output [(MEMORY_DEPTH): 0] w_ptr;
output [(MEMORY_DEPTH-1): 0] w_addr;





//Gray to Binary

wire [(MEMORY_DEPTH): 0] wbin;

gray_to_binary #(.N(MEMORY_DEPTH +1))
	w_gray_to_binary_conv (.gray(w_ptr),
			     .binary(bin));
			     
	
			     
	
			     

//Conditional incrementation

wire [(MEMORY_DEPTH): 0] w_bnext;

assign w_bnext = (w_en & (!w_full)) ? (wbin + 1'b1) : wbin;






//Binary to Gray

wire [(MEMORY_DEPTH): 0] w_gnext;

binary_to_gray # (.N(MEMORY_DEPTH +1))
	w_binary_to_gray_conv (.binary(w_bnext),
			       .gray(w_gnext));
			       
			       
			       
	
			       
	
//wptr generation


d_ff_async #(SIZE(MEMORY_DEPTH +1))
	w_ptr_reg (.clk(w_clk),
		   .rst(!wrst_n),
		   .d(w_gnext),
		   .q(w_ptr));






//Write address generation

wire w_msbnext ;
wire addr_msb;

assign w_msbnext = ( w_gnext[(MEMORY_DEPTH)] ^ w_gnext[(MEMORY_DEPTH -1)] ) ;

d_ff_async #(SIZE(1))
	w_addr_reg (.clk(w_clk),
		   .rst(!wrst_n),
		   .d(w_msbnext),
		   .q(addr_msb));       
			      
assign w_addr = {addr_msb , w_ptr[(MEMORY_DEPTH-2): 0]};			       
			       
			       
			       
	
			       
			       
			       
//Synchronisation of rptr to wclk

wire [(MEMORY_DEPTH): 0] wq2_rptr;
2
2_ff_synchronizer #(.SYNCHRONIZER_SIZE(MEMORY_DEPTH +1 ))
	sync_r2w (.clk(w_clk),
		  .rst_n(wrst_n),
		  .in(r_ptr),
		  .out(wq2_rptr)
		  );



//full signal generation

  
wire f1;
wire f2;
wire f3;

assign f1 = (!(wq2_rptr[MEMORY_DEPTH] == w_gnext[MEMORY_DEPTH]));
assign f2 = (!(wq2_rptr[MEMORY_DEPTH-1] == w_gnext[MEMORY_DEPTH-1]));
assign f3 = (wq2_rptr[(MEMORY_DEPTH-2) :0] == w_gnext[(MEMORY_DEPTH-2) :0]);


assign wfull = (f1 & f2 & f3);





endmodule
