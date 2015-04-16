`timescale 1ns/1ps
/*!************************************************************************************************
*
*	@file		    CarryLookAheadAdder4Bit.sv
*
*	@author		  Paul Long <paul@thelongs.ws>
*	@date		    31 March 2015
*	@copyright  Paul Long, 2015
*
*	@brief		  4-bit expandable carry lookahead adder
*				
*		  This module implements a 4-bit carry lookahead adder as described in  ECE571
*		  at Portland State University, Spring 2015. It uses XOR for the addition and 
*		  constructs generate and propagate signals for the lookahead logic. The lookahead
*		  algorithm can be summarized thusly: a carry out (CO) is produced if the current
*		  stage generates a CO (i.e. a=b=1) or if any previous stage generates a CO which
*		  propagates through all intervening stages including the current stage.
*		  Propagation delay through the entire module is modelled at 5ns
*
*	@input	 a,b   4-bit numbers to be added
*	@input	 c_in  carry in from any previous stages (module is expandable)
*		  	
* @output  s     4-bit result of the addition
*	@output	 c_out carry out to the next stage
*     
*		  
**************************************************************************************************/

	
module CarryLookAheadAdder4Bit (
	input  [3:0] a,
	input  [3:0] b,
	input        c_in,
	
	output [3:0] s,
	output       c_out);
	
	wire  [3:0] g, p;
	wire  [3:0] co;


	// lookahead logic
  assign co[0] = c_in;
  
  assign co[1] = g[0] | 
                 c_in & p[0];
                 
  assign co[2] = g[1] | 
                 g[0] & p[1] | 
                 c_in & p[0] & p[1];
                 
  assign co[3] = g[2] | 
                 g[1] & p[2] | 
                 g[0] & p[1] & p[2] | 
                 c_in & p[0] & p[1] & p[2];
                 
  assign #5 c_out = g[3] | 
                 g[2] & p[3] | 
                 g[1] & p[2] & p[3] | 
                 g[0] & p[1] & p[2] & p[3] | 
                 c_in & p[0] & p[1] & p[2] & p[3];
 
  // adder logic
  assign g = a & b;
	assign p = a | b;
	assign #5 s = a ^ b ^ co;

	
endmodule
