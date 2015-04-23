`timescale 1ns/1ps
/*!************************************************************************************************
*
*	@file		    nbitCarryLookAheadAdder.sv
*
*	@author		  Paul Long <paul@thelongs.ws>
*	@date		    5 April 2015
*	@copyright  Paul Long, 2015
*
*	@brief		  n-bit expandable carry lookahead adder
*				
*		  This module implements a n-bit carry lookahead adder using the appropriate number of
*     4-bit adders (as described in  ECE571 at Portland State University, Spring 2015).
*     It uses XOR for the addition and constructs generate and propagate signals for the
*     lookahead logic.  
*
*	@input	    a,b   numbers to be added
*	@input	    c_in  carry in from any previous stages (module is expandable)
*		  	
* @output     s     result of the addition
*	@output	    c_out carry out to the next stage
*     
*	@parameter 	NUMBITS Width of the inputs and output. Must be a multiple of 4, since the 
*                     constituent adders are 4-bits wide.
*                     Parameter may be changed at simtime on the command line
*  
**************************************************************************************************/

module nBitCLAdder #(parameter NUMBITS=8)(
	input   [NUMBITS-1:0] a_in, b_in,
	input					        c_in,
	output  [NUMBITS-1:0]	s_out,
	output					      c_out);
	
	localparam BASEADDERSIZE   = 4;						            // width of constituent adders
	localparam BASEADDEROFFSET = BASEADDERSIZE-1;		      // upper index given base adder size
	localparam BASEADDERNUM    = NUMBITS / BASEADDERSIZE; // number of base adders we need
                                                        // to hit the desired input width
  initial begin
    if (NUMBITS % BASEADDERSIZE != 0) begin
      // stop and scream, this won't work, bucko!
      $display("\n     =========================");
      $display("     Invalid NUMBITS specified");
      $display("       must be multiple of 4");
      $display("       you gave NUMBITS=%0d", NUMBITS);
      $display("     =========================\n");
      $finish();
    end
	end

	// internal connections
  // carry needs special consideration
  // inputs and sum are just bit selects
	wire  [BASEADDERNUM:0]    carry;
	
	genvar i;		// loop counter
	
	generate
		assign carry[0] = c_in;
		assign c_out    = carry[BASEADDERNUM];
		
		for (i=0; i < BASEADDERNUM; i = i + 1) begin : adders
      CarryLookAheadAdder4Bit #(/*no parameters*/)
      adder (
				.a		  (a_in[(i*BASEADDERSIZE)+BASEADDEROFFSET:i*BASEADDERSIZE]),
				.b		  (b_in[(i*BASEADDERSIZE)+BASEADDEROFFSET:i*BASEADDERSIZE]),
				.c_in	  (carry[i]),
				.s		  (s_out[(i*BASEADDERSIZE)+BASEADDEROFFSET:i*BASEADDERSIZE]),
				.c_out  (carry[i+1])			
			);
		end
	endgenerate
endmodule
