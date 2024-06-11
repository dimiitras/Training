###MEM_IP = 1
create_clock -period 28.000 -name clk -waveform {0.000 14.000} [get_ports clk]

#MEM_IP = 1
set_input_delay -clock [get_clocks *] 16.800 [get_ports {r_en rst_n w_en {wdata[0]} {wdata[1]} {wdata[2]} {wdata[3]}}]
set_output_delay -clock [get_clocks *] 16.800 [get_ports -filter { NAME =~  "*" && DIRECTION == "OUT" }]


#########

##MEM_IP = 0
#create_clock -period 25.000 -name clk -waveform {0.000 12.500} [get_ports clk]
##23.40 with 14 delay

##MEM_IP = 1
#set_input_delay -clock [get_clocks *] 15.000 [get_ports {r_en rst_n w_en {wdata[0]} {wdata[1]} {wdata[2]} {wdata[3]}}]
#set_output_delay -clock [get_clocks *] 15.000 [get_ports -filter { NAME =~  "*" && DIRECTION == "OUT" }]
