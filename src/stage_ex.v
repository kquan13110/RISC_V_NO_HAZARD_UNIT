module stage_ex (
    // Data inputs from ID/EX Register
    input wire [31:0] pc,
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire [31:0] imm,

    // Control signals for ALU
    input wire ASel,
    input wire BSel,
    input wire [3:0] ALUSel,
    
    // Control signals for Branch Logic
    input wire BrUn,
    input wire IsBranch,           // 1 if BEQ, BNE, BLT...
    input wire IsJump,             // 1 if JAL, JALR
    input wire [2:0] branch_func3, // inst[14:12] passed from ID

    // Outputs
    output wire [31:0] alu_out,    // Data result OR Branch Target
    output reg PCSel               // Goes back to IF stage
);

    // MUXes for ALU inputs
    wire [31:0] alu_A = ASel ? pc : rs1_data;
    wire [31:0] alu_B = BSel ? imm : rs2_data;

    // 1. ALU
    alu u_alu (
        .A(alu_A),
        .B(alu_B),
        .alu_sel(ALUSel),
        .out(alu_out)
    );

    // 2. Branch Comparator
    wire BrEq, BrLT;
    branch_comp u_branch_comp (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .BrUn(BrUn),
        .BrEq(BrEq),
        .BrLT(BrLT)
    );

    // 3. Branch Target Logic (PCSel Evaluation)
    always @(*) begin
        if (IsJump) begin
            PCSel = 1'b1; // Always jump
        end 
        else if (IsBranch) begin
            // Evaluate condition
            case (branch_func3)
                3'b000: PCSel = BrEq;  // BEQ
                3'b001: PCSel = ~BrEq; // BNE
                3'b100: PCSel = BrLT;  // BLT
                3'b101: PCSel = ~BrLT; // BGE
                3'b110: PCSel = BrLT;  // BLTU
                3'b111: PCSel = ~BrLT; // BGEU
                default: PCSel = 1'b0;
            endcase
        end 
        else begin
            PCSel = 1'b0; // Normal instructions
        end
    end

endmodule