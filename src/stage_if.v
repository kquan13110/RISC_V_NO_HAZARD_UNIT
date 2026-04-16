module stage_if #(
    parameter MEM_DEPTH = 1024
)(
    input wire clk,
    input wire rst_n,
    input wire pc_en,         // Stall control from Hazard Unit
    input wire PCSel,         // Branch/Jump control
    input wire [31:0] alu_target, 

    output wire [31:0] inst,
    output wire [31:0] pc_out,     
    output wire [31:0] pc_plus_4
);

    wire [31:0] pc_next;

    // Next PC logic
    assign pc_plus_4 = pc_out + 32'd4;
    assign pc_next = PCSel ? alu_target : pc_plus_4;
    
    // PC Register instantiation
    pc u_pc (
        .clk(clk),
        .rst_n(rst_n),
        .pc_en(pc_en),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    // Instruction Memory instantiation
    imem #(
        .MEM_DEPTH(MEM_DEPTH)
    ) u_imem (
        .pc(pc_out),
        .inst(inst)
    );

endmodule