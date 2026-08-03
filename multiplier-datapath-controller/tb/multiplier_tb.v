// multiplier_tb.v
//
// Testbench for the datapath + controller multiplier.
// The original repository had no testbench for this design — only a pasted
// simulation log in the README.
//
// Expected behaviour: A is cleared to its seed (50), then P (10) is added once
// per clock while the down-counter B is non-zero. With data_in = 5, B counts
// 5,4,3,2,1,0 — six accumulate cycles — so the final result is 50 + 6*10 = 110,
// which matches the log recorded in the original README.

`timescale 1ns / 1ps

module multiplier_tb;

    reg         clk = 0;
    reg         start = 0;
    reg  [31:0] data_in = 0;

    wire        done;
    wire [31:0] X, Y, Z, Bout;

    multiplier_top dut (
        .clk     (clk),
        .start   (start),
        .data_in (data_in),
        .done    (done),
        .X       (X),
        .Y       (Y),
        .Z       (Z),
        .Bout    (Bout)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("multiplier.vcd");
        $dumpvars(0, multiplier_tb);

        $display("  time |    B |    A |    P |    Z | done");
        $display("-------+------+------+------+------+-----");

        data_in = 32'd5;
        #12 start = 1;
        #10 start = 0;

        wait (done === 1'b1);
        #10;

        $display("");
        $display("final result Z = %0d (expected 110)", Z);
        if (Z === 32'd110)
            $display("PASS");
        else
            $display("FAIL");

        #20 $finish;
    end

    // trace every clock edge
    always @(posedge clk)
        $display("%6t | %4d | %4d | %4d | %4d |    %b",
                 $time, Bout, X, Y, Z, done);

endmodule
