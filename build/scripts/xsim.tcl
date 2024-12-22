open_vcd waveform.vcd


# You may add other signals here
# log_vcd [get_objects ...]

log_wave {/tb/inst/inst/dut/core/d_pc} 
log_wave {/tb/inst/inst/dut/core/e_pc} 
log_wave {/tb/inst/inst/dut/core/m_pc} 
log_wave {/tb/inst/inst/dut/core/pc}

log_vcd [get_objects /tb/inst/inst/dut/core/e_pc]
# log_vcd [get_objects /tb/inst/inst/dut/core/w_pc]
log_vcd [get_objects /tb/inst/inst/dut/core/m_pc]
log_vcd [get_objects /tb/inst/inst/dut/core/alu_result]
log_vcd [get_objects /tb/inst/inst/dut/core/data_rd]
log_vcd [get_objects /tb/inst/inst/dut/core/stall]
log_vcd [get_objects /tb/inst/inst/dut/core/branch_taken]
log_vcd [get_objects /tb/inst/inst/dut/core/R_branch_taken]

run 2000ns > output.sim
flush_vcd
close_vcd
exit
exit
