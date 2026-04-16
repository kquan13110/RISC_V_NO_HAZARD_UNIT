module ex_mem_reg (
    input wire clk,
    input wire rst_n,

    // Data Inputs (From EX Stage)
    input wire [31:0] ex_alu_out,
    input wire [31:0] ex_pc_plus_4, // DÂY MỚI THÊM
    input wire [31:0] ex_rs2_data,
    input wire [4:0]  ex_rd_idx,
    input wire [2:0]  ex_func3,     

    // Control Inputs (From ID/EX Register)
    input wire       ex_MemRW,
    input wire       ex_RegWEn,
    input wire [1:0] ex_WBSel,

    // Data Outputs (To MEM Stage)
    output reg [31:0] mem_alu_out,
    output reg [31:0] mem_pc_plus_4, // DÂY MỚI THÊM
    output reg [31:0] mem_rs2_data,
    output reg [4:0]  mem_rd_idx,
    output reg [2:0]  mem_func3,

    // Control Outputs (To MEM & WB Stages)
    output reg       mem_MemRW,
    output reg       mem_RegWEn,
    output reg [1:0] mem_WBSel
);

always @(posedge clk) begin
    if (!rst_n) begin
        mem_alu_out   <= 32'h0;
        mem_pc_plus_4 <= 32'h0;      // RESET
        mem_rs2_data  <= 32'h0;
        mem_rd_idx    <= 5'h0;
        mem_func3     <= 3'h0;
        mem_MemRW     <= 1'b0;
        mem_RegWEn    <= 1'b0;
        mem_WBSel     <= 2'b00;
    end else begin
        mem_alu_out   <= ex_alu_out;
        mem_pc_plus_4 <= ex_pc_plus_4; // TRUYỀN ĐI TIẾP
        mem_rs2_data  <= ex_rs2_data;
        mem_rd_idx    <= ex_rd_idx;
        mem_func3     <= ex_func3;
        mem_MemRW     <= ex_MemRW;
        mem_RegWEn    <= ex_RegWEn;
        mem_WBSel     <= ex_WBSel;
    end
end
endmodule