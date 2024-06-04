module ABP_CSR_top_module (
clk,
rst_n,
addr,
sel,
en,
write,
slv_err,
ready,
wdata,
rdata,
intrpt
);

/*
`include "cs_registers.v"
`include "APB_comm.v"
*/

parameter ADDRESS_SIZE      = 32;
parameter REG_NUMBER        = 5;       //How many registers we have (assume all of them can be read)
parameter ADDR_BASE         = 4;
parameter BASE_BIT          = 8;
parameter WRITE_REG_NUMBER  = 3;       //How many registers we can write on
parameter REG_WIDTH         = 8;
parameter TYPE_DEFAULT      = 8'hAF;  //TYPE register default value
parameter RANDOM_DEFAULT    = 8'hAF;  //TYPE register default value


input                       clk;
input                       rst_n;
input [(ADDRESS_SIZE -1):0] addr;
input                       sel;
input                       en;
input                       write;
input [(REG_WIDTH-1) :0]    wdata;
input                       intrpt;

output [(REG_WIDTH-1) :0]   rdata;
output                      slv_err;
output                      ready;



wire [(WRITE_REG_NUMBER-1) :0] w_en_all;
wire [(REG_NUMBER-1) :0]       r_en_all;



APB_comm #(.ADDRESS_SIZE(ADDRESS_SIZE),
           .REG_NUMBER(REG_NUMBER),
           .ADDR_BASE(ADDR_BASE),
           .BASE_BIT(BASE_BIT),
           .WRITE_REG_NUMBER(WRITE_REG_NUMBER))
        APB(.clk(clk),
            .rst_n(rst_n),
            .addr(addr),
            .sel(sel),
            .en(en),
            .write(write),
            .slv_err(slv_err),
            .ready(ready),
            .w_en_all(w_en_all),
            .r_en_all(r_en_all)
            );



cs_registers #(.REG_WIDTH(REG_WIDTH),
               .TYPE_DEFAULT(TYPE_DEFAULT),
               .RANDOM_DEFAULT(RANDOM_DEFAULT),
               .WRITE_REG_NUMBER(WRITE_REG_NUMBER),
			   .REG_NUMBER(REG_NUMBER))
  registers(.clk(clk),
            .rst_n(rst_n),
            .sel(sel),
            .write(write),
            .w_en_all(w_en_all),
            .r_en_all(r_en_all),
            .wdata(wdata),
            .rdata(rdata),
            .intrpt(intrpt)
            );




endmodule
