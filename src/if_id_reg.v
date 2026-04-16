module if_id_reg (
    input wire clk,
    input wire rst_n,
    
    // Hazard Control Signals
    input wire flush,  // Clear register (e.g., when branch is taken)
    input wire en,     // Enable register (set to 0 to stall)
    
    // Inputs from IF stage
    input wire [31:0] if_pc,
    input wire [31:0] if_inst,
    input wire [31:0] if_pc_plus_4,
    
    // Outputs to ID stage
    output reg [31:0] id_pc,
    output reg [31:0] id_inst,
    output reg [31:0] id_pc_plus_4
);

// Synchronous update
always @(posedge clk) begin
    if (!rst_n || flush) begin
        // Reset or Flush: Inject NOP instruction (addi x0, x0, 0)
        id_pc        <= 32'h0000_0000;
        id_inst      <= 32'h0000_0013; // RISC-V NOP
        id_pc_plus_4 <= 32'h0000_0000;
    end 
    else if (en) begin
        // Normal operation: Pass data to next stage
        id_pc        <= if_pc;
        id_inst      <= if_inst;
        id_pc_plus_4 <= if_pc_plus_4;
    end
end
    
endmodule