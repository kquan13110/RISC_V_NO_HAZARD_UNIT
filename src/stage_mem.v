module stage_mem #(
    parameter MEM_DEPTH = 1024
)(
    input wire clk,

    // Data Inputs from EX/MEM Register
    input wire [31:0] alu_out,    // Memory Address
    input wire [31:0] rs2_data,   // Write Data (for Store instructions)
    input wire [2:0]  func3,      // To determine load/store size

    // Control Inputs
    input wire MemRW,

    // Data Outputs
    output wire [31:0] mem_rd_raw // Raw data read from memory
);

    // Convert func3 to size for dmem
    // LB/SB: 000 -> 00
    // LH/SH: 001 -> 01
    // LW/SW: 010 -> 10
    wire [1:0] dmem_size = func3[1:0];

    // Data Memory Instantiation
    dmem #(
        .WORD_DEPTH(MEM_DEPTH)
    ) u_dmem (
        .clk(clk),
        .we(MemRW),
        .size(dmem_size),
        .addr(alu_out),
        .wd(rs2_data),
        .rd(mem_rd_raw)
    );

endmodule