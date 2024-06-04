module cs_registers (
clk,
rst_n,
write,
sel,
w_en_all,
r_en_all,
//strb,
wdata,
intrpt,
rdata
);

/*
`include "d_ff_async.v"
`include "d_ff_async_en.v"
*/

parameter REG_WIDTH         = 8;
parameter TYPE_DEFAULT      = 8'hAF;  //TYPE register default value
parameter RANDOM_DEFAULT    = 8'hAF;  //TYPE register default value

parameter WRITE_REG_NUMBER  = 3;
parameter REG_NUMBER        = 5;



input                             clk;
input                             rst_n;
input                             sel;
input                             write;
input [(WRITE_REG_NUMBER-1) :0]   w_en_all;
input [(REG_NUMBER-1) :0]         r_en_all;
//input [((REG_WIDTH/8)-1) :0]      strb;
input [(REG_WIDTH-1) :0]          wdata;
input                             intrpt;

output [(REG_WIDTH-1) :0]         rdata;



wire r_enable;
assign r_enable = (!write && sel);

d_ff_async_en #(.SIZE(REG_WIDTH),
             .RESET_VALUE(0))
    rdata_reg(.clk(clk),
              .rst(!rst_n),
              .en(!write && sel),  //otherwise the rdata reg reads the register of addr all the time, even when writing occurs 
              .d(rdata_temp),      //using only !write doesn't work, because write becomes zero in between the APB phases.
              .q(rdata));



//Register TYPE

wire [(REG_WIDTH-1) :0] type_out;

d_ff_async #(.SIZE(REG_WIDTH),
             .RESET_VALUE(TYPE_DEFAULT))
    type_reg(.clk(clk),
             .rst(!rst_n),
             .d(TYPE_DEFAULT),
             .q(type_out));
              
              

//Register RANDOM

reg [(REG_WIDTH-1) :0] random_in;
wire [(REG_WIDTH-1) :0] random_out;


d_ff_async_en #(.SIZE(REG_WIDTH),
             .RESET_VALUE(RANDOM_DEFAULT))
    random_reg(.clk(clk),
               .rst(!rst_n),
			   .en(w_en_all[0]),      //random_in changes immediately with wdata (along with sel) and then changes back to 
               .d(wdata),         //default value. Without w_en_all[0], random_out would change back at default after the access phase.
               .q(random_out));




//Interrupt

//Register INT_CLR

reg int_clr_in;
wire int_clr_out;


d_ff_async_en #(.SIZE(1),
             .RESET_VALUE(0))
    int_clr_reg(.clk(clk),
                .rst(!rst_n | !w_en_all[1]),   //int_clr register must self-clear
                .en(w_en_all[1]),
                .d(wdata[REG_WIDTH-1]),
                .q(int_clr_out));





//Register INT_STATUS

wire int_status_out;
wire mask_out;
wire int_status_reset;

assign int_status_reset = (int_clr_out | !rst_n);

d_ff_async_en #(.SIZE(1),
             .RESET_VALUE(0))
    int_status_reg(.clk(clk),
              .rst(int_status_reset),
              .en(intrpt),     //having as input (intrpt & mask_out) didin't work because as soon as one of those become zero
              .d(mask_out),    //int_status reg would go back to 0. But, it should be cleaned only by int_clr reg.
              .q(int_status_out));




//Register MASK

reg mask_in;
wire mask_out_1;

d_ff_async_en #(.SIZE(1),
             .RESET_VALUE(0))
    mask_reg(.clk(clk),
             .rst(!rst_n),
		     .en(w_en_all[2]),   //Without w_en_all[2], mask_out would change back at default after the access phase.
             .d(wdata[0]),
             .q(mask_out));





//MUX for writing in registers


always@(*)begin
    case(1'b1)
        w_en_all[0]:  random_in  = wdata;
        w_en_all[1]:  int_clr_in = wdata[(REG_WIDTH-1)];
        w_en_all[2]:  mask_in    = wdata[0];
        default: begin
            random_in  = RANDOM_DEFAULT;
            int_clr_in = {REG_WIDTH{1'b0}};                //default case : int_clr register self clears 
            mask_in    = {REG_WIDTH{1'b0}};
        end
    endcase
end





//DEMUX for reading from registers

reg [(REG_WIDTH-1) :0] rdata_temp;

always@(*)begin
    case(1'b1)
        r_en_all[0]:  rdata_temp                = type_out;
        r_en_all[1]:  rdata_temp                = random_out;
        r_en_all[2]:  rdata_temp                = int_clr_out;
        r_en_all[3]:  rdata_temp                = int_status_out;
        r_en_all[4]:  rdata_temp                = mask_out;
        default: begin
            rdata_temp  = {REG_WIDTH{1'b0}} ;             
        end
    endcase
end




/*
//Assertions
 
property interrupt_check_1;
  @(posedge clk) (intrpt && mask_out) |=> int_status_out; 
  endproperty

assert property(interrupt_check_1) $display ("interrupt asserted");
    else $error("interrupt fail");
  
property interrupt_check_2;
  @(posedge clk) int_clr_in |=> (!int_status_out);
endproperty

  assert property(interrupt_check_2) $display ("interrupt cleared");
    else $error("interrupt clear fail");
    

*/

endmodule
