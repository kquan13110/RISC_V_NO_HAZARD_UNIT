module stage_id (
    input wire clk,

    // Inputs
    input wire [31:0] inst,
    input wire [2:0] ImmSel,  // From Control Unit
    input wire wb_we,
    input wire [4:0] wb_rd,
    input wire [31:0] wb_wd,

    // Outputs to ID/EX Register
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data,
    output wire [31:0] imm,
    output wire [4:0] rd_idx
);

    // Extract fields
    wire [4:0] rs1_idx = inst[19:15];
    wire [4:0] rs2_idx = inst[24:20];
    assign rd_idx      = inst[11:7];

    // 1. Register File
    regfile u_regfile (
        .clk(clk),
        .we(wb_we),
        .rs1(rs1_idx),
        .rs2(rs2_idx),
        .rd(wb_rd),
        .wd(wb_wd),
        .rd1(rs1_data),
        .rd2(rs2_data)
    );

    // 2. Immediate Generator
    imm_gen u_imm_gen (
        .inst(inst),
        .imm_sel(ImmSel),
        .imm_out(imm)
    );

endmodule