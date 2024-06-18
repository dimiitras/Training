module rc_adder(
clk,
rst_n,
add_1,
add_2,
c_in,
a_valid_f_data,
a_valid_f_data,
a_ready_f_res,
a_valid_f_res,
a_ready_f_data,
s,
c_out);

parameter DATA_SIZE;


input clk;
input rst_n;
input [(DATA_SIZE-1) :0] add_1;
input [(DATA_SIZE-1) :0] add_2;
input c_in;

input a_valid_f_data;
input a_ready_f_res;

output a_valid_f_res;
output a_ready_f_data;

output [(DATA_SIZE-1) :0] s;
output c_out;



//Signals between adder and the FIFOs 




//Registers where valid data will be loaded at the beginning of the operation

wire [(DATA_SIZE-1) :0] v_add_1;
wire [(DATA_SIZE-1) :0] v_add_2;

d_ff_async_en #(.SIZE(DATA_SIZE),
             .RESET_VALUE{DATA_SIZE{1'b0}}))
      add_1_reg(.clk(clk),
                 .rst(!rst_n),
                 .en(),
                 .d(add_1),
                 .q(v_add_1));

d_ff_async_en #(.SIZE(DATA_SIZE),
             .RESET_VALUE{DATA_SIZE{1'b0}}))
      add_2_reg(.clk(clk),
                 .rst(!rst_n),
                 .en(),
                 .d(add_2),
                 .q(v_add_2));  



//DATA_SIZE bit rc_adder 

wire [(DATA_SIZE) :0] c;
assign c[0] = c_in;
assign c[DATA_SIZE] = c_out;

genvar i;
generate

    for(i =0; i <= DATA_SIZE; i = i +1 )begin
        rca_1_bit_reg
            fa_reg_1_bit(.clk(clk),
                         .rst_n(rst_n),
                         .add_1(add_1[i]),
                         .add_2(add_2[i]),
                         .c_in(c[i]),
                         .s(s[i]),
                         .c_out(c[i+1]));
    end



endgenerate



                  




endmodule
