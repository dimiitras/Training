module add_sub(
a1,
b,
cin,
operation,
s,
cout);

parameter DATA_SIZE;

input [(DATA_SIZE-1):0] a1; 
input [(DATA_SIZE-1):0] b;
input cin;
input operation;           // 1-> addition, 0 -> subtraction (converts b input to its two's complement and then adds them)
output [(DATA_SIZE-1):0] s;
output cout;

wire [(DATA_SIZE-1):0] g; //generate function
wire [(DATA_SIZE-1):0] p; //propagate function

wire [(DATA_SIZE-1):0] c;
reg  [(DATA_SIZE-1):0] a2;


//Select addition or subtraction

always@(*) begin
    if(operation) 
        a2 = b;
    else 
        a2 = (b ^ {DATA_SIZE{cin}});
end


//Carry-lookahead adder

assign c[0] = cin;
assign cout = c[(DATA_SIZE-1)];

/*genvar i;
generate
    for(i=0; i <= (DATA_SIZE-1); i = i + 1) begin
        g[i] = (a1[i] & a2[i]);
        p[i] = (a1[i] ^ a2[i]);
        
        c[i+1] = (g[i] | (p[i] & c[i]));
        s[i] = (p[i] ^ c[i]);

    end
endgenerate
*/

genvar i;
generate 
   for(i=0; i <= (DATA_SIZE-1); i = i + 1) begin
       cla_1_bit
           cla_n_bits(.a1(a1[i]),
                      .a2(a2[i]),
                      .cin(c[i]),
                      .s(s[i]),
                      .c_out(c[i+1]));
    end

endgenerate

endmodule
