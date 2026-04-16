`timescale 1ns / 1ps

module tb_alu();

    // Testbench signals
    logic [31:0] A;
    logic [31:0] B;
    logic [3:0]  alu_sel;
    logic [31:0] out;

    // Instantiate DUT
    alu uut (
        .A(A),
        .B(B),
        .alu_sel(alu_sel),
        .out(out)
    );

    // ALU Operation Codes mapped from the module
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_SLL  = 4'b0010;
    localparam ALU_SLT  = 4'b0011;
    localparam ALU_SLTU = 4'b0100;
    localparam ALU_XOR  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_OR   = 4'b1000;
    localparam ALU_AND  = 4'b1001;

    // Helper task to check ALU results
    task check_result(input string op_name, input logic [31:0] expected);
        #1; // Allow time for combinational logic
        if (out === expected) begin
            $display("[PASS] %s | A: 0x%08h, B: 0x%08h -> Out: 0x%08h", op_name, A, B, out);
        end else begin
            $error("[FAIL] %s | Expected: 0x%08h | Got: 0x%08h", op_name, expected, out);
        end
        #9; // Padding to align with 10ns visual steps
    endtask

    initial begin
        $display("=== STARTING ALU TEST ===");

        // 1. ADD / SUB
        A = 32'd15; B = 32'd10; alu_sel = ALU_ADD;
        check_result("ADD ", 32'd25);

        A = 32'd15; B = 32'd20; alu_sel = ALU_SUB;
        // 15 - 20 = -5 (Two's complement: 0xFFFFFFFB)
        check_result("SUB ", 32'hFFFF_FFFB);

        // 2. Logic Operations
        A = 32'h0000_FFFF; B = 32'h0FFF_0000; alu_sel = ALU_OR;
        check_result("OR  ", 32'h0FFF_FFFF);

        A = 32'h1234_5678; B = 32'hFFFF_FFFF; alu_sel = ALU_XOR;
        check_result("XOR ", 32'hEDCB_A987);

        // 3. Shift Operations
        A = 32'hFFFF_0000; B = 32'd8; alu_sel = ALU_SRL;
        check_result("SRL ", 32'h00FF_FF00); // Zeros shifted in from left

        A = 32'hFFFF_0000; B = 32'd8; alu_sel = ALU_SRA;
        check_result("SRA ", 32'hFFFF_FF00); // Sign bit (1) shifted in from left

        // 4. Set Less Than (Crucial test for Signed vs Unsigned)
        // A = -1 (0xFFFFFFFF), B = 1 (0x00000001)
        A = 32'hFFFF_FFFF; B = 32'h0000_0001; 
        
        // As Signed: -1 < 1 (True -> 1)
        alu_sel = ALU_SLT;
        check_result("SLT ", 32'd1);

        // As Unsigned: 0xFFFFFFFF < 0x00000001 (False -> 0)
        alu_sel = ALU_SLTU;
        check_result("SLTU", 32'd0);

        $display("=== TEST FINISHED ===");
        $finish;
    end

endmodule