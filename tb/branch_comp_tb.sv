`timescale 1ns / 1ps

module tb_branch_comp();

    // Signals
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic        BrUn;
    logic        BrEq;
    logic        BrLT;

    // Instantiate DUT
    branch_comp uut (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .BrUn(BrUn),
        .BrEq(BrEq),
        .BrLT(BrLT)
    );

    // Helper task to check results
    task check_result(input string test_name, input logic exp_BrEq, input logic exp_BrLT);
        #1; // Wait for combinational logic
        if ((BrEq === exp_BrEq) && (BrLT === exp_BrLT)) begin
            $display("[PASS] %s | BrEq: %b, BrLT: %b", test_name, BrEq, BrLT);
        end else begin
            $error("[FAIL] %s | Expected: BrEq=%b, BrLT=%b | Got: BrEq=%b, BrLT=%b", 
                    test_name, exp_BrEq, exp_BrLT, BrEq, BrLT);
        end
        #9; // Align to 10ns grid
    endtask

    initial begin
        $display("=== STARTING BRANCH COMPARATOR TEST ===");

        // 1. Test Equality
        rs1_data = 32'd100; rs2_data = 32'd100; BrUn = 1'b0; // Signed
        check_result("Equal (Signed)     ", 1'b1, 1'b0);

        // 2. Test Signed Less Than (rs1 is negative, rs2 is positive)
        rs1_data = 32'hFFFF_FFFF; // -1
        rs2_data = 32'h0000_0005; // 5
        BrUn = 1'b0;              // Signed comparison (-1 < 5 -> True)
        check_result("Less Than (Signed) ", 1'b0, 1'b1);

        // 3. Test Unsigned Less Than with same data
        // 0xFFFFFFFF (4,294,967,295) vs 0x00000005 (5)
        BrUn = 1'b1;              // Unsigned comparison (4294967295 < 5 -> False)
        check_result("Less Than (Unsigned)", 1'b0, 1'b0);

        // 4. Test Signed Greater Than
        rs1_data = 32'd20; rs2_data = 32'd10; BrUn = 1'b0;
        check_result("Greater Than (Sign)", 1'b0, 1'b0);

        // 5. Test negative numbers comparison
        rs1_data = 32'hFFFF_FFF6; // -10
        rs2_data = 32'hFFFF_FFFB; // -5
        BrUn = 1'b0;              // -10 < -5 -> True
        check_result("Neg vs Neg (Signed)", 1'b0, 1'b1);

        $display("=== TEST FINISHED ===");
        $finish;
    end

endmodule