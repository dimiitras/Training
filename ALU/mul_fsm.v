module mul_fsm(
clk,
rst_n,
a_in,
b_in,
valid_f_data,
ready_f_res,
valid_f_res,
result,
ready_f_data);

parameter DATA_SIZE;
parameter COUNTER_SIZE = ($clog2(DATA_SIZE)+1);  //Counter needs to count DATA_SIZE times, before the multiplication ends
                                            //It the number of shifts that have occured 

parameter IDLE = 0, INITIAL = 1, TEST = 2, ADD = 3, SHIFT = 4;

input clk;
input rst_n;
input [(DATA_SIZE-1):0] a_in;
input [(DATA_SIZE-1):0] b_in;
input valid_f_data;      //The FIFO providing the data (FIFO_in) has valid data (not empty & operation = multiplication)
input ready_f_res;     //The FIFO were the results will be saved, can store more data (not full)

output ready_f_data;     //Signal, to FIFO in, that the previous multiplication has ended, thus the multiplier is ready to start a new one
output valid_f_res;    //Signal that a multiplication has ended and the result is ready to be stored in FIFO out
output [((2*DATA_SIZE)-1):0] result;



//Start / stop signals

wire [2:0] state;
wire idle_state;     //low when there is an operation happening, high when in idle state (waiting for data or for the results to be saved)
wire start;
wire start_temp;
wire done;
reg  done_temp;
wire stop;

wire [(COUNTER_SIZE-1):0] counter_out;


assign stop = ((counter_out == DATA_SIZE) );  //done signal -> the multiplication has finished and it goes low when a new one can begin

assign idle_state = (state == IDLE);
assign start_temp = (idle_state & valid_f_data & ready_f_res);  //new data are ready to be read from the FIFO in and FIFO out has availiable space 

d_ff_async #(.SIZE(1),
             .RESET_VALUE(1'b0))
       start_reg  (.clk(clk),
                 .rst(!rst_n),
                 .d(start_temp),
                 .q(start)); 



d_ff_async #(.SIZE(1),
             .RESET_VALUE(1'b0))
       done_reg  (.clk(clk),
                 .rst(!rst_n),
                 .d(done_temp),
                 .q(done)); 



//Signals between multiplier and the FIFOs 


wire ready_f_data_temp;
assign ready_f_data_temp = (valid_f_res & ready_f_res);      //in order a new multiplication to start, the previous results have to have been be saved

 d_ff_async #(.SIZE(1),
             .RESET_VALUE(1'b1))
       ready_f_data_reg(.clk(clk),
                 .rst(!rst_n),
                 .d(ready_f_data_temp),
                 .q(ready_f_data));



wire ready_f_res_dly;
d_ff_async #(.SIZE(1),
             .RESET_VALUE(1'b0))
       ready_f_resreg(.clk(clk),
                 .rst(!rst_n & valid_f_res_rst),
                 .d(ready_f_res),
                 .q(ready_f_res_dly));


wire ready_fall;
assign ready_fall= (!(ready_f_res & !ready_f_res_dly));    

wire valid_f_res_temp;

assign valid_f_res_temp = (stop & ready_fall);
 d_ff_async #(.SIZE(1),
             .RESET_VALUE(1'b0))
       valid_f_out_reg(.clk(clk),
                 .rst(!rst_n & valid_f_res_rst),
                 .d(valid_f_res_temp),
                 .q(valid_f_res)); 




//reg inputs, outputs and enable signals for load/shift registers, controlled by FSM

wire [(DATA_SIZE-1):0]  mul_c;             //multiplicant (reg A)
wire [(DATA_SIZE-1):0]  multiplier_shift;  //multiplier (output of shift reg B)

wire [(DATA_SIZE-1):0] adder_in;  
wire [(DATA_SIZE-1):0] adder_out;  
wire [(DATA_SIZE-1):0] reg_c_out; 

reg shift_load_mul_r_regB;  //control signal for loading or shifting (1-> shift, 0-> load) reg B
reg shift_load_mul_c_regC;  //control signal for loading or shifting (1-> shift, 0-> load) reg C

reg en_regA;   //enable signal for load input a_in in the multiplicant register  (is 0 in IDLE state)
reg en_regB;   //enable signal for the shift register B, for the multiplier b_in (is 0 in IDLE state)
reg en_regC;   //enable signal for the shift register C, for the addition result (is 0 in IDLE state)



//(Shift) Registers

//Register holding multiplicant               (Reg_A)
//(loaded only once, along with reg B, 
//in the beggining of the mul opperation)                                             
         d_ff_async_en #(.SIZE(DATA_SIZE),
                         .RESET_VALUE({DATA_SIZE{1'b0}}))
             load_a_reg(.clk(clk),
                        .rst(!rst_n | done),
                        .en(en_regA),
                        .d(a_in),
                        .q(mul_c));



//Shift register for multiplier                (Reg_B)
//(loaded in the begging of the operation,
//right-shifted every cycle (shift-input => reg_C[lsb]))       
        right_shift_register #(.DATA_SIZE(DATA_SIZE))
             shift_reg_B(.clk(clk),
                         .rst_n(rst_n & !done)  ,
                         .en(en_regB),
                         .shift_load(shift_load_mul_r_regB),
                         .d(b_in),
                         .d_shift(reg_c_out[0]),
                         .q(multiplier_shift));


wire carry_out_reg;
//Shift register for addition                  (Reg_C)
//(multiplicant + 0 or mul_c) result
           right_shift_register #(.DATA_SIZE(DATA_SIZE))
             shift_reg_C(.clk(clk),
                         .rst_n(rst_n & !done),
                         .en(en_regC),
                         .shift_load(shift_load_mul_c_regC),
                         .d(adder_out),
                         .d_shift(carry_out_reg),       //shift value is the carry_out from the previous addition
                         .q(reg_c_out));




//MUX and Adder

assign adder_in = (multiplier_shift[0]) ? mul_c : {DATA_SIZE{1'b0}};

wire carry_out;

add_sub #(.DATA_SIZE(DATA_SIZE))
    adder_mul(.a1(adder_in),
              .b(reg_c_out),
              .cin(1'b0),
              .operation(1'b1),
              .s(adder_out),
              .cout(carry_out));


//Register holding carry_out from the above addition
d_ff_async #(.SIZE(1),
             .RESET_VALUE({DATA_SIZE{1'b0}}))
       carry_reg(.clk(clk),
                 .rst(!rst_n),
                 .d(carry_out),
                 .q(carry_out_reg)); 
 



//FSM 

//State transition

reg  [2:0] next_state;


d_ff_async #(.SIZE(3),
                 .RESET_VALUE(IDLE))
       fsm_reg(.clk(clk),
                .rst(!rst_n),
                 .d(next_state),
                 .q(state));



//next-state combinational logic

always@(*)begin  
      next_state = IDLE;
    case(state) 
        IDLE   : next_state = (start) ? INITIAL : IDLE;                 

        INITIAL: next_state = TEST;  

        TEST   : next_state = (multiplier_shift[0]) ? ADD : SHIFT;

        ADD    : next_state              = SHIFT;

        SHIFT  : next_state              = (stop) ? IDLE : TEST;

        default: next_state              = IDLE;
    endcase
end



//output logic

always@(*)begin
      done_temp = 1'b0;
      en_regA = 1'b0;
      en_regB = 1'b0;
      en_regC       = 1'b0;  
      shift_load_mul_r_regB   = 1'b0;
      shift_load_mul_c_regC   = 1'b0;
    case(state)
        IDLE: begin
              en_regA = (start);
              en_regB = (start);
              end
       /* INITIAL: begin
                en_regA = 1'b1;
                en_regB = 1'b1;
                end */
        TEST: begin
              en_regC       = 1'b1;
              en_regB = (!multiplier_shift[0]);
              shift_load_mul_r_regB   = (!multiplier_shift[0]);
              shift_load_mul_c_regC   = (!multiplier_shift[0]);
              end

        ADD: begin
            en_regC       = 1'b1;
            en_regB = 1'b1;
            shift_load_mul_r_regB   = 1'b1;
            shift_load_mul_c_regC   = 1'b1;
             end

        SHIFT: begin
               done_temp   = (stop);
               end
        default: begin
                 done_temp = 1'b0;
                 en_regA = 1'b0;
                 en_regB = 1'b0;
                 en_regC       = 1'b0;  
                 shift_load_mul_r_regB   = 1'b0;
                 shift_load_mul_c_regC   = 1'b0;            
                 end

    endcase


end




//Counter for counting the times the values shifted -> DATA_SIZE times before the operation ends

wire [(COUNTER_SIZE-1):0] counter_in;
wire counter_en;

d_ff_async_en #(.SIZE(COUNTER_SIZE),
             .RESET_VALUE({COUNTER_SIZE{1'b0}}))
      counter_mul(.clk(clk),
                 .rst(!rst_n | start_temp),
                 .en(counter_en),
                 .d(counter_in),
                 .q(counter_out)); 
 

assign counter_en    = (next_state == SHIFT);
assign counter_in    = (done) ? {COUNTER_SIZE{1'b0}} : (next_state == SHIFT) ? (counter_out + 1'b1) : counter_out ;



//Result

wire [((2*DATA_SIZE)-1):0] result_temp;
assign result_temp =  {reg_c_out,multiplier_shift} ;


d_ff_async_en #(.SIZE(2*DATA_SIZE),
             .RESET_VALUE({2*DATA_SIZE{1'b0}}))
      result_reg(.clk(clk),
                 .rst(!rst_n),
                 .en(done_temp),
                 .d(result_temp),
                 .q(result)); 

endmodule
