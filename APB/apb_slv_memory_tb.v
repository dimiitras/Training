module apb_slv_memory_tb ();

parameter DATA_SIZE = 32;
parameter ADDR_SIZE = 5;

wire PCLK;
wire PRESETn;
wire [(ADDR_SIZE-1) :0]PADDR;
wire PSEL;
wire PENABLE; 
wire [(DATA_SIZE-1) :0] PWRITE;
wire [(DATA_SIZE-1) :0] PWDATA;
wire PSTROBE;


wire PREADY;
wire [(DATA_SIZE-1) :0] PRDATA;
wire PSLVERR;

apb_slv_memory_reg #(.DATA_SIZE(DATA_SIZE), .ADDR_SIZE(ADDR_SIZE))
			i1(PCLK,
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


//clock
initial begin 
PCLK= 1'b0;
forever #5 PCLK=~PCLK;
end

//reset
initial begin
 PRESETn = 1'b0;
 #10;
 PRESETn = 1'b1;
end

//enable
initial begin
PENABLE = 1'b1;
#730; 
PENABLE = 1'b0;
#325;
PENABLE = 1'b1;
end

endmodule
