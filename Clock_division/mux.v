module mux
(sel,
count,
out
);

parameter C2_size ;

input sel;
input [(C2_size-1):0] count;
output [(C2_size-1):0] out;

assign out = (sel) ? count : out;

endmodule