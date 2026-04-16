`timescale 1ns/1ps

module tb_dmem;

    // Signal declarations
    reg clk;
    reg we;
    reg [1:0] size;
    reg [31:0] addr;
    reg [31:0] wd;
    wire [31:0] rd;

    // Instantiate UUT
    dmem #(
        .WORD_DEPTH(1024)
    ) uut (
        .clk(clk),
        .we(we),
        .size(size),
        .addr(addr),
        .wd(wd),
        .rd(rd)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task for automatic checking
    task check_result;
        input [31:0] expected_rd;
        input [80*8:1] test_name;
        begin
            #1; // Wait for combinational read
            if (rd === expected_rd) begin
                $display("[PASS] %s: addr=%0d -> rd=%h", test_name, addr, rd);
            end else begin
                $display("[FAIL] %s: addr=%0d -> Expected %h, Got %h", test_name, addr, expected_rd, rd);
            end
            #9;
        end
    endtask

    initial begin
        // Initialize
        clk = 0;
        we = 0;
        size = 2'b00;
        addr = 32'd0;
        wd = 32'd0;

        #15; // Wait out initial reset phase
        
        $display("========================================");
        $display("      STARTING DMEM SIMULATION          ");
        $display("========================================");

        // ------------------------------------------------
        // TEST 1: Word Write and Read (size = 10)
        // ------------------------------------------------
        @(negedge clk);
        we = 1; size = 2'b10; addr = 32'd4; wd = 32'hDEAD_BEEF;
        @(posedge clk); #1; // Wait for write to complete
        
        @(negedge clk);
        we = 0; addr = 32'd4; // Read from same address
        check_result(32'hDEAD_BEEF, "Test 1 (Word Write/Read)");

        // ------------------------------------------------
        // TEST 2: Byte Writes into an empty Word
        // ------------------------------------------------
        // Write byte 0xAA to address 8
        @(negedge clk);
        we = 1; size = 2'b00; addr = 32'd8; wd = 32'h0000_00AA;
        @(posedge clk);
        
        // Write byte 0xBB to address 9
        @(negedge clk);
        we = 1; size = 2'b00; addr = 32'd9; wd = 32'h0000_00BB;
        @(posedge clk);
        
        // Write byte 0xCC to address 10
        @(negedge clk);
        we = 1; size = 2'b00; addr = 32'd10; wd = 32'h0000_00CC;
        @(posedge clk);

        // Read the full word at address 8
        @(negedge clk);
        we = 0; addr = 32'd8; 
        // Expected: 0x00CCBBAA (Little Endian: AA is LSB, CC is byte 2, 00 is MSB)
        check_result(32'h00CC_BBAA, "Test 2 (Byte Writes Check)");

        // ------------------------------------------------
        // TEST 3: Half-Word Overwrite
        // ------------------------------------------------
        // Overwrite the upper half-word of address 8 with 0xFFFF
        @(negedge clk);
        we = 1; size = 2'b01; addr = 32'd10; wd = 32'h0000_FFFF;
        @(posedge clk);

        // Read the full word at address 8 again
        @(negedge clk);
        we = 0; addr = 32'd8; 
        // Expected: 0xFFFFBBAA
        check_result(32'hFFFF_BBAA, "Test 3 (Half-Word Overwrite)");

        $display("========================================");
        $display("         SIMULATION FINISHED            ");
        $display("========================================");
        $finish;
    end

endmodule