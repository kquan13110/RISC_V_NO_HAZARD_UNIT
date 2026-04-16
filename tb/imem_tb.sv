`timescale 1ns/1ps

module tb_imem;

    // Khai báo tín hiệu
    reg  [31:0] pc;
    wire [31:0] inst;

    // Khởi tạo module Instruction Memory
    imem #(
        .MEM_DEPTH(1024)
    ) uut (
        .pc(pc),
        .inst(inst)
    );

    // ==========================================
    // NẠP DỮ LIỆU TỪ TESTBENCH
    // ==========================================
    initial begin
        // Dùng uut.memory để chọc thẳng vào mảng bên trong thiết kế
        $readmemh("firmware.hex", uut.memory);
        $display("[INFO] Da nap file firmware.hex vao khoi uut.memory thanh cong!\n");
    end

    // Task kiểm tra kết quả tự động
    task check_result;
        input [31:0] expected_inst;
        input [80*8:1] test_name;
        begin
            #1; // Chờ 1ns cho mạch tổ hợp ổn định
            if (inst === expected_inst) begin
                $display("[PASS] %s: pc = %0d -> inst = %h", test_name, pc, inst);
            end else begin
                $display("[FAIL] %s: pc = %0d -> Expected %h, Got %h", test_name, pc, expected_inst, inst);
            end
            #9;
        end
    endtask

    initial begin
        // Đợi một chút để quá trình nạp dữ liệu hoàn tất trước khi chạy test
        #10;
        
        $display("========================================");
        $display("      STARTING IMEM SIMULATION          ");
        $display("========================================");

        // Đọc các lệnh hợp lệ (PC tăng thêm 4)
        pc = 32'd0;  check_result(32'h0000_0013, "Read Word 0");
        pc = 32'd4;  check_result(32'h0010_0093, "Read Word 1");
        pc = 32'd8;  check_result(32'h0020_8113, "Read Word 2");
        pc = 32'd12; check_result(32'h0020_81b3, "Read Word 3");

        // Kiểm tra đọc địa chỉ không căn lề (Unaligned PC)
        pc = 32'd5;  check_result(32'h0010_0093, "Read Unaligned (PC=5)");

        // Kiểm tra đọc ngoài vùng nhớ (Out-of-bounds)
        pc = 32'd4096; check_result(32'h0000_0000, "Out of Bounds Read");

        $display("========================================");
        $display("         SIMULATION FINISHED            ");
        $display("========================================");
        $finish;
    end

endmodule