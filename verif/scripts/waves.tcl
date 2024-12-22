puts "dump.vcd should be created in the simulation folder"
set nfacs [gtkwave::getNumFacs]
set dumpname [gtkwave::getDumpFileName]
set dmt [gtkwave::getDumpType]

puts "number of signals in dumpfile '$dumpname' of type $dmt: $nfacs"

set clk48 [list]
lappend clk48 "TOP.top.dut.core.clock"
lappend clk48 "TOP.top.dut.core.pc"
lappend clk48 "TOP.top.dut.core.d_pc"
lappend clk48 "TOP.top.dut.core.e_pc"
lappend clk48 "TOP.top.dut.core.m_pc"
lappend clk48 "TOP.top.dut.core.w_pc"
lappend clk48 "TOP.top.dut.core.branch_taken"
lappend clk48 "TOP.top.dut.core.stall"
# lappend clk48 "TOP.top.dut.core.pc_de"
# lappend clk48 "TOP.top.dut.core.opcode"
# lappend clk48 "TOP.top.dut.core.rd"
# lappend clk48 "TOP.top.dut.core.rs1"
# lappend clk48 "TOP.top.dut.core.rs2"
# lappend clk48 "TOP.top.dut.core.funct3"
# lappend clk48 "TOP.top.dut.core.funct7"
# lappend clk48 "TOP.top.dut.core.imm"
# lappend clk48 "TOP.top.dut.core.rs2"
# lappend clk48 "TOP.top.dut.core.rf_write_enable"
# lappend clk48 "TOP.top.dut.core.rd"
# lappend clk48 "TOP.top.dut.core.data_rd"
# lappend clk48 "TOP.top.dut.core.rs1"
# lappend clk48 "TOP.top.dut.core.rs2"
# lappend clk48 "TOP.top.dut.core.data_rs1"
# lappend clk48 "TOP.top.dut.core.data_rs2"
# lappend clk48 "TOP.top.dut.core.pc_ex"
# lappend clk48 "TOP.top.dut.core.alu_result"
# lappend clk48 "TOP.top.dut.core.branch_taken"
# lappend clk48 "TOP.top.dut.core.pc_me"
# lappend clk48 "TOP.top.dut.core.alu_result_me"
# lappend clk48 "TOP.top.dut.core.write_en_mem_me"
# lappend clk48 "TOP.top.dut.core.wb_access_size"
# lappend clk48 "TOP.top.dut.core.data_rs2_me"
# lappend clk48 "TOP.top.dut.core.pc_wb"
# lappend clk48 "TOP.top.dut.core.write_en_regs_wb"
# lappend clk48 "TOP.top.dut.core.rd_wb"
# lappend clk48 "TOP.top.dut.core.data_rd"

set num_added [gtkwave::addSignalsFromList $clk48]

# Change color of singnal top.c.x to Yellow

gtkwave::/Edit/Highlight_Regexp "pc"
gtkwave::/Edit/Color_Format/Yellow
gtkwave::/Edit/UnHighlight_All

gtkwave::/View/Show_Wave_Highlight
gtkwave::/Edit/Set_Trace_Max_Hier 0

# # zoom full
# gtkwave::/Time/Zoom/Zoom_Full

open_vcd
log_vcd [ get_objects *]
run all
close_vcd

quit
