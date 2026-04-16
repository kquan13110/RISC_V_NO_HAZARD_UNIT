module imem #(
    parameter MEM_DEPTH = 1024
)(
    input wire [31:0] pc,
    output wire [31:0] inst
);

reg [31:0] memory [0:MEM_DEPTH-1];

// initial begin
//     // Load instructions from hexadecimal file
//     $readmemh("firmware.hex", memory);
// end

//Asynchronous read
wire [29:0] word_addr = pc[31:2];
assign inst = (word_addr < MEM_DEPTH) ? memory[word_addr] : 32'h0000_0000;
    
endmodule