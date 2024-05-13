module keyboard_shift_1 (
clk, 
reset,
rows,
columns,
key);

parameter Rows = 4;
parameter Columns = 4;

parameter Key_X1 = 0 ,Key_X2 = 1, Key_X3 = 2, Key_X4 = 3;

input clk;
input reset;
input [(Rows - 1):0] rows;
output reg [(Columns - 1):0] columns;
output reg [4:0] key;



reg [4:0] key_r;

		
always@(posedge clk)begin
	if(reset) columns <= 4'b1110;
	else columns <= {columns[2:0], columns [3]};
end

//key
always@(*)begin
key = 16; //nothing pressed
	case(columns)
		4'b1110:begin
			case(rows)
				4'b1110: key = 0;
				4'b1101: key = 1;
				4'b1111: key = 2;
				4'b0111: key = 3;
				default: key = 16;
			endcase
			end
		4'b1101:begin
			case(rows)
				4'b1110: key = 4;
				4'b1101: key = 5;
				4'b1111: key = 6;
				4'b0111: key = 7;
				default: key = 16;
			endcase
			end
		4'b1011:begin
			case(rows)
				4'b1110: key = 8;
				4'b1101: key = 9;
				4'b1111: key = 10;
				4'b0111: key = 11;
				default: key = 16;
			endcase
			end
		4'b0111:begin
			case(rows)
				4'b1110: key = 12;
				4'b1101: key = 13;
				4'b1111: key = 14;
				4'b0111: key = 15;
				default: key = 16;
			endcase
			end
		default: key = 16;
	endcase
end

always@(posedge clk) begin
	if(reset) key_r <= 5'b00000;
	else begin
		if(~(&rows)) key_r <= key;
	end
end
endmodule