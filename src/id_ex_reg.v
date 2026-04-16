module id_ex_reg (
    input wire clk,
    input wire rst_n,
    
    // Hazard Control Signals
    input wire flush,  // Clear control signals (bubble)
    input wire en,     // Enable register (1 = run, 0 = stall)
    
    // ==========================================
    // 1. DATA INPUTS (From ID Stage)
    // ==========================================
    input wire [31:0] id_pc,
    input wire [31:0] id_pc_plus_4,   
    input wire [31:0] id_rs1_data,
    input wire [31:0] id_rs2_data,
    input wire [31:0] id_imm,
    input wire [4:0]  id_rd_idx,
    input wire [2:0]  id_branch_func3, // inst[14:12] for branch eval
    
    // ==========================================
    // 2. CONTROL INPUTS (From Control Unit)
    // ==========================================
    // EX Stage Controls
    input wire       id_BrUn,
    input wire       id_IsBranch,
    input wire       id_IsJump,
    input wire       id_ASel,
    input wire       id_BSel,
    input wire [3:0] id_ALUSel,
    
    // MEM Stage Controls
    input wire       id_MemRW,
    
    // WB Stage Controls
    input wire       id_RegWEn,
    input wire [1:0] id_WBSel,

    // ==========================================
    // 3. DATA OUTPUTS (To EX Stage)
    // ==========================================
    output reg [31:0] ex_pc,
    output reg [31:0] ex_pc_plus_4,    
    output reg [31:0] ex_rs1_data,
    output reg [31:0] ex_rs2_data,
    output reg [31:0] ex_imm,
    output reg [4:0]  ex_rd_idx,
    output reg [2:0]  ex_branch_func3,
    
    // ==========================================
    // 4. CONTROL OUTPUTS (To EX, MEM, WB Stages)
    // ==========================================
    output reg       ex_BrUn,
    output reg       ex_IsBranch,
    output reg       ex_IsJump,
    output reg       ex_ASel,
    output reg       ex_BSel,
    output reg [3:0] ex_ALUSel,
    output reg       ex_MemRW,
    output reg       ex_RegWEn,
    output reg [1:0] ex_WBSel
);

// Synchronous update
always @(posedge clk) begin
    if (!rst_n || flush) begin
        // On reset or flush, we strictly disable all write/branch operations.
        // Data fields can optionally be zeroed out for cleaner waveforms.
        ex_pc           <= 32'h0;
        ex_pc_plus_4    <= 32'h0;      
        ex_rs1_data     <= 32'h0;
        ex_rs2_data     <= 32'h0;
        ex_imm          <= 32'h0;
        ex_rd_idx       <= 5'h0;
        ex_branch_func3 <= 3'h0;
        
        ex_BrUn         <= 1'b0;
        ex_IsBranch     <= 1'b0; // Prevent ghost branches
        ex_IsJump       <= 1'b0; // Prevent ghost jumps
        ex_ASel         <= 1'b0;
        ex_BSel         <= 1'b0;
        ex_ALUSel       <= 4'b0000;
        ex_MemRW        <= 1'b0; // Prevent memory corruption
        ex_RegWEn       <= 1'b0; // Prevent regfile corruption
        ex_WBSel        <= 2'b00;
    end 
    else if (en) begin
        // Normal operation: Pass all signals to the next stage
        ex_pc           <= id_pc;
        ex_pc_plus_4    <= id_pc_plus_4; 
        ex_rs1_data     <= id_rs1_data;
        ex_rs2_data     <= id_rs2_data;
        ex_imm          <= id_imm;
        ex_rd_idx       <= id_rd_idx;
        ex_branch_func3 <= id_branch_func3;
        
        ex_BrUn         <= id_BrUn;
        ex_IsBranch     <= id_IsBranch;
        ex_IsJump       <= id_IsJump;
        ex_ASel         <= id_ASel;
        ex_BSel         <= id_BSel;
        ex_ALUSel       <= id_ALUSel;
        ex_MemRW        <= id_MemRW;
        ex_RegWEn       <= id_RegWEn;
        ex_WBSel        <= id_WBSel;
    end
end
    
endmodule