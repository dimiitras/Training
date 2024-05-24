`timescale 1ns/1ps
`define DATAWIDTH 32
`define ADDRWIDTH 6
`define IDLE     2'b00
`define W_ENABLE  2'b01
`define R_ENABLE  2'b10

module APB_Slave_tb ();

  reg                         PCLK;
  reg                         PRESETn;
  reg        [`ADDRWIDTH-1:0] PADDR;
  reg                         PWRITE;
  reg                         PSEL;
  reg						  PENABLE;
  reg     	 [`DATAWIDTH-1:0] PWDATA;
  reg    [(`DATAWIDTH/8)-1:0] PSTROBE;
  wire 	  	 [`DATAWIDTH-1:0] PRDATA;
  wire	                      PREADY;
  wire                        PSLVERR;
  

integer i;
integer j;
integer k;


initial begin
    PCLK = 0;
    PRESETn = 0;
    #10;
    PRESETn = 1;
    PSEL = 0;
	PENABLE = 0;
    @(negedge PCLK);
	@(negedge PCLK);
    Write;
    //Read;
	//Strobe;
    #20;
    #10000; 
     $stop;
  end
  
  always  #1  PCLK = ~PCLK;
 
  apb_slv_memory_final #(.DATA_SIZE(`DATAWIDTH), .ADDR_SIZE(`ADDRWIDTH))
			DUT(.PCLK(PCLK),
				.PRESETn(PRESETn),
				.PADDR(PADDR),
				.PSEL(PSEL),
				.PENABLE(PENABLE), 
				.PWRITE(PWRITE),
				.PWDATA(PWDATA),
				.PSTROBE(PSTROBE),
				.PREADY(PREADY),
				.PRDATA(PRDATA),
				.PSLVERR(PSLVERR) );

 task Write;
 begin
 	// #1;
	for (i = 0; i < 50; i=i+1) begin
	@(negedge PCLK) begin
	// @(negedge PCLK) begin
	 	PSEL = 1;
	 	PWRITE = 1;
		PSTROBE = 4-i;
		PADDR = i;
		PWDATA = {16{2'b01}};
	$display("PADDR %h, PWDATA %h  ",PADDR,PWDATA);
	 // end 
	 end
	 @(negedge PCLK) begin
	// @(negedge PCLK) begin
	 	PENABLE = 1;
	 	
	end
	
	@(negedge PCLK) begin
	// @(negedge PCLK) begin
	 	PENABLE = 0;
	 	PSEL = 0;
	 	PWRITE = 0;
	end
	
	 // end 
	 end
		// #2;
	 	// PSEL = 0; 
	end
    // PSEL = 0;

endtask



		 
/*task Read;
begin 
	for (j = 0;  j< 50; j= j+1) begin
	@(negedge PCLK) begin
	 	PSEL = 1;
	 	PWRITE = 0;
	// @(negedge PCLK) begin
	 // end
	 // @(negedge PCLK) begin
		PADDR = j;
	 	// PSEL = 0;
	$display("PADDR %h, PRDATA %h  ",PADDR,PRDATA);
	 // end
	 end
end
end
 endtask*/
 
 /*task Strobe;
 begin
	for(k=0; k<5; k = k+1)begin
	@(negedge PCLK) begin
		PSEL = 1;
	 	PWRITE = 1;
		PSTROBE = k;
		PADDR = k;
		end
	@(negedge PCLK) begin
		PENABLE = 1;
	end
	
	@(negedge PCLK) begin
	// @(negedge PCLK) begin
	 	PENABLE = 0;
	 	PSEL = 0;
	 	PWRITE = 0;
	end
	end
end
 endtask*/
 		
 endmodule