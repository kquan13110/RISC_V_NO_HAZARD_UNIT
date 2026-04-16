`timescale 1ns / 1ps

module tb_load_extend();

    // Signals
    logic [31:0] raw_data;
    logic [2:0]  func3;
    logic [31:0] ext_data;

    // Instantiate DUT
    load_extend uut (
        .raw_data(raw_data),
        .func3(func3),
        .ext_data(ext_data)
    );

    // Encodings mapping
    localparam F3_LB  = 3'b000;
    localparam F3_LH  = 3'b001;
    localparam F3_LW  = 3'b010;
    localparam F3_LBU = 3'b100;
    localparam F3_LHU = 3'b101;

    // Helper task to check results
    task check_result(input string op_name, input logic [31:0] expected);
        #1; // Delay for combinational evaluation
        if (ext_data === expected) begin
            $display("[PASS] %s | Raw: 0x%08h -> Ext: 0x%08h", op_name, raw_data, ext_data);
        end else begin
            $error("[FAIL] %s | Raw: 0x%08h | Expected: 0x%08h | Got: 0x%08h", 
                    op_name, raw_data, expected, ext_data);
        end
        #9;
    endtask

    initial begin
        $display("=== STARTING LOAD EXTENSION TEST ===");

        // Simulate reading a memory word that contains negative values in the lower bytes
        // For example, raw_data = 0x1234_F688
        // Byte 0: 0x88 (Negative if signed, msb=1)
        // Half 0: 0xF688 (Negative if signed, msb=1)
        raw_data = 32'h1234_F688;

        // 1. Test Load Byte (LB)
        // Should extract 0x88 and sign-extend -> 0xFFFF_FF88
        func3 = F3_LB;
        check_result("LB  ", 32'hFFFF_FF88);

        // 2. Test Load Byte Unsigned (LBU)
        // Should extract 0x88 and zero-extend -> 0x0000_0088
        func3 = F3_LBU;
        check_result("LBU ", 32'h0000_0088);

        // 3. Test Load Half-word (LH)
        // Should extract 0xF688 and sign-extend -> 0xFFFF_F688
        func3 = F3_LH;
        check_result("LH  ", 32'hFFFF_F688);

        // 4. Test Load Half-word Unsigned (LHU)
        // Should extract 0xF688 and zero-extend -> 0x0000_F688
        func3 = F3_LHU;
        check_result("LHU ", 32'h0000_F688);

        // 5. Test Load Word (LW)
        // Should pass the data through unmodified
        func3 = F3_LW;
        check_result("LW  ", 32'h1234_F688);

        $display("=== TEST FINISHED ===");
        $finish;
    end

endmodule