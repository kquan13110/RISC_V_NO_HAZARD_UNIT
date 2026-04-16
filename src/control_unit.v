module control_unit (
    input wire [31:0] inst,
    
    // Outputs for Stage ID (Data Path)
    output reg [2:0] ImmSel,
    
    // Outputs for Pipeline Registers (passed to EX, MEM, WB)
    output reg RegWEn,
    output reg BrUn,
    output reg IsBranch,       // 1 if BEQ, BNE, BLT...
    output reg IsJump,         // 1 if JAL, JALR
    output reg ASel,
    output reg BSel,
    output reg [3:0] ALUSel,
    output reg MemRW,
    output reg [1:0] WBSel
);

// Extract fields from instruction
wire [6:0] opcode = inst[6:0];
wire [2:0] func3 = inst[14:12];
wire funct7_5 = inst[30]; // Distinguish ADD/SUB and SRL/SRA

// Opcode decoding
localparam R_TYPE = 7'b0110011;
localparam I_TYPE = 7'b0010011;
localparam LOAD   = 7'b0000011;
localparam STORE  = 7'b0100011;
localparam BRANCH = 7'b1100011;
localparam JAL    = 7'b1101111;
localparam JALR   = 7'b1100111;
localparam LUI    = 7'b0110111;
localparam AUIPC  = 7'b0010111;
  
// ALU Operation encoding
localparam ALU_ADD = 4'b0000;
localparam ALU_SUB = 4'b0001;
localparam ALU_SLL = 4'b0010;
localparam ALU_SLT = 4'b0011;
localparam ALU_SLTU = 4'b0100;
localparam ALU_XOR = 4'b0101;
localparam ALU_SRL = 4'b0110;
localparam ALU_SRA = 4'b0111;
localparam ALU_OR  = 4'b1000;
localparam ALU_AND = 4'b1001;
localparam ALU_PASSB = 4'b1010; // For JALR/LUI

// Main control logic
always @(*) begin
    // 1. Default assignments to prevent latches
    ImmSel   = 3'b000;
    RegWEn   = 1'b0;
    BrUn     = 1'b0;
    IsBranch = 1'b0;
    IsJump   = 1'b0;
    ASel     = 1'b0;
    BSel     = 1'b0;
    ALUSel   = ALU_ADD;
    MemRW    = 1'b0;
    WBSel    = 2'b00;

    // 2. Decode logic
    case (opcode)
        R_TYPE: begin
            RegWEn = 1'b1;
            case (func3)
                3'b000: ALUSel = funct7_5 ? ALU_SUB : ALU_ADD; 
                3'b001: ALUSel = ALU_SLL; 
                3'b010: ALUSel = ALU_SLT; 
                3'b011: ALUSel = ALU_SLTU; 
                3'b100: ALUSel = ALU_XOR; 
                3'b101: ALUSel = funct7_5 ? ALU_SRA : ALU_SRL; 
                3'b110: ALUSel = ALU_OR; 
                3'b111: ALUSel = ALU_AND; 
                default: ALUSel = ALU_ADD;
            endcase
        end
        
        I_TYPE: begin
            RegWEn = 1'b1;
            BSel = 1'b1; // Use immediate
            ImmSel = 3'b000;
            case (func3)
                3'b000: ALUSel = ALU_ADD; // ADDI
                3'b001: ALUSel = ALU_SLL; // SLLI
                3'b010: ALUSel = ALU_SLT; // SLTI
                3'b011: ALUSel = ALU_SLTU; // SLTIU
                3'b100: ALUSel = ALU_XOR; // XORI
                3'b101: ALUSel = funct7_5 ? ALU_SRA : ALU_SRL; // SRLI/SRAI
                3'b110: ALUSel = ALU_OR; // ORI
                3'b111: ALUSel = ALU_AND; // ANDI
                default: ALUSel = ALU_ADD;
            endcase
        end
        
        LOAD: begin
            RegWEn = 1'b1;
            BSel = 1'b1; 
            ImmSel = 3'b000; 
            ALUSel = ALU_ADD; 
            WBSel = 2'b01; // Data from Memory
        end
        
        STORE: begin
            MemRW = 1'b1;
            BSel = 1'b1; 
            ImmSel = 3'b001; 
            ALUSel = ALU_ADD; 
        end
        
        BRANCH: begin
            IsBranch = 1'b1; // Signal EX stage to evaluate branch
            ASel = 1'b1;     // ALU A = PC
            BSel = 1'b1;     // ALU B = imm
            ImmSel = 3'b010; 
            ALUSel = ALU_ADD; // Calculate PC + imm
            
            if (func3 == 3'b110 || func3 == 3'b111) begin
                BrUn = 1'b1; // Unsigned comparison (BLTU, BGEU)
            end
        end
        
        JAL: begin
            IsJump = 1'b1;   // Signal EX stage to jump
            RegWEn = 1'b1;
            ASel = 1'b1;     // ALU A = PC
            BSel = 1'b1;     // ALU B = imm
            ImmSel = 3'b100; 
            ALUSel = ALU_ADD; 
            WBSel = 2'b10;   // Data = PC + 4
        end
        
        JALR: begin
            IsJump = 1'b1;   // Signal EX stage to jump
            RegWEn = 1'b1;
            // ASel = 0 by default (ALU A = rs1)
            BSel = 1'b1;     // ALU B = imm
            ImmSel = 3'b000; 
            ALUSel = ALU_ADD; // Calculate rs1 + imm
            WBSel = 2'b10;   // Data = PC + 4
        end
        
        LUI: begin
            RegWEn = 1'b1;
            BSel = 1'b1; 
            ImmSel = 3'b011; 
            ALUSel = ALU_PASSB; // Pass imm through ALU
        end
        
        AUIPC: begin
            RegWEn = 1'b1;
            ASel = 1'b1; 
            BSel = 1'b1; 
            ImmSel = 3'b011; 
            ALUSel = ALU_ADD; // Calculate PC + imm
        end
        
        default: begin
            // Relies on default signal assignments at the top
        end
    endcase
end
endmodule