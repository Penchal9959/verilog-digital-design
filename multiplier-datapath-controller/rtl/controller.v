`timescale 1ns / 1ps

// Control path - the FSM half of the datapath/control-path split.
//
// Five states drive the whole multiply. The controller never touches data; it
// only issues load, clear and decrement signals, and watches one status bit
// (eqz) coming back from the comparator.
//
//   S0  idle, waiting for start
//   S1  clear the accumulator
//   S2  load the counter from data_in, clear P
//   S3  accumulate: A <- A + P, B <- B - 1. Loops here until eqz
//   S4  assert done and stay put
//
// Two things about this code are worth flagging rather than copying.
//
// The delays. The #1 and #2 inside the always blocks are not synthesisable -
// they exist to paper over a race between the state register and the output
// decoder. Both blocks assign with blocking (=) rather than non-blocking (<=)
// assignment, so without the delays the output decoder can see a stale state.
// The proper structure is three blocks: a clocked state register using <=, a
// combinational next-state block, and a separate output block.
//
// The missing reset. There is no reset input, so `state` powers up as x. The
// default case catches that and pushes it to S0, which works, but an explicit
// reset would be the normal way to do it.

module controller (LdA, LdB, LdP, clrP,clrA, decB, done, clk, eqz, start);

input clk,eqz,start;
output reg LdA, LdB, LdP, clrP,clrA, decB, done;

reg [2:0] state;
parameter S0 = 3'b000 , S1 = 3'b001 , S2 = 3'b010 , S3 = 3'b011 , S4 = 3'b100 ;

/************************ State Transistions **********************/

always@(posedge clk)
        begin
                case (state)
                            
                            S0 : if(start) state <= S1;
                            S1 : state <= S2;
                            S2 : state <= S3;
                            S3 : #2 if(eqz) state <= S4;  // delay added so as to get better simulation results //
                            S4 : state <= S4;
                            default : state <= S0;
                        
                endcase
        end                    

/************************ Generation of Control Signals **********************/    
    
    always@(state)
        begin
                    case(state)
                        
                        S0 : begin #1 LdA = 0; LdB = 0; LdP = 0; clrP = 0; clrA = 0; decB = 0; end
                        S1 : begin #1 clrA = 1;   end
                        S2 : begin #1 LdA = 0; clrA = 0; LdB = 1; clrP = 1;  end
                        S3 : begin #1 LdA = 1; LdB = 0; LdP = 1; clrP = 0; decB = 1; clrA = 0; end
                        S4 : begin #1 done = 1; LdB = 0; LdP = 0; LdA = 0; decB = 0; end
                        default : begin #1 LdA = 0; LdB = 0; LdP = 0; clrP = 0; clrA = 0; decB = 0; end
                    endcase
        end            
    
endmodule  