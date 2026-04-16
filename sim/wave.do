onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_riscv_checker_ver2/uut/clk
add wave -noupdate /tb_riscv_checker_ver2/uut/rst_n
add wave -noupdate -divider {IF STAGE}
add wave -noupdate /tb_riscv_checker_ver2/uut/if_inst
add wave -noupdate /tb_riscv_checker_ver2/uut/if_pc
add wave -noupdate /tb_riscv_checker_ver2/uut/if_pc_plus_4
add wave -noupdate -divider {ID STAGE}
add wave -noupdate /tb_riscv_checker_ver2/uut/id_inst
add wave -noupdate /tb_riscv_checker_ver2/uut/id_pc
add wave -noupdate /tb_riscv_checker_ver2/uut/id_pc_plus_4
add wave -noupdate /tb_riscv_checker_ver2/uut/id_func3
add wave -noupdate /tb_riscv_checker_ver2/uut/id_rs1_data
add wave -noupdate /tb_riscv_checker_ver2/uut/id_rs2_data
add wave -noupdate /tb_riscv_checker_ver2/uut/id_imm
add wave -noupdate /tb_riscv_checker_ver2/uut/id_rd_idx
add wave -noupdate /tb_riscv_checker_ver2/uut/id_ImmSel
add wave -noupdate /tb_riscv_checker_ver2/uut/id_RegWEn
add wave -noupdate /tb_riscv_checker_ver2/uut/id_BrUn
add wave -noupdate /tb_riscv_checker_ver2/uut/id_IsBranch
add wave -noupdate /tb_riscv_checker_ver2/uut/id_IsJump
add wave -noupdate /tb_riscv_checker_ver2/uut/id_ASel
add wave -noupdate /tb_riscv_checker_ver2/uut/id_BSel
add wave -noupdate /tb_riscv_checker_ver2/uut/id_ALUSel
add wave -noupdate /tb_riscv_checker_ver2/uut/id_MemRW
add wave -noupdate /tb_riscv_checker_ver2/uut/id_WBSel
add wave -noupdate -divider {EX STAGE}
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_pc
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_rs1_data
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_rs2_data
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_imm
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_pc_plus_4
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_rd_idx
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_func3
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_BrUn
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_IsBranch
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_IsJump
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_ASel
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_BSel
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_ALUSel
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_MemRW
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_RegWEn
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_WBSel
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_alu_out
add wave -noupdate /tb_riscv_checker_ver2/uut/ex_PCSel
add wave -noupdate -divider {MEM STAGE}
add wave -noupdate /tb_riscv_checker_ver2/uut/mem_alu_out
add wave -noupdate /tb_riscv_checker_ver2/uut/mem_rs2_data
add wave -noupdate /tb_riscv_checker_ver2/uut/mem_pc_plus_4
add wave -noupdate /tb_riscv_checker_ver2/uut/mem_rd_idx
add wave -noupdate /tb_riscv_checker_ver2/uut/mem_func3
add wave -noupdate /tb_riscv_checker_ver2/uut/mem_MemRW
add wave -noupdate /tb_riscv_checker_ver2/uut/mem_RegWEn
add wave -noupdate /tb_riscv_checker_ver2/uut/mem_WBSel
add wave -noupdate /tb_riscv_checker_ver2/uut/mem_rd_raw
add wave -noupdate -divider {WB STAGE}
add wave -noupdate /tb_riscv_checker_ver2/uut/wb_alu_out
add wave -noupdate /tb_riscv_checker_ver2/uut/wb_rd_raw
add wave -noupdate /tb_riscv_checker_ver2/uut/wb_pc_plus_4
add wave -noupdate /tb_riscv_checker_ver2/uut/wb_rd_idx
add wave -noupdate /tb_riscv_checker_ver2/uut/wb_func3
add wave -noupdate /tb_riscv_checker_ver2/uut/wb_RegWEn
add wave -noupdate /tb_riscv_checker_ver2/uut/wb_WBSel
add wave -noupdate /tb_riscv_checker_ver2/uut/wb_wd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {817575 ps} {820128 ps}
