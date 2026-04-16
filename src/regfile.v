module regfile (
    input wire clk,
    input wire we,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,
    input wire [31:0] wd,
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
    //32 - 32 bit registers
    reg [31:0] registers [31:0];
    //
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'h0000_0000;
        end
    end

    //asynchronous read
    assign rd1 = (rs1 == 5'd0) ? 32'h0000_0000 : registers[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'h0000_0000 : registers[rs2];

    //synchronous write
    always @(posedge clk) begin
        if (we && rd != 5'd0) begin
            registers[rd] <= wd;
        end
    end
endmodule

