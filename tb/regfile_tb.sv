`timescale 1ns / 1ps

module tb_regfile();

    // Testbench signals
    logic        clk;
    logic        we;
    logic [4:0]  rs1, rs2, rd;
    logic [31:0] wd;
    logic [31:0] rd1, rd2;

    // Instantiate Device Under Test (DUT)
    regfile uut (
        .clk(clk),
        .we(we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Clock generation (10ns period -> 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Helper task to check read results
    task check_read(input string test_name, input logic [31:0] exp1, input logic [31:0] exp2);
        #1; // Small delay to allow combinational logic to settle
        if ((rd1 === exp1) && (rd2 === exp2)) begin
            $display("[PASS] %s | rd1: 0x%0h, rd2: 0x%0h", test_name, rd1, rd2);
        end else begin
            $error("[FAIL] %s | Expected: 0x%0h, 0x%0h | Got: 0x%0h, 0x%0h", 
                    test_name, exp1, exp2, rd1, rd2);
        end
    endtask

    // Test Sequence
    initial begin
        $display("=== STARTING REGFILE TEST ===");

        // 1. Initialize inputs
        we = 0; rs1 = 0; rs2 = 0; rd = 0; wd = 0;
        @(negedge clk); // Wait for the falling edge to safely change inputs

        // 2. Test Write to standard registers (Write to x5 and x10)
        rd = 5'd5; wd = 32'hDEADBEEF; we = 1;
        @(negedge clk); // Advance one clock cycle
        
        rd = 5'd10; wd = 32'hCAFEBABE; we = 1;
        @(negedge clk);
        we = 0; // Turn off write enable

        // 3. Test Asynchronous Read (Read x5 and x10)
        rs1 = 5'd5; rs2 = 5'd10;
        check_read("Read Standard Registers", 32'hDEADBEEF, 32'hCAFEBABE);

        // 4. Test x0 Immutability (Attempt to write to x0)
        rd = 5'd0; wd = 32'hFFFFFFFF; we = 1;
        @(negedge clk);
        we = 0;
        
        // Read x0 to ensure it is still 0
        rs1 = 5'd0; rs2 = 5'd0;
        check_read("Read x0 (Should be 0)  ", 32'h00000000, 32'h00000000);

        // 5. Test Read and Write simultaneously (Forwarding test context)
        // Write to x6 while reading x6. Since read is async and write is sync, 
        // read should output the OLD value until the next clock edge.
        rd = 5'd6; wd = 32'h11223344; we = 1;
        rs1 = 5'd6;
        check_read("Read before Clock Edge ", 32'h00000000, 32'h00000000); // Should be 0 (old value)
        
        @(negedge clk);
        check_read("Read after Clock Edge  ", 32'h11223344, 32'h00000000); // Should now be updated

        $display("=== TEST FINISHED ===");
        $finish;
    end

endmodule