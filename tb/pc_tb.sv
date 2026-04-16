`timescale 1ns / 1ps

module tb_pc();

    reg         clk;
    reg         rst_n;
    reg  [31:0] pc_next;
    wire [31:0] pc_out;

    pc uut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    // xung clock chu kỳ 10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // 1. Khởi tạo giá trị ban đầu
        rst_n = 0;
        pc_next = 32'h0000_0000;
        
        // Đợi 2 chu kỳ clk rồi nhả reset
        #20;
        rst_n = 1;
        
        // 2. Test trường hợp PC tăng tuần tự
        pc_next = 32'h0000_0004; #10;
        pc_next = 32'h0000_0008; #10;
        pc_next = 32'h0000_000C; #10;
        
        // 3. Test trường hợp PC nhảy nhánh
        pc_next = 32'h0000_1040; #10;
        pc_next = 32'h0000_1044; #10;
        
        // 4. Test reset đột ngột khi đang chạy
        rst_n = 0; #10;
        rst_n = 1;
        pc_next = 32'h0000_0004; #10;
        
        $finish;
    end

    initial begin
        $dumpfile("tb_pc.vcd");
        $dumpvars(0, tb_pc);
    end

endmodule