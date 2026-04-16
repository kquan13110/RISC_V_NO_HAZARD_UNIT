`timescale 1ns/1ps

module riscv_core (
    input wire clk,
    input wire rst_n
);

    // ==========================================
    // 1. WIRES DECLARATION
    // ==========================================
    
    // --- IF Stage Wires ---
    wire [31:0] if_inst;
    wire [31:0] if_pc;
    wire [31:0] if_pc_plus_4;
    
    // --- ID Stage Wires ---
    wire [31:0] id_inst;
    wire [31:0] id_pc;
    wire [31:0] id_pc_plus_4;
    wire [2:0]  id_func3 = id_inst[14:12]; // Extract func3 to pass down
    
    wire [31:0] id_rs1_data, id_rs2_data, id_imm;
    wire [4:0]  id_rd_idx;
    
    // Control wires from CU
    wire [2:0] id_ImmSel;
    wire id_RegWEn, id_BrUn, id_IsBranch, id_IsJump, id_ASel, id_BSel;
    wire [3:0] id_ALUSel;
    wire id_MemRW;
    wire [1:0] id_WBSel;

    // --- EX Stage Wires ---
    wire [31:0] ex_pc, ex_rs1_data, ex_rs2_data, ex_imm, ex_pc_plus_4;
    wire [4:0]  ex_rd_idx;
    wire [2:0]  ex_func3;
    
    wire ex_BrUn, ex_IsBranch, ex_IsJump, ex_ASel, ex_BSel;
    wire [3:0] ex_ALUSel;
    wire ex_MemRW, ex_RegWEn;
    wire [1:0] ex_WBSel;
    
    wire [31:0] ex_alu_out;
    wire ex_PCSel; // Branch/Jump decision

    // --- MEM Stage Wires ---
    wire [31:0] mem_alu_out, mem_rs2_data, mem_pc_plus_4;
    wire [4:0]  mem_rd_idx;
    wire [2:0]  mem_func3;
    wire mem_MemRW, mem_RegWEn;
    wire [1:0] mem_WBSel;
    
    wire [31:0] mem_rd_raw;

    // --- WB Stage Wires ---
    wire [31:0] wb_alu_out, wb_rd_raw, wb_pc_plus_4;
    wire [4:0]  wb_rd_idx;
    wire [2:0]  wb_func3;
    wire wb_RegWEn;
    wire [1:0] wb_WBSel;
    
    wire [31:0] wb_wd; // Final data to write back


    // ==========================================
    // 2. INSTRUCTION FETCH (IF)
    // ==========================================
    stage_if #(
        .MEM_DEPTH(1024)
    ) u_stage_if (
        .clk(clk),
        .rst_n(rst_n),
        .pc_en(1'b1),               // No hazard unit yet -> always run
        .PCSel(ex_PCSel),           // Feedback from EX stage
        .alu_target(ex_alu_out),    // Feedback from EX stage (Branch target)
        .inst(if_inst),
        .pc_out(if_pc),
        .pc_plus_4(if_pc_plus_4)
    );

    // --- IF/ID Register ---
    if_id_reg u_if_id_reg (
        .clk(clk),
        .rst_n(rst_n),
        .flush(1'b0),               // No hazard unit yet
        .en(1'b1),
        .if_pc(if_pc),
        .if_inst(if_inst),
        .if_pc_plus_4(if_pc_plus_4),
        .id_pc(id_pc),
        .id_inst(id_inst),
        .id_pc_plus_4(id_pc_plus_4)
    );


    // ==========================================
    // 3. INSTRUCTION DECODE (ID)
    // ==========================================
    
    // Control Unit (Standalone)
    control_unit u_control_unit (
        .inst(id_inst),
        .ImmSel(id_ImmSel),
        .RegWEn(id_RegWEn),
        .BrUn(id_BrUn),
        .IsBranch(id_IsBranch),
        .IsJump(id_IsJump),
        .ASel(id_ASel),
        .BSel(id_BSel),
        .ALUSel(id_ALUSel),
        .MemRW(id_MemRW),
        .WBSel(id_WBSel)
    );

    // Data Path
    stage_id u_stage_id (
        .clk(clk),
        .inst(id_inst),
        .ImmSel(id_ImmSel),
        .wb_we(wb_RegWEn),          // Feedback from WB stage
        .wb_rd(wb_rd_idx),          // Feedback from WB stage
        .wb_wd(wb_wd),              // Feedback from WB stage
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data),
        .imm(id_imm),
        .rd_idx(id_rd_idx)
    );

    // --- ID/EX Register ---
    id_ex_reg u_id_ex_reg (
        .clk(clk),
        .rst_n(rst_n),
        .flush(1'b0),               // No hazard unit yet
        .en(1'b1),
        // Data in
        .id_pc(id_pc),
        .id_pc_plus_4(id_pc_plus_4),
        .id_rs1_data(id_rs1_data),
        .id_rs2_data(id_rs2_data),
        .id_imm(id_imm),
        .id_rd_idx(id_rd_idx),
        .id_branch_func3(id_func3), 
        // Control in
        .id_BrUn(id_BrUn),
        .id_IsBranch(id_IsBranch),
        .id_IsJump(id_IsJump),
        .id_ASel(id_ASel),
        .id_BSel(id_BSel),
        .id_ALUSel(id_ALUSel),
        .id_MemRW(id_MemRW),
        .id_RegWEn(id_RegWEn),
        .id_WBSel(id_WBSel),
        
        // Data out
        .ex_pc(ex_pc),
        .ex_pc_plus_4(ex_pc_plus_4),
        .ex_rs1_data(ex_rs1_data),
        .ex_rs2_data(ex_rs2_data),
        .ex_imm(ex_imm),
        .ex_rd_idx(ex_rd_idx),
        .ex_branch_func3(ex_func3),
        // Control out
        .ex_BrUn(ex_BrUn),
        .ex_IsBranch(ex_IsBranch),
        .ex_IsJump(ex_IsJump),
        .ex_ASel(ex_ASel),
        .ex_BSel(ex_BSel),
        .ex_ALUSel(ex_ALUSel),
        .ex_MemRW(ex_MemRW),
        .ex_RegWEn(ex_RegWEn),
        .ex_WBSel(ex_WBSel)
    );
    // (Note: Add id_pc_plus_4 -> ex_pc_plus_4 inside id_ex_reg manually)


    // ==========================================
    // 4. EXECUTE (EX)
    // ==========================================
    stage_ex u_stage_ex (
        .pc(ex_pc),
        .rs1_data(ex_rs1_data),
        .rs2_data(ex_rs2_data),
        .imm(ex_imm),
        .ASel(ex_ASel),
        .BSel(ex_BSel),
        .ALUSel(ex_ALUSel),
        .BrUn(ex_BrUn),
        .IsBranch(ex_IsBranch),
        .IsJump(ex_IsJump),
        .branch_func3(ex_func3),
        .alu_out(ex_alu_out),
        .PCSel(ex_PCSel)           // Feedback to IF
    );

    // --- EX/MEM Register ---
    ex_mem_reg u_ex_mem_reg (
        .clk(clk),
        .rst_n(rst_n),
        .ex_alu_out(ex_alu_out),
        .ex_pc_plus_4(ex_pc_plus_4),
        .ex_rs2_data(ex_rs2_data),
        .ex_rd_idx(ex_rd_idx),
        .ex_func3(ex_func3),
        .ex_MemRW(ex_MemRW),
        .ex_RegWEn(ex_RegWEn),
        .ex_WBSel(ex_WBSel),
        
        .mem_alu_out(mem_alu_out),
        .mem_pc_plus_4(mem_pc_plus_4),
        .mem_rs2_data(mem_rs2_data),
        .mem_rd_idx(mem_rd_idx),
        .mem_func3(mem_func3),
        .mem_MemRW(mem_MemRW),
        .mem_RegWEn(mem_RegWEn),
        .mem_WBSel(mem_WBSel)
    );
    // (Note: Add ex_pc_plus_4 -> mem_pc_plus_4 inside ex_mem_reg manually)


    // ==========================================
    // 5. MEMORY (MEM)
    // ==========================================
    stage_mem #(
        .MEM_DEPTH(1024)
    ) u_stage_mem (
        .clk(clk),
        .alu_out(mem_alu_out),
        .rs2_data(mem_rs2_data),
        .func3(mem_func3),
        .MemRW(mem_MemRW),
        .mem_rd_raw(mem_rd_raw)
    );

    // --- MEM/WB Register ---
    mem_wb_reg u_mem_wb_reg (
        .clk(clk),
        .rst_n(rst_n),
        .mem_alu_out(mem_alu_out),
        .mem_rd_raw(mem_rd_raw),
        .mem_pc_plus_4(mem_pc_plus_4), // Make sure this traveled from ID!
        .mem_rd_idx(mem_rd_idx),
        .mem_func3(mem_func3),
        .mem_RegWEn(mem_RegWEn),
        .mem_WBSel(mem_WBSel),
        
        .wb_alu_out(wb_alu_out),
        .wb_rd_raw(wb_rd_raw),
        .wb_pc_plus_4(wb_pc_plus_4),
        .wb_rd_idx(wb_rd_idx),
        .wb_func3(wb_func3),
        .wb_RegWEn(wb_RegWEn),
        .wb_WBSel(wb_WBSel)
    );


    // ==========================================
    // 6. WRITE BACK (WB)
    // ==========================================
    stage_wb u_stage_wb (
        .wb_alu_out(wb_alu_out),
        .wb_rd_raw(wb_rd_raw),
        .wb_pc_plus_4(wb_pc_plus_4),
        .wb_func3(wb_func3),
        .wb_WBSel(wb_WBSel),
        .wb_wd(wb_wd)               // Feedback to ID
    );

endmodule