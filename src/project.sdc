# Shared constants, copied from  base.sdc  
set input_delay_value [ expr $::env(CLOCK_PERIOD) * $::env(IO_PCT) ]
set output_delay_value [ expr $::env(CLOCK_PERIOD) * $::env(IO_PCT) ]
set_max_fanout $::env(MAX_FANOUT_CONSTRAINT) [ current_design ]
set cap_load [ expr $::env(OUTPUT_CAP_LOAD) / 1000.0 ] ;# fF -> pF

# Remove clock net from inputs
set idx [ lsearch [ all_inputs ] "clk" ]
set all_inputs_wo_clk [ lreplace [ all_inputs ] $idx $idx ]
set idx [ lsearch $all_inputs_wo_clk "ui_in\[3\]" ]
set all_inputs_wo_clk [ lreplace $all_inputs_wo_clk $idx $idx ]

#  clk   is the main clock
create_clock [ get_ports "clk" ]  -name clk -period $::env(CLOCK_PERIOD)
set_input_delay $input_delay_value -clock [ get_clocks clk ] $all_inputs_wo_clk
set_output_delay $output_delay_value -clock [ get_clocks clk ] [ all_outputs ]
set_clock_uncertainty $::env(SYNTH_CLOCK_UNCERTAINTY) [ get_clocks clk ]
set_clock_transition $::env(SYNTH_CLOCK_TRANSITION) [ get_clocks clk ]

#  ui_in[3]   clock is genearted by the debugger for driving debbuging data
create_clock [ get_ports "ui_in\[3\]" ]  -name debug_clk -period $::env(CLOCK_PERIOD)
set_input_delay $input_delay_value -clock [ get_clocks debug_clk ] $all_inputs_wo_clk
set_output_delay $output_delay_value -clock [ get_clocks debug_clk ] [ all_outputs ]
set_clock_uncertainty $::env(SYNTH_CLOCK_UNCERTAINTY) [ get_clocks debug_clk ]
set_clock_transition $::env(SYNTH_CLOCK_TRANSITION) [ get_clocks debug_clk ]

# rp2040_clk  and  fpga_clk  are mesochronous, and they never interact
set_clock_groups -asynchronous -group { clk } -group { debug_clk }

# Miscellanea
set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) $all_inputs_wo_clk
set_load  $cap_load [ all_outputs ]
set_timing_derate -early [ expr {1-$::env(SYNTH_TIMING_DERATE)} ]
set_timing_derate -late [ expr {1+$::env(SYNTH_TIMING_DERATE)} ]

