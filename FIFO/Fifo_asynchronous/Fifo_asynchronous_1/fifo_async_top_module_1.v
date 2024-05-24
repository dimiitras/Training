module fifo_async_top_module_1 (
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

parameter MEMORY_DEPTH;
parameter MEMORY_WIDTH;


parameter ADDRESS_SIZE;


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



`include "w_clk_module.v";
`include "r_clk_module.v";



w_clk_module_1 #(.ADDRESS_SIZE(ADDRESS_SIZE))
	write_clk_block (.w_clk(w_clk),
			.w_en(w_en),
			.wrst_n(wrst_n),
			.r_ptr(r_ptr),
			.w_ptr(w_ptr),
			.w_full(w_full),
			.w_addr(w_addr));



r_clk_module_1 #(.ADDRESS_SIZE(ADDRESS_SIZE))
	read_clk_block (.r_clk(r_clk),
			.r_en(r_en),
			.rrst_n(rrst_n),
			.w_ptr(w_ptr),
			.r_ptr(r_ptr),
			.r_empty(r_empty),
			.r_addr(r_addr));






//Memory

reg [(MEMORY_WIDTH -1) :0] memory [(MEMORY_DEPTH -1) :0];






//Write

wire cw_en ;

assign cw_en = (w_en & (!w_full));

always@(posedge w_clk) begin
	if(cw_en) 
		memory[w_addr] <= wdata;		
	
end






//Read

assign rdata = memory[r_addr];




endmodule
