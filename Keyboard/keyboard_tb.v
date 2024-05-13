`timescale 1ns / 1ps
module keyboard_tb (
);
parameter Rows = 4;
parameter Columns = 4;

reg clk;
reg reset;
reg [(Rows - 1):0] rows;
wire [(Columns - 1):0] columns;
wire [4:0] key;

/*keyboard_5_FSM #(.Rows(4), .Columns(4), .IDLE(3'b000), .Shift_1(3'b001), .Shift_2(3'b010), .Shift_3(3'b011), .Shift_4(3'b100))
			fsm_5(
			.clk(clk),
			.reset(reset),
			.rows(rows),
			.columns(columns),
			.key(key));
			
/*keyboard_4_FSM #(.Rows(4), .Columns(4), .Shift_1(2'b00), .Shift_2(2'b01), .Shift_3(2'b10), .Shift_4(2'b11));
			fsm_4(
			.clk(clk),
			.reset(reset),
			.rows(rows),
			.columns(columns),
			.key(key));
			
keyboard_shift #(.Rows(4), .Columns(4), .Key_X1(3), .Key_X2(2), .Key_X3(1), .Key_X4(0));
			shift(
			.clk(clk),
			.reset(reset),
			.rows(rows),
			.columns(columns),
			.key(key));*/
			
keyboard_shift_1 #(.Rows(4), .Columns(4), .Key_X1(0), .Key_X2(1), .Key_X3(2), .Key_X4(3))
			shift_1(
			.clk(clk),
			.reset(reset),
			.rows(rows),
			.columns(columns),
			.key(key));



//clock
initial begin 
clk= 1'b0;
forever #10 clk=~clk;
end

initial begin
#5
rows = 4'b1011;
#40
rows = 4'b1110;
#40
rows = 4'b0111;
end

//reset
initial begin
 reset = 1'b1;
 #15;
 reset = 1'b0;
end

endmodule