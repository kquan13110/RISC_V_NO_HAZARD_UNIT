module load_extend (
    input wire [31:0] raw_data, // 32-bit word from DMEM
    input wire [1:0] offset,    // addr[1:0] from CPU
    input wire [2:0] func3,     // Instruction func3
    output reg [31:0] ext_data
);

// Internal signals for extracted data
reg [7:0] byte_data;
reg [15:0] half_data;

// Extract correct Byte
always @(*) begin
    case (offset)
        2'b00: byte_data = raw_data[7:0];
        2'b01: byte_data = raw_data[15:8];
        2'b10: byte_data = raw_data[23:16];
        2'b11: byte_data = raw_data[31:24];
    endcase
end

// Extract correct Half-word
always @(*) begin
    if (offset[1] == 1'b0)
        half_data = raw_data[15:0];
    else
        half_data = raw_data[31:16];
end

// Sign/Zero Extend
always @(*) begin
    case (func3)
        3'b000: ext_data = {{24{byte_data[7]}}, byte_data};   // LB
        3'b001: ext_data = {{16{half_data[15]}}, half_data};  // LH
        3'b010: ext_data = raw_data;                          // LW
        3'b100: ext_data = {24'b0, byte_data};                // LBU
        3'b101: ext_data = {16'b0, half_data};                // LHU
        default: ext_data = 32'h0000_0000;                    // Default
    endcase
end
    
endmodule