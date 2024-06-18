module rca_1_bit_reg (
clk,
rst_n,
add_1,
add_2,
c_in
s,
c_out);


input clk;
input rst_n;
input add_1;
input add_2;

output s;
output c_out;


//1-bit Full Adder

assign c_out_temp = (((add_1^add_2) & c_in) | (add_1 & add_2));

assign s = (c_in ^ (add_1^add_2));


//1-bit register for propagating the carry


d_ff_async #(.SIZE(1),
             .RESET_VALUE(1))
      fa_reg(.clk(clk),
                 .rst(!rst_n),
                 .d(c_out_temp),
                 .q(c_out)); 


endmodule
