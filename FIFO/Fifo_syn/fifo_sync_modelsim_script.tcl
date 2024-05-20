#fifo_sync_modelsim_script

#Initialize Modelsim

vsim -c

#Compile

vlog d_ff_sync.v d_ff_sync_en.v fifo_sync.v fifo_sync_tb.v

#Start Simulation

vsim work.d_ff_sync_tb.v

#Add signals to the waveform window

add wave /fifo_sync_tb.v/* -radix unsigned -input

#Run Simulation

run all
