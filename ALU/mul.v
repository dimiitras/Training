module mul(
clk,
rst_n,
a_in,
b_in,
valid_f_in,
ready_f_out,
valid_f_out,
result,
ready_f_in);

parameter DATA_SIZE;

input clk;
input rst_n;
input [(DATA_SIZE-1):0] a_in;
input [(DATA_SIZE-1):0] b_in;
input valid_f_in;
input ready_f_out;

output ready_f_in;
output valid_f_out;
output [((2*DATA_SIZE)-1):0] result;



//Control signasls

assign ready_f_in = (done & ready_f_out);  //done -> the previous multiplication is over

wire start;
assign start = (ready_f_in & valid_f_in);




//Reg A -> holds multiplicant 

wire [(DATA_SIZE-1):0] mul_c;

d_ff_async_en #(.SIZE(DATA_SIZE),
                .RESET_VALUE(0))
    mul_reg_A(.clk(clk),
              .rst_n(rst_n),
              .en(),
              .d(a_in),
              .q(mul_c));



//Reg B -> shift register (multiplier) 


wire [(DATA_SIZE-1):0] reg_b_in;
wire [(DATA_SIZE-1):0] reg_b_out; //res[15:0]

always@(*)begin
    if() 
      reg_b_in = b_in;
    else begin
      reg_b_in = {reg_b_out[DATA_SIZE-2):0],reg_c_out};   
    end
end
 

d_ff_async_en #(.SIZE(DATA_SIZE),
                 .RESET_VALUE(0))
       mul_reg_B(.clk(clk),
                .rst_n(rst_n),
                 .en(),
                 .d(reg_b_in),
                 .q(reg_b_out)); //res[15:0]


//Adder

wire [(DATA_SIZE-1):0] add_out;
wire carry_in;
wire carry_out;

//MUX for adding based on reg_b_out lsb

always@(*)begin
    if(reg_b_out[0] == 1)
        add_in = a_in;
    else 
        add_in = {DATA_SIZE{1'b0}};
end


add_sub #(.DATA_SIZE(DATA_SIZE))
     mul_adder(.a1(add_in),
               .b(reg_c_out),
               .cin(0),
               .operation(1),
               .s(add_out),
               .cout(carry_in)
                );


d_ff_async_en #(.SIZE(1'b1),
                 .RESET_VALUE(0))
       carry_reg(.clk(clk),
                .rst_n(rst_n),
                 .en(),
                 .d(carry_in),
                 .q(carry_out)); 



//Reg C -> shift or add a_in based on reg_b_out lsb

wire [(DATA_SIZE-1):0] reg_c_in;

always@(*)begin
    if() 
      reg_c_in = add_out;
    else begin
      reg_c_in = {reg_c_out[DATA_SIZE-2):0], carry_out};   
    end
end
 

d_ff_async_en #(.SIZE(DATA_SIZE),
                 .RESET_VALUE(0))
       mul_reg_B(.clk(clk),
                .rst_n(rst_n),
                 .en(),
                 .d(reg_b_in),
                 .q(reg_b_out)); //res[15:0]









 

endmodule
