module pc (
    input wire clk,
    input wire rst_n,
    input wire pc_en,
    input wire [31:0] pc_next,
    output reg [31:0] pc_out
);

always @(posedge clk) begin
    if (!rst_n) begin
        pc_out <= 32'h0000_0000;
    end else if (pc_en) begin
        pc_out <= pc_next;
    end
end
    
endmodule

