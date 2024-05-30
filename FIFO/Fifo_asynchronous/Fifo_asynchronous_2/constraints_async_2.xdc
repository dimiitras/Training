#For REAL_MEM = 0 and READ_REG = 0 -> highest possible frequencies (fw = 40 MHz and fr = 35 MHz)
create_clock -period 25.000 -name w_clk -waveform {0.000 12.500} [get_ports w_clk]
create_clock -period 28.000 -name r_clk -waveform {0.000 14.000} [get_ports r_clk]

#set_input_delay -help
#set_output_delay -help
set_clock_groups -asynchronous -group r_clk -group w_clk

set_input_delay -clock w_clk -max 15.000 [get_ports {w_en {wdata[0]} {wdata[1]} {wdata[2]} {wdata[3]} wrst_n}]
#set_input_delay -clock w_clk -min 3.000 [get_ports {w_en {wdata[0]} {wdata[1]} {wdata[2]} {wdata[3]} wrst_n}]

set_input_delay -clock r_clk -max 16.800 [get_ports {r_en rrst_n}]
#set_input_delay -clock r_clk -min 1.000 [get_ports {r_en rrst_n}]

set_output_delay -clock w_clk -max 15.000 [get_ports w_full]
#set_output_delay -clock w_clk -min 2.000 [get_ports w_full]

set_output_delay -clock r_clk -max 16.800 [get_ports {r_almost_empty r_empty {rdata[0]} {rdata[1]} {rdata[2]} {rdata[3]}}]
#set_output_delay -clock r_clk -min 1.000 [get_ports {r_almost_empty r_empty {rdata[0]} {rdata[1]} {rdata[2]} {rdata[3]}}]


#set_false_path -from [get_clocks r_clk] -to [get_clocks w_clk]
#set_false_path -from [get_clocks w_clk] -to [get_clocks r_clk]

#set_max_delay -datapath_only -from [get_clocks r_clk] -to [get_clocks w_clk] 2.000
#set_max_delay -datapath_only -from [get_clocks w_clk] -to [get_clocks r_clk] 2.000


#set top_module w_clk_module
#set r_pointer [get_ports -hierarchical -filter {NAME == "${top_module}/r_ptr"}]
#set_property ASYNC_REG TRUE r_pointer

#set top_module r_clk_module
#set w_pointer [get_ports -hierarchical -filter {NAME == "${top_module}/w_ptr"}]
#set_property ASYNC_REG TRUE w_pointer

