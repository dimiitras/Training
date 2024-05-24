module apb_slv_memory_reg (
PCLK,
PRESETn,
PADDR,
PSEL,
PENABLE, 
PWRITE,
PWDATA,
PSTROBE,
PREADY,
PRDATA,
PSLVERR);

parameter DATA_SIZE = 32;
parameter ADDR_SIZE = 6;

input PCLK;
input PRESETn;
input [(ADDR_SIZE-1) :0]PADDR;
input PSEL;
input PENABLE; 
input  PWRITE;
input [(DATA_SIZE-1) :0] PWDATA;
input [((DATA_SIZE/8)-1) :0] PSTROBE;


output  PREADY;
//(* dont_touch = "yes" *) output  [(DATA_SIZE-1) :0] PRDATA;
output  [(DATA_SIZE-1) :0] PRDATA;
output  PSLVERR;


reg [31:0] memory [31:0] ;

wire  SLVERR_temp, write_en, addr_max;
wire [(DATA_SIZE-1) :0] PRDATA_temp;
wire [(DATA_SIZE-1) :0] memory_temp;
wire R_1;

genvar i;


//output assignments

assign addr_max = (PADDR >= {6'd32} );

 

//Masking

assign write_en = (!addr_max & PREADY & PWRITE);

always@(posedge PCLK) begin
	if(write_en) begin
		memory[PADDR] <= memory_temp;
	end
end

for(i=0; i<4; i = i+1) begin
	assign memory_temp[(i*8)+:8] = (PSTROBE[i]) ? PWDATA[(i*8)+:8] : memory[PADDR][(i*8)+:8];
end


//Outputs

//SLVERR

assign SLVERR_temp = (addr_max  & R_1 & (~PENABLE));

d_ff #(.D_SIZE(1))
	d_slv_err (
	.clk(PCLK),
	.resetn(PRESETn),
	.d(SLVERR_temp),
	.q(PSLVERR));
	
	
//PRDATA

assign PRDATA_en = !addr_max & R_1 & !PWRITE;
assign PRDATA_temp = memory[PADDR];

/*(* DONT_TOUCH = "yes" *)*/ d_ff_en #(.D_SIZE(DATA_SIZE))
	d_rdata (
	.clk(PCLK),
	.resetn(PRESETn),
	.en(PRDATA_en),
	.d(PRDATA_temp),
	.q(PRDATA));
	


//PREADY


d_ff_en #(.D_SIZE(1))
	d_ready1(
	.clk(PCLK),
	.resetn(PRESETn),
	.en(PSEL),
	.d(!PENABLE),
	.q(R_1));
	
d_ff_en #(.D_SIZE(1))
	d_ready2(
	.clk(PCLK),
	.resetn(PRESETn),
	.en(PSEL),
	.d(R_1),
	.q(PREADY));
	

//Assertions

  
property enable;
@(posedge PCLK) PSEL |=> (PENABLE);
endproperty

assert property (enable) else $error("enable error");

property ready;
@(posedge PCLK) PENABLE |-> (PREADY);
endproperty

assert property (ready) else $error("ready error");


endmodule
