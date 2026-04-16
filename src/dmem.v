module dmem #(
    parameter WORD_DEPTH = 1024 // 1024 words = 4096 bytes
)(
    input wire clk,
    input wire we,
    input wire [1:0] size,
    input wire [31:0] addr,
    input wire [31:0] wd,
    output wire [31:0] rd
);

reg [31:0] memory [0:WORD_DEPTH-1];
wire [29:0] word_addr = addr[31:2];

integer i;
initial begin
    for (i = 0; i < WORD_DEPTH; i = i + 1) begin
        memory[i] = 32'h0000_0000;
    end
end

// Asynchronous Read
assign rd = memory[word_addr];

// Synchronous Write
always @(posedge clk) begin
    if (we) begin
        case (size)
            //word
            2'b10: begin 
                memory[word_addr] <= wd;
            end
            //halfword
            2'b01: begin 
                if (addr[1] == 1'b0) // Căn lề nửa dưới
                    memory[word_addr][15:0]  <= wd[15:0];
                else                 // Căn lề nửa trên
                    memory[word_addr][31:16] <= wd[15:0];
            end
            //byte
            2'b00: begin 
                case (addr[1:0])
                    2'b00: memory[word_addr][7:0]   <= wd[7:0];
                    2'b01: memory[word_addr][15:8]  <= wd[7:0];
                    2'b10: memory[word_addr][23:16] <= wd[7:0];
                    2'b11: memory[word_addr][31:24] <= wd[7:0];
                endcase
            end
            
            default: memory[word_addr] <= 32'h0000_0000; 
        endcase
    end
end

endmodule