`timescale 1ns / 1ps

// Self-checking testbench for the 1100111 non-overlapping sequence detector.
//
// The original testbenches drive a fixed stimulus but contain no $display or
// comparison, so they can only be judged by eyeballing a waveform. This one
// streams a known bit pattern and counts detections.
//
// Stimulus: 1100111 0 1100111
//   Two complete non-overlapping occurrences of the target, so the detector
//   must assert exactly twice.

module sequence_detector_selfcheck_tb;

    reg in  = 0;
    reg clk = 0;
    reg rst = 0;

    wire out;

    integer i;
    integer detections = 0;

    // 15-bit stimulus, MSB first: 1100111 0 1100111
    localparam [14:0] STREAM = 15'b1100111_0_1100111;
    localparam        EXPECTED = 2;

    mealydesign dut (.in(in), .clk(clk), .rst(rst), .out(out));

    always #5 clk = ~clk;

    // Count assertions of `out`.
    // Sampled on the negative edge: the DUT drives `out` with blocking
    // assignments inside its own posedge block, so sampling on posedge races
    // against it and reads the stale value.
    always @(negedge clk)
        if (!rst && out) detections = detections + 1;

    initial begin
        $dumpfile("sequence_detector.vcd");
        $dumpvars(0, sequence_detector_selfcheck_tb);

        rst = 1;
        @(negedge clk);
        @(negedge clk);
        rst = 0;

        for (i = 14; i >= 0; i = i - 1) begin
            in = STREAM[i];
            @(negedge clk);
            $display("bit %0d: in=%b out=%b", 14-i, in, out);
        end

        // allow the registered output to settle
        @(negedge clk);
        @(negedge clk);

        $display("");
        $display("detections = %0d (expected %0d)", detections, EXPECTED);
        if (detections == EXPECTED) $display("PASS");
        else                        $display("FAIL");

        #10 $finish;
    end

endmodule
