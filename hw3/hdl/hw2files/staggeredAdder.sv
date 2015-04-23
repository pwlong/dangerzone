`timescale 1ns/1ps
/*!*****************************************************************************
*
*	@file		    staggeredAdder.sv
*
*	@author		  Paul Long <paul@thelongs.ws>
*	@date		    15 April 2015
*	@copyright	Paul Long, 2015
*
*	@brief		  nBit (in multiples of 8) staggered pipeline adder
*     
*       This module implements an nBit staggered pipeline added in 4 pipeline
*       stages; Stage 1 registers the inputs. Stage two adds the lower halves
*       of the inputs, Stage three adds the upper halves of the inputs, Stage
*       four registers the outputs. The constituent adders are parametrizable
*       in 4-bit increments and thus this module is expandable in 8Bit steps.
*
* @parameter  N   The bit-width of inputs
*
*******************************************************************************/

module nBitStaggeredAdder #(parameter N=16)(
  input   bit         clk,
  input   bit         rst,
  input       [N-1:0] a_in, b_in,
  input               c_in,
  output  reg [N-1:0] s_out,
  output  reg         c_out);
  
  // pipeline registers
  // stage0
  reg  [N-1:0]      s0a,  s0b;
  reg               s0c;
  
  // stage1
  reg  [(N/2)-1:0]  s1a,  s1b;
  reg  [(N/2)-1:0]  s1SumLow;
  reg               s1c;
  
  // stage2
  reg  [(N/2)-1:0]  s2SumLow, s2SumHigh;
  reg               s2c;
  
  // adder connections
  wire [(N/2)-1:0]  fa0Sum, fa1Sum;
  wire              fa0co, fa1co;
  
  // build the pipeline
  always @ (posedge clk or negedge rst) begin
    if (!rst) begin
      // flush the pipeline
      // this should be a task?
      s_out     <= 0;
      c_out     <= 0;
      s0a       <= 0;
      s0b       <= 0;
      s0c       <= 0;
      s1a       <= 0;
      s1b       <= 0;
      s1SumLow  <= 0;
      s1c       <= 0;
      s2SumLow  <= 0;
      s2SumHigh <= 0;
      s2c       <= 0;
    end
    else begin
      // stage0
      s0a <= a_in;
      s0b <= b_in;
      s0c <= c_in;
      
      // stage1
      s1a       <= s0a[N-1:N/2];
      s1b       <= s0b[N-1:N/2];
      s1SumLow  <= fa0Sum;
      s1c       <= fa0co;
      
      // stage2
      s2SumLow  <= s1SumLow;
      s2SumHigh <= fa1Sum;
      s2c       <= fa1co;
      
      // stage 3
      s_out     <= {s2SumHigh,s2SumLow};
      c_out     <= s2c;
    end
  end
  
  // instantiate constituent adders
  nBitCLAdder #(N/2)
  fa0 (
    .a_in   (s0a[(N/2)-1:0]),
    .b_in   (s0b[(N/2)-1:0]),
    .c_in   (s0c),
    .s_out  (fa0Sum),
    .c_out  (fa0co)
  );
  
  nBitCLAdder #(N/2)
  fa1 (
    .a_in   (s1a),
    .b_in   (s1b),
    .c_in   (s1c),
    .s_out  (fa1Sum),
    .c_out  (fa1co)
  );
  
endmodule
