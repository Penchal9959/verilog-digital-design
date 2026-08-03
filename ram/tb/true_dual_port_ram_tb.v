`timescale 1ns / 1ps

// Testbench for true_dual_port_ram.
// Demonstrates the property the original single-port design cannot provide:
// two different addresses accessed in the same clock cycle.

module true_dual_port_ram_tb;

    localparam DW = 4;
    localparam AW = 8;

    reg           clk = 0;
    reg           en_a = 0, we_a = 0, en_b = 0, we_b = 0;
    reg  [AW-1:0] addr_a = 0, addr_b = 0;
    reg  [DW-1:0] din_a = 0,  din_b = 0;
    wire [DW-1:0] dout_a, dout_b;

    integer errors = 0;

    true_dual_port_ram #(.DATA_WIDTH(DW), .ADDR_WIDTH(AW)) dut (
        .clk_a(clk), .en_a(en_a), .we_a(we_a), .addr_a(addr_a), .din_a(din_a), .dout_a(dout_a),
        .clk_b(clk), .en_b(en_b), .we_b(we_b), .addr_b(addr_b), .din_b(din_b), .dout_b(dout_b)
    );

    always #5 clk = ~clk;

    task check(input [DW-1:0] got, input [DW-1:0] exp, input [127:0] label);
        begin
            if (got !== exp) begin
                $display("FAIL %0s: got %b, expected %b", label, got, exp);
                errors = errors + 1;
            end else begin
                $display("ok   %0s = %b", label, got);
            end
        end
    endtask

    initial begin
        $dumpfile("true_dual_port_ram.vcd");
        $dumpvars(0, true_dual_port_ram_tb);

        @(negedge clk);

        // Simultaneous writes to two different addresses
        en_a = 1; we_a = 1; addr_a = 8'd10; din_a = 4'b1010;
        en_b = 1; we_b = 1; addr_b = 8'd20; din_b = 4'b0101;
        @(negedge clk);

        // Simultaneous reads — port A reads what B wrote, and vice versa
        we_a = 0; addr_a = 8'd20;
        we_b = 0; addr_b = 8'd10;
        @(negedge clk);

        check(dout_a, 4'b0101, "port A reads addr 20");
        check(dout_b, 4'b1010, "port B reads addr 10");

        $display("");
        if (errors == 0) $display("PASS - all checks passed");
        else             $display("FAIL - %0d error(s)", errors);

        #10 $finish;
    end

endmodule
