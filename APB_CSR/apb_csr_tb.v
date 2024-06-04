`timescale 1ns/1ps
`define CLK_PERIOD 10
`define sim_delay 0   //sel, en, wdata, addr and write are being set at posedge for BEHAVIORAL SIMULATION.
                      //But for POST-IMPL. SIMULATION, we add a small delay. Setting sel = 1 at posedge of setup phase causes metastabillity issues.
                      //That is still the steup phase, even with the delay.
module apb_csr_tb();

/*
For EDA Playground:
`inlcude "design.sv"
*/


parameter ADDRESS_SIZE      = 32;
parameter REG_NUMBER        = 5;       //How many registers we have (assume all of them can be read)
parameter ADDR_BASE         = 4; 
parameter BASE_BIT          = 8;
parameter WRITE_REG_NUMBER  = 3;       //How many registers we can write on
parameter REG_WIDTH         = 8;
parameter TYPE_DEFAULT      = 8'hAF;  //TYPE register default value
parameter RANDOM_DEFAULT    = 8'hAF;  //TYPE register default value


reg                       clk;
reg                       rst_n;
reg [(ADDRESS_SIZE -1):0] addr;
reg                       sel;
reg                       en;
reg                       write;
reg [(REG_WIDTH-1) :0]    wdata;
reg                       intrpt;

wire [(REG_WIDTH-1) :0]     rdata;
wire                        slv_err;
wire                        ready;

integer i;
integer j;



ABP_CSR_top_module #(.ADDRESS_SIZE(ADDRESS_SIZE),
                    .REG_NUMBER(REG_NUMBER),
                    .ADDR_BASE(ADDR_BASE),
					.BASE_BIT(BASE_BIT),
                    .WRITE_REG_NUMBER(WRITE_REG_NUMBER),
                    .REG_WIDTH(REG_WIDTH),
                    .TYPE_DEFAULT(TYPE_DEFAULT),
                    .RANDOM_DEFAULT(RANDOM_DEFAULT))
            DUT(.clk(clk),
                .rst_n(rst_n),
                .addr(addr),
                .sel(sel),
                .en(en),
                .write(write),
                .slv_err(slv_err),
                .ready(ready),
                .wdata(wdata),
                .rdata(rdata),
                .intrpt(intrpt));
                   
                   
     
initial
begin
	clk = 1'b0;
	
	rst_n = 1'b0;
	
	addr = 32'h0000_0400;
    sel = 1'b0;
	en  = 1'b0;
	write = 1'b0;
    wdata = {REG_WIDTH{1'b0}};
	intrpt = 1'b0;
	
	#13;
	
	rst_n = 1'b1;
	
	//#100; //Vivado simulation (post-synthesis) :GSR deasserts after 100ns
	
	main;
	
	#20;
	$stop;
end

always #(`CLK_PERIOD/2)  clk = ~ clk;


task main; 
begin
	
	Write_1;
    Write_2;
    Interrupt;
	Read;

end
endtask

   
task Write_1;
begin
		#10;
        //First two regs (TYPE and RANDOM)
		for(i=0; i < 2; i = i +1) begin
            //SETUP PHASE
		    @(posedge clk)begin
			#(`sim_delay);
		    sel   = 1'b1;
            write = 1'b1;
            addr = 32'h0000_0400 + i;
		    wdata = wdata + 1'b1;
		    end
            //ACCESS PHASE
            @(posedge clk) begin
			#(`sim_delay);
            en = 1'b1;        
            end
        
            @(posedge clk) begin
			#(`sim_delay);
            sel   = 1'b0;
            en    = 1'b0;
            write = 1'b0;
            end
		end
  
   
end
endtask


task Write_2;
begin
        //for registers INT_CLR(bit 7) and INT_STATUS and MASK(bit 0) 
		for(j=2; j < 5; j = j +1) begin
            //SETUP PHASE
		    @(posedge clk)begin
			#(`sim_delay);
		    sel   = 1'b1;
            write = 1'b1;
            addr = 32'h0000_0400 + j;
		    wdata = 8'b10000000 + 1'b1;
		    end
            //ACCESS PHASE            
            @(posedge clk) begin
			#(`sim_delay);
            en = 1'b1;        
            end
        
            @(posedge clk) begin
			#(`sim_delay);
            sel   = 1'b0;
            en    = 1'b0;
            write = 1'b0;
            end
		end
        
end
endtask

task Interrupt;
begin
        //Write mask 1	and int 1
        @(posedge clk)begin
        //SETUP PHASE
		#(`sim_delay);
		sel   = 1'b1;
        write = 1'b1;
        addr = 32'h0000_0404;
		wdata = 8'b10000000 + 1'b1;
        intrpt = 1'b1;
        end
        //ACCESS PHASE
        @(posedge clk)begin
		#(`sim_delay);
        en = 1'b1;          
        end
        
        @(posedge clk) begin
		#(`sim_delay);
        sel   = 1'b0;
        en    = 1'b0;
        write = 1'b0;
        end
		
		@(posedge clk);
		@(posedge clk);
		
        //INT_CLR 1
        @(posedge clk)begin
        //SETUP PHASE
		#(`sim_delay);
        sel   = 1'b1;
        write = 1'b1;
        addr = 32'h0000_0402;   
		wdata = 8'b10000000 + 1'b1;   
        intrpt = 1'b0;
        end
        //ACCESS PHASE
        @(posedge clk)begin
		#(`sim_delay);
        en = 1'b1;          
        end
        
        @(posedge clk) begin
		#(`sim_delay);
        sel   = 1'b0;
        en    = 1'b0;
        write = 1'b0;
        end

end
endtask


task Read;
begin
		#3;
		for(i=0; i < 5; i = i +1) begin
		    @(posedge clk)begin
            //SETUP PHASE
			#(`sim_delay);
		    sel   = 1'b1;
            write = 1'b0;
            addr = 32'h0000_0400 + i;
		    end
            //ACCESS PHASE
            @(posedge clk)begin
			#(`sim_delay);
            en = 1'b1;          
            end
        
            @(posedge clk) begin
			#(`sim_delay);
            sel   = 1'b0;
            en    = 1'b0;
            write = 1'b0;
            end
        end
end
endtask




endmodule
