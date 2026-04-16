module alu (
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [3:0] alu_sel,
    output reg [31:0] out
);

//define ALU operations
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
localparam ALU_PASSB = 4'b1010; //For LUI

always @(A or B or alu_sel) begin
    case (alu_sel)
        ALU_ADD: out = A + B;
        ALU_SUB: out = A - B;

        // Shift operations
        ALU_SLL: out = A << B[4:0];
        ALU_SRL: out = A >> B[4:0];
        
        // Arithmetic Shift Right
        ALU_SRA: out = $signed(A) >>> B[4:0];

        //Comparison operations
        ALU_SLT: out = ($signed(A) < $signed(B)) ? 32'h1 : 32'h0;

        //Unsigned comparison
        ALU_SLTU: out = (A < B) ? 32'h1 : 32'h0;
        
        ALU_XOR: out = A ^ B;
        ALU_OR: out = A | B;
        ALU_AND: out = A & B;

        ALU_PASSB: out = B; //For LUI, pass immediate directly to output
        
        default: out = 32'h0;
    endcase
end
    
endmodule