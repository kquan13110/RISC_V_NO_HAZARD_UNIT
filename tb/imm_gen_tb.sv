`timescale 1ns / 1ps

module tb_imm_gen();

    logic [31:0] inst;
    logic [2:0]  imm_sel;
    logic [31:0] imm_out;

    imm_gen uut (
        .inst(inst),
        .imm_sel(imm_sel),
        .imm_out(imm_out)
    );

    // Macro hỗ trợ in kết quả test
    task check_result(input string type_name, input logic [31:0] expected);
        #1;
        if (imm_out === expected) begin
            $display("[PASS] %s - INST: 0x%h | OUT: 0x%h", type_name, inst, imm_out);
        end else begin
            $error("[FAIL] %s - INST: 0x%h | HOPE: 0x%h | OUT: 0x%h", 
                    type_name, inst, expected, imm_out);
        end
    endtask

    initial begin
        $display("=== TEST IMMEDIATE GENERATOR ===");

        // 1. Test I-Type: addi t0, zero, -1 (-1 = 0xFFFFFFFF)
        inst = 32'hfff00293; imm_sel = 3'b000;
        check_result("I-Type (ADDI)", 32'hFFFF_FFFF);
        #10;

        // 2. Test I-Type (Dương): addi t1, t2, 2047 (2047 = 0x000007FF)
        inst = 32'h7ff38313; imm_sel = 3'b000;
        check_result("I-Type (ADDI)", 32'h0000_07FF);
        #10;

        // 3. Test S-Type: sw ra, 4(sp) (imm = 4 = 0x00000004)
        inst = 32'h00112223; imm_sel = 3'b001;
        check_result("S-Type (SW)  ", 32'h0000_0004);
        #10;

        // 4. Test S-Type (Âm): sw t0, -12(t1) (imm = -12 = 0xFFFFFFF4)
        inst = 32'hfeb32a23; imm_sel = 3'b001;
        check_result("S-Type (SW)  ", 32'hFFFF_FFF4);
        #10;

        // 5. Test B-Type: beq t0, t1, -4 (Lùi lại 1 lệnh, imm = -4 = 0xFFFFFFFC)
        // (Chú ý bit dịch trái trong lệnh Branch)
        inst = 32'hfe628ee3; imm_sel = 3'b010;
        check_result("B-Type (BEQ) ", 32'hFFFF_FFFC);
        #10;

        // 6. Test U-Type: lui t0, 0x12345 (imm = 0x12345000)
        inst = 32'h123452b7; imm_sel = 3'b011;
        check_result("U-Type (LUI) ", 32'h1234_5000);
        #10;

        // 7. Test J-Type: jal ra, -8 (Lùi 2 lệnh, imm = -8 = 0xFFFFFFF8)
        inst = 32'hff9ff0ef; imm_sel = 3'b100;
        check_result("J-Type (JAL) ", 32'hFFFF_FFF8);
        #10;

        $display("=== END TEST ===");
        $finish;
    end

endmodule