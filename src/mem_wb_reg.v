module mem_wb_reg (
    input wire clk,
    input wire rst_n,

    // Data Inputs (From MEM Stage)
    input wire [31:0] mem_alu_out,
    input wire [31:0] mem_rd_raw,   // Raw data from Data Memory
    input wire [31:0] mem_pc_plus_4,// Required for JAL/JALR
    input wire [4:0]  mem_rd_idx,
    input wire [2:0]  mem_func3,    // Required for load_extend

    // Control Inputs (From EX/MEM Register)
    input wire       mem_RegWEn,
    input wire [1:0] mem_WBSel,

    // Data Outputs (To WB Stage)
    output reg [31:0] wb_alu_out,
    output reg [31:0] wb_rd_raw,
    output reg [31:0] wb_pc_plus_4,
    output reg [4:0]  wb_rd_idx,
    output reg [2:0]  wb_func3,

    // Control Outputs (To WB Stage & ID Stage)
    output reg       wb_RegWEn,
    output reg [1:0] wb_WBSel
);

always @(posedge clk) begin
    if (!rst_n) begin
        wb_alu_out   <= 32'h0;
        wb_rd_raw    <= 32'h0;
        wb_pc_plus_4 <= 32'h0;
        wb_rd_idx    <= 5'h0;
        wb_func3     <= 3'h0;
        wb_RegWEn    <= 1'b0;
        wb_WBSel     <= 2'b00;
    end else begin
        wb_alu_out   <= mem_alu_out;
        wb_rd_raw    <= mem_rd_raw;
        wb_pc_plus_4 <= mem_pc_plus_4;
        wb_rd_idx    <= mem_rd_idx;
        wb_func3     <= mem_func3;
        wb_RegWEn    <= mem_RegWEn;
        wb_WBSel     <= mem_WBSel;
    end
end

endmodule