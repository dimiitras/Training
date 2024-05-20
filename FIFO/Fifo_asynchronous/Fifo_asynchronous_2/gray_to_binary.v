module gray_to_binary (
gray,
binary);

parameter N;

input [(N-1) :0] gray;

output reg [(N-1) :0] binary;

integer i;

always @(*)
  begin
    binary[N-1]=gray[N-1];
    
    for (i=N-2; i>0; i=i-1) begin
      binary[i]=gray[i]^gray[i+1];
    end
end


endmodule
