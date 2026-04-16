module branch_comp (
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire BrUn,
    output wire BrEq,
    output wire BrLT
);

//Equality Check
assign BrEq = (rs1_data == rs2_data);

//Less Than Check
assign BrLT = (BrUn) ? (rs1_data < rs2_data) : ($signed(rs1_data) < $signed(rs2_data));

endmodule