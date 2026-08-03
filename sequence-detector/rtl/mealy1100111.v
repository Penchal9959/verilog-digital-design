`timescale 1ns / 1ps

// Non-overlapping sequence detector for the bit pattern 1100111.
//
// Seven states track how much of the target has matched so far. On a mismatch
// the machine falls back to the state matching the longest suffix of what it
// has seen that is still a prefix of the target - that is the part worth
// studying, since going straight back to s0 every time would miss overlapping
// starts.
//
//   state  matched   on 1   on 0
//   s0     -         s1     s0
//   s1     1         s2     s0
//   s2     11        s2     s3
//   s3     110       s1     s4     <- 1101 leaves a useful "1", so s1 not s0
//   s4     1100      s5     s0
//   s5     11001     s6     s0
//   s6     110011    s0 + out=1    s0
//
// Non-overlapping means a hit returns to s0 rather than reusing the tail of
// the match, which is why s6 goes to s0 on a 1 rather than to s1.
//
// The coding style is not what you would write today. State, next state and
// output are all assigned with blocking (=) assignments inside one clocked
// block. The conventional structure is three separate blocks - a clocked state
// register using <=, combinational next-state logic, and a separate output
// block - which avoids the simulation/synthesis mismatches this style invites.
//
// One consequence to be aware of: `out` is assigned inside the clocked block,
// so it is registered. That gives this "Mealy" machine Moore-like timing, and
// it means a testbench sampling `out` on posedge races the DUT and reads the
// previous value. The self-checking bench samples on negedge for that reason.

module mealydesign(
input in,
input clk,
input rst, 
output reg out
);

reg[2:0]cst;
reg[2:0]nst;
//parameter [1:0]s0 = 2'b000;
//parameter [1:0]s1 = 2'b001;
//parameter [1:0]s2 = 2'b010;
//parameter [1:0]s3 = 2'b011;
//parameter [1:0]s4 = 3'b100;
//parameter [1:0]s5 = 3'b101;
//parameter [1:0]s6 = 3'b110;

parameter s0 = 3'b000;
parameter s1 = 3'b001;
parameter s2 = 3'b010;
parameter s3 = 3'b011;
parameter s4 = 3'b100;
parameter s5 = 3'b101;
parameter s6 = 3'b110;

always@(posedge clk)
begin
if(rst)
begin
out = 1'b0;
cst = s0;
nst = s0;
end

else
begin
cst = nst;
case(cst)

s0:if(in)
begin
out=1'b0;
nst=s1;
end
else
begin
out=1'b0;
nst=s0;
end


s1:if(in)
begin
out=1'b0;
nst=s2;
end
else
begin
out=1'b0;
nst=s0;
end

s2:if(in)
begin
out=1'b0;
nst=s2;
end
else
begin
out=1'b0;
nst=s3;
end

s3:if(in)
begin
out=1'b0;
nst=s1;
end
else
begin
out=1'b0;
nst=s4;
end

s4:if(in)
begin
out=1'b0;
nst=s5;
end
else
begin
out=1'b0;
nst=s0;
end

s5:if(in)
begin
out=1'b0;
nst=s6;
end
else
begin
out=1'b0;
nst=s0;
end

s6:if(in)
begin
out=1'b1;
nst=s0;
end
else
begin
out=1'b0;
nst=s0;
end

endcase
end
end
endmodule
