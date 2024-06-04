module APB_comm (
clk,
rst_n,
addr,
sel,
en,
write,
slv_err,
ready,
w_en_all,
r_en_all
);

/*
`include "d_ff_async.v"
`include "d_ff_async_en.v"

*/

parameter ADDRESS_SIZE      = 32;
parameter ADDR_BASE         = 4; 
parameter BASE_BIT          = 8;       //The position of the base (eg. 32 bit address -> 32'h0000_0400 -> BASE_BIT = 8 (up to 11)).
parameter REG_NUMBER        = 5;       //How many registers we have (assume all of them can be read).

parameter WRITE_REG_NUMBER = 3;       //How many registers we can write on.


input                              clk;
input                              rst_n;
input [(ADDRESS_SIZE -1):0]        addr;
input                              sel;
input                              en;
input                              write;

output                             slv_err;
output                             ready;
output [(WRITE_REG_NUMBER-1) :0]   w_en_all;
output [(REG_NUMBER-1) :0]         r_en_all;




//Register addresses as wires (not parameters) so they can be function inputs

wire [(BASE_BIT-1):0] REG_TYPE;
wire [(BASE_BIT-1):0] REG_RANDOM;
wire [(BASE_BIT-1):0] REG_INT_CLEAR;
wire [(BASE_BIT-1):0] REG_INT_STATUS;
wire [(BASE_BIT-1):0] REG_MASK;


assign REG_TYPE       = 8'h00;
assign REG_RANDOM     = 8'h01;
assign REG_INT_CLEAR  = 8'h02;
assign REG_INT_STATUS = 8'h03;
assign REG_MASK       = 8'h04;



//For RO registers 

function err_or_w_en;

    input [(BASE_BIT-1):0]      address;
    input                       write;
    input [(BASE_BIT-1):0]      compare;
    reg                         eq;
begin

    eq = (address == compare);
    err_or_w_en = (eq && write);
end
endfunction



//For RW registers 

function r_en ;

    input [(BASE_BIT-1):0]      address;
    input                       write;
    input [(BASE_BIT-1):0]      compare;
    reg                         eq;
begin   

    eq = (address == compare);
    r_en = (eq && !write);
end
endfunction




//Compute (based on address and write inputs) errors (write request on a RO reg) 
//or write/read enable signals for the requested register

wire err_0;
wire err_3; 

wire w_1;
wire w_2;
wire w_4;

wire r_0;
wire r_1;
wire r_2;
wire r_3;
wire r_4;



//wire [7:0] addr_2;                     //for simulation only
//assign addr_2 = addr[(BASE_BIT-1) :0];

assign err_0 = err_or_w_en(addr[(BASE_BIT-1) :0], write, REG_TYPE);
assign err_3 = err_or_w_en(addr[(BASE_BIT-1) :0], write, REG_INT_STATUS);


//Control signal for writing in registers -> w_enable all (one-hot -> no MUX -> wdata as input and w_en_all[] as enable)
                                                        //(MUX -> extra logic at data path)
assign w_1 = err_or_w_en(addr[(BASE_BIT-1) :0], write, REG_RANDOM);
assign w_2 = err_or_w_en(addr[(BASE_BIT-1) :0], write, REG_INT_CLEAR);
assign w_4 = err_or_w_en(addr[(BASE_BIT-1) :0], write, REG_MASK);

assign w_en_all = {{w_4}, {w_2}, {w_1}};


//Control signal for reading from registers -> r_enable all (one-hot for read data MUX)

assign r_0 = r_en(addr[(BASE_BIT-1) :0], write, REG_TYPE);
assign r_1 = r_en(addr[(BASE_BIT-1) :0], write, REG_RANDOM);
assign r_2 = r_en(addr[(BASE_BIT-1) :0], write, REG_INT_CLEAR);
assign r_3 = r_en(addr[(BASE_BIT-1) :0], write, REG_INT_STATUS);
assign r_4 = r_en(addr[(BASE_BIT-1) :0], write, REG_MASK);
            
assign r_en_all = {{r_4}, {r_3}, {r_2}, {r_1}, {r_0}};



//Max address error

wire err_max;

assign err_max = (addr[(ADDRESS_SIZE-1)] > REG_NUMBER);




//Wrong Base address error

wire err_base;

assign err_base = (addr[BASE_BIT+:4] !== ADDR_BASE);

wire [3:0] addr_1;
assign addr_1 = addr[BASE_BIT+:4];




//Output slv_err

wire slv_err_temp;

assign slv_err_temp = (err_0 | err_3 | err_max |err_base);


d_ff_async#(.SIZE(1),
             .RESET_VALUE(0))
    slv_err_reg(.clk(clk),
                .rst(!rst_n),
                .d(slv_err_temp),
                .q(slv_err));



//Output ready



wire ready_temp;
        
d_ff_async_en #(.SIZE(1),
		        .RESET_VALUE(0))
	 d_ready(.clk(clk),
	          .rst(!rst_n),
	          .en(sel),
	          .d(!en),
              .q(ready));
	             





endmodule
