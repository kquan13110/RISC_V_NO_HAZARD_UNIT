`timescale 1ns/1ps

module tb_pc2;

    // Signal declarations
    reg clk;
    reg rst_n;
    reg [31:0] pc_next;
    wire [31:0] pc_out;

    // Instantiate the pc module (Unit Under Test)
    pc uut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    // Generate clock signal (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        pc_next = 32'h0000_0000;

        // System reset
        #15 rst_n = 1;
        
        // ==========================================
        // 1. AUTOMATED TEST SEQUENCE
        // ==========================================
        $display("========================================");
        $display("       RUNNING AUTOMATED TESTS          ");
        $display("========================================");

        // Auto Test 1: Normal PC increment (PC + 4)
        @(negedge clk);
        pc_next = 32'h0000_0004;
        @(posedge clk); #1; // Wait for PC to update
        if (pc_out == 32'h0000_0004) $display("[PASS] Test 1 (PC+4): pc_out = %h", pc_out);
        else                         $display("[FAIL] Test 1 (PC+4): Expected 00000004, Got %h", pc_out);

        // Auto Test 2: Normal PC increment (PC + 8)
        @(negedge clk);
        pc_next = 32'h0000_0008;
        @(posedge clk); #1;
        if (pc_out == 32'h0000_0008) $display("[PASS] Test 2 (PC+8): pc_out = %h", pc_out);
        else                         $display("[FAIL] Test 2 (PC+8): Expected 00000008, Got %h", pc_out);

        // Auto Test 3: Simulate a Jump/Branch instruction
        @(negedge clk);
        pc_next = 32'h0000_00A0;
        @(posedge clk); #1;
        if (pc_out == 32'h0000_00A0) $display("[PASS] Test 3 (Jump): pc_out = %h\n", pc_out);
        else                         $display("[FAIL] Test 3 (Jump): Expected 000000a0, Got %h\n", pc_out);


        // ==========================================
        // 2. INTERACTIVE MANUAL INPUT MODE
        // ==========================================
        $display("========================================");
        $display("     SWITCHING TO MANUAL INPUT MODE     ");
        $display("========================================");
        $display("Enter pc_next value in HEX format (e.g., 00000004).");
        $display("Enter any non-HEX character (e.g., 'q') to exit.\n");

        // Loop to wait for terminal input
        forever begin
            @(negedge clk);
            
            $display("-> Current: pc_out = %h", pc_out);
            $display("=> Enter new pc_next: ");
            
            if ($fscanf(32'h8000_0000, "%h", pc_next) != 1) begin
                $display("\n[!] Exiting manual input mode. Simulation finished.");
                $finish;
            end
            
            @(posedge clk);
            #1; 
            $display("   [Updated] pc_out = %h\n", pc_out);
        end
    end

    // Dump waves for waveform viewing
    initial begin
        $dumpfile("pc_wave.vcd");
        $dumpvars(0, tb_pc2);
    end

endmodule