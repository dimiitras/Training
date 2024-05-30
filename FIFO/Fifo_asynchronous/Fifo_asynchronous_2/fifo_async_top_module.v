module fifo_async_top_module (
w_clk,
w_en,
wrst_n,
r_clk,
r_en,
rrst_n,
wdata,

r_empty,
w_full,
rdata);

/*
REAL_MEM =1 & READ_REG =1 -> Memory array and 1 ff at rdata. No ff at r_en and only one ff at r_empty and it rises on time
REAL_MEM =1 & READ_REG =0 -> Memory array and no ff at rdata. One ff at r_en and only one ff at r_empty and it rises one cycle later

!REAL_MEM =0 & READ_REG =0!-> Memory IP (with one clock latency at port B -> for read) -> no need for ff at rdata                     
							 no ff at rdata -> One ff at r_en and only one ff at r_empty and it rises on time         			
							 
REAL_MEM =0 & READ_REG =1 -> Memory IP and 1 ff at rdata. No ff at r_en and one extra ff at r_empty (otherwise it rises one cycle too early).
*/

parameter MEMORY_DEPTH = 4;
parameter MEMORY_WIDTH = 4;

parameter ADDRESS_SIZE = 2;


parameter REAL_MEM = 1;   // 0 -> Memory IP , 1 -> memory array
parameter READ_REG = 1;	  // 0 -> no ff at read output, 1 -> rdata goes through a ff


input w_clk;
input w_en;
input wrst_n;
input r_clk;
input r_en;
input rrst_n;
input [(MEMORY_WIDTH-1): 0] wdata;

output r_empty;
output w_full;
output [(MEMORY_WIDTH-1): 0] rdata;


wire [(ADDRESS_SIZE): 0] r_ptr;
wire [(ADDRESS_SIZE): 0] w_ptr;

wire [(ADDRESS_SIZE-1): 0] w_addr;
wire [(ADDRESS_SIZE-1): 0] r_addr;


//For EDA PLAYGROUND :
/*`include "w_clk_module.v";
`include "r_clk_module.v";
*/



w_clk_module #(.ADDRESS_SIZE(ADDRESS_SIZE))
	write_clk_block (.w_clk(w_clk),
			.w_en(w_en),
			.wrst_n(wrst_n),
			.r_ptr(r_ptr),
			.w_ptr(w_ptr),
			.w_full(w_full),
			.w_addr(w_addr));




r_clk_module #(.ADDRESS_SIZE(ADDRESS_SIZE),
			   .READ_REG(READ_REG))
	read_clk_block (.r_clk(r_clk),
			.r_en(r_en),
			.rrst_n(rrst_n),
			.w_ptr(w_ptr),
			.r_ptr(r_ptr),
			.r_empty(r_empty),
			.r_addr(r_addr));






// Memory

wire [(MEMORY_WIDTH-1): 0] rdata_temp;
wire cw_en;
assign cw_en = (w_en & (!w_full));


generate

	if(REAL_MEM == 0) begin
		blk_mem_gen_1 				//Memory IP 
			memory_ip(.clka(w_clk), 
					  .ena(1'b1),
					  .wea(cw_en),
					  .addra(w_addr),
					  .dina(wdata),
					  .clkb(r_clk), 
					  .enb(1'b1),
					  .addrb(r_addr), 
					  .doutb(rdata_temp));
		end
	else if (REAL_MEM == 1) begin
		reg [(MEMORY_WIDTH -1) :0] memory [(MEMORY_DEPTH -1) :0];
		assign rdata_temp = memory[r_addr];
		
		always@(posedge w_clk) begin
			if(cw_en) 
				memory[w_addr] <= wdata;		
			end
		end

endgenerate



generate
	if(READ_REG == 0) begin 			//read happens combinationally
		assign rdata = rdata_temp;
		end
	else if (READ_REG ==1) begin  
		d_ff_async_en #(.SIZE(MEMORY_WIDTH))
			r_data_reg (.clk(r_clk),
						.rst(!rrst_n),
						.en(r_en),
						.d(rdata_temp),
						.q(rdata));
		end

endgenerate



endmodule
