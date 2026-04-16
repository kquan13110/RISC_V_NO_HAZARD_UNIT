`timescale 1ns/1ps

module tb_riscv_checker_ver2;

    // --- Signal Declarations ---
    reg clk;
    reg rst_n;
    integer check_cnt = 0;
    integer pass_cnt = 0;
    integer fail_cnt = 0;

    // Instantiate CPU
    riscv_core uut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // --- Data Structures for Detailed Checking ---
    // 29 instructions that write to the Register File
    logic  [31:0] expected_results [0:28];
    string        inst_name        [0:28];
    string        inst_group       [0:28];
    
    // --- Initialize Expected Values & Instruction Metadata ---
    initial begin
        // ==========================================
        // 1. U-Type Instructions
        // ==========================================
        inst_group[0]  = "U-Type"; inst_name[0]  = "LUI";   expected_results[0]  = 32'h12345000; 
        inst_group[1]  = "U-Type"; inst_name[1]  = "AUIPC"; expected_results[1]  = 32'h00001010; 

        // ==========================================
        // 2. I-Type ALU Instructions
        // ==========================================
        inst_group[2]  = "I-Type"; inst_name[2]  = "ADDI";  expected_results[2]  = 32'h0000000F; 
        inst_group[3]  = "I-Type"; inst_name[3]  = "SLTI";  expected_results[3]  = 32'h00000001; 
        inst_group[4]  = "I-Type"; inst_name[4]  = "SLTIU"; expected_results[4]  = 32'h00000001; 
        inst_group[5]  = "I-Type"; inst_name[5]  = "XORI";  expected_results[5]  = 32'h00000000; 
        inst_group[6]  = "I-Type"; inst_name[6]  = "ORI";   expected_results[6]  = 32'h0000000A; 
        inst_group[7]  = "I-Type"; inst_name[7]  = "ANDI";  expected_results[7]  = 32'h0000000A; 
        inst_group[8]  = "I-Type"; inst_name[8]  = "SLLI";  expected_results[8]  = 32'h00000028; 
        inst_group[9]  = "I-Type"; inst_name[9]  = "SRLI";  expected_results[9]  = 32'h00000014; 
        inst_group[10] = "I-Type"; inst_name[10] = "SRAI";  expected_results[10] = 32'h0000000A; 

        // ==========================================
        // 3. R-Type ALU Instructions
        // ==========================================
        inst_group[11] = "R-Type"; inst_name[11] = "ADD";   expected_results[11] = 32'h00000019; 
        inst_group[12] = "R-Type"; inst_name[12] = "SUB";   expected_results[12] = 32'h00000005; 
        inst_group[13] = "R-Type"; inst_name[13] = "SLL";   expected_results[13] = 32'h00000140; 
        inst_group[14] = "R-Type"; inst_name[14] = "SLT";   expected_results[14] = 32'h00000001; 
        inst_group[15] = "R-Type"; inst_name[15] = "SLTU";  expected_results[15] = 32'h00000001; 
        inst_group[16] = "R-Type"; inst_name[16] = "XOR";   expected_results[16] = 32'h00000005; 
        inst_group[17] = "R-Type"; inst_name[17] = "SRL";   expected_results[17] = 32'h0000000A; 
        inst_group[18] = "R-Type"; inst_name[18] = "SRA";   expected_results[18] = 32'h0000000A; 
        inst_group[19] = "R-Type"; inst_name[19] = "OR";    expected_results[19] = 32'h0000000F; 
        inst_group[20] = "R-Type"; inst_name[20] = "AND";   expected_results[20] = 32'h0000000A; 

        // ==========================================
        // 4. Load Instructions (Memory Read)
        // ==========================================
        inst_group[21] = "Load";   inst_name[21] = "LW";    expected_results[21] = 32'h0000000F; 
        inst_group[22] = "Load";   inst_name[22] = "LH";    expected_results[22] = 32'h0000000A; 
        inst_group[23] = "Load";   inst_name[23] = "LB";    expected_results[23] = 32'h00000005; 
        inst_group[24] = "Load";   inst_name[24] = "LHU";   expected_results[24] = 32'h0000000A; 
        inst_group[25] = "Load";   inst_name[25] = "LBU";   expected_results[25] = 32'h00000005; 

        // ==========================================
        // 5. Jump Instructions (PC + 4 saved to RD)
        // ==========================================
        inst_group[26] = "Jump";   inst_name[26] = "JAL";   expected_results[26] = 32'h00000108; 
        inst_group[27] = "Jump";   inst_name[27] = "AUIPC"; expected_results[27] = 32'h00000114; // Setup for JALR
        inst_group[28] = "Jump";   inst_name[28] = "JALR";  expected_results[28] = 32'h00000128; 
    end

    // --- Clock Generation ---
    always #5 clk = ~clk;

    // --- AUTOMATIC CHECK MECHANISM ---
    always @(negedge clk) begin
        // Only check when writing to a valid register (not x0)
        if (uut.wb_RegWEn && uut.wb_rd_idx != 5'd0) begin
            if (uut.wb_wd === expected_results[check_cnt]) begin
                // Detailed PASS Message: Group | Instruction Name | Check Count | Register & Value
                $display("[PASS] [%-6s] %-5s (Check %02d) : Reg x%-2d successfully updated to 0x%08h", 
                         inst_group[check_cnt], inst_name[check_cnt], check_cnt, uut.wb_rd_idx, uut.wb_wd);
                pass_cnt = pass_cnt + 1;
            end else begin
                // Detailed FAIL Message
                $display("[FAIL] [%-6s] %-5s (Check %02d) : Reg x%-2d MISMATCH! Expected: 0x%08h | Got: 0x%08h", 
                         inst_group[check_cnt], inst_name[check_cnt], check_cnt, uut.wb_rd_idx, expected_results[check_cnt], uut.wb_wd);
                fail_cnt = fail_cnt + 1;
            end
            check_cnt = check_cnt + 1;
        end
    end

    // --- Main Simulation Sequence ---
    initial begin
        // Load Hex File
        $readmemh("inst_37.hex", uut.u_stage_if.u_imem.memory);
        $display("------------------------------------------------------------------");
        $display("                 STARTING RISC-V SIMULATION                       ");
        $display("------------------------------------------------------------------");

        // Reset sequence
        clk = 0; rst_n = 0;
        #15 rst_n = 1;

        // Wait until all 29 instructions are checked OR timeout occurs
        fork
            wait (check_cnt == 29);
            #3000; // Timeout fallback in case CPU hangs
        join_any
        
        #50;
        // --- Final Report ---
        $display("\n==================================================================");
        $display("                    FINAL SIMULATION REPORT                       ");
        $display("==================================================================");
        $display(" Total writes checked : %0d / 29", check_cnt);
        $display(" Passed               : %0d", pass_cnt);
        $display(" Failed               : %0d", fail_cnt);
        $display("==================================================================");
        
        if (fail_cnt == 0 && check_cnt == 29) begin
            $display(" RESULT: SUCCESS! Your CPU is fully RV32I compliant.");
        end else begin
            $display(" RESULT: WARNING! Logic errors or missing instructions detected.");
            $display("         Please check the waveforms for the failed instructions.");
        end
        $display("==================================================================\n");
        
        $finish;
    end

endmodule