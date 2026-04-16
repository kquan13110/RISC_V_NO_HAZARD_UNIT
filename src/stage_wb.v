module stage_wb (
    // Inputs from MEM/WB Register
    input wire [31:0] wb_alu_out,
    input wire [31:0] wb_rd_raw,
    input wire [31:0] wb_pc_plus_4,
    input wire [2:0]  wb_func3,
    input wire [1:0]  wb_WBSel,

    // Output to Register File (in Stage ID)
    output reg [31:0] wb_wd
);

    // 1. Data Extension for Loads
    wire [31:0] mem_extended_data;
    wire [1:0]  byte_offset = wb_alu_out[1:0]; // 2 LSB of address

    load_extend u_load_extend (
        .raw_data(wb_rd_raw),
        .offset(byte_offset),
        .func3(wb_func3),
        .ext_data(mem_extended_data)
    );

    // 2. Write Back Multiplexer (MUX)
    always @(*) begin
        case (wb_WBSel)
            2'b00: wb_wd = wb_alu_out;        // Arithmetic/Logic operations
            2'b01: wb_wd = mem_extended_data; // Load instructions
            2'b10: wb_wd = wb_pc_plus_4;      // JAL/JALR instructions
            default: wb_wd = 32'h0000_0000;
        endcase
    end

endmodule