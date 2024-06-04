create_clock -period 25.000 -name clk -waveform {0.000 5.000} [get_ports clk]
#input delay 8 for period 10 ns passed implementation
#increased period due to Reg2Out setup 

set_input_delay -clock [get_clocks *] 15.000 [get_ports {{addr[0]} {addr[1]} {addr[2]} {addr[3]} {addr[4]} {addr[5]} {addr[6]} {addr[7]} {addr[8]} {addr[9]} {addr[10]} {addr[11]} {addr[12]} {addr[13]} {addr[14]} {addr[15]} {addr[16]} {addr[17]} {addr[18]} {addr[19]} {addr[20]} {addr[21]} {addr[22]} {addr[23]} {addr[24]} {addr[25]} {addr[26]} {addr[27]} {addr[28]} {addr[29]} {addr[30]} {addr[31]} en int rst_n sel {wdata[0]} {wdata[1]} {wdata[2]} {wdata[3]} {wdata[4]} {wdata[5]} {wdata[6]} {wdata[7]} write}]

set_output_delay -clock [get_clocks *] 15.000 [get_ports -filter { NAME =~  "*" && DIRECTION == "OUT" }]

