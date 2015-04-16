`timescale 1ns/1ps
/*!************************************************************************************************
*
*	@file		    nBitAdder_TB.sv
*
*	@author		  Paul Long <paul@thelongs.ws>
*	@date		    31 March 2015
*	@copyright	Paul Long, 2015
*
*	@brief		  Test bench for 4-bit or n-bit expandable carry-lookahead adder.
*
* @parameter  TEST    When = 0, run the 4-bit test.
*                     When = 1, run the n-bit testName.
*                     This may be changed at simtime on the command line.
*
* @parameter  NUMBITS Width of the inputs and output
*                     This may be changed at simtime on the command line
* @parameter  testName  Name of the generated logfile. Will have ".log" appended to the
*                       filename. If no name is specified a reasonable default is used.
*
**************************************************************************************************/

module nBitAdder_TB ();
  // default to baseline test unless
  // overridden on command line
	parameter TEST     = 0;
  parameter NUMBITS  = 4;
  
  // module connections
	reg   [NUMBITS-1:0]	a, b;
  reg 		 	          c_in;
  wire  [NUMBITS-1:0] s_out;
  wire                c_out;
  
  // internal signals
  wire  [NUMBITS-1:0] temp_s[1:0];
  wire                temp_c[1:0];
  
	integer i, j, k;		    // loop counters
	integer f;					    // file handle
  string  logName;        // logfile name
	integer errors   = 0;		// counters
  integer testsRun = 0;   
  
  // instantiate modules
  CarryLookAheadAdder4Bit #()
    adder_4Bit (
      .a		  (a[3:0]),
      .b		  (b[3:0]),
      .c_in	  (c_in),
      .s		  (temp_s[0]),
      .c_out  (temp_c[0])
    );  
    
  nBitCarryLookAheadAdder #(.NUMBITS(NUMBITS))
    adder_nBit (
      .a_in   (a),
      .b_in   (b),
      .c_in   (c_in),
      .s_out  (temp_s[1]),
      .c_out  (temp_c[1])
    );
  
  // mux the results
  assign s_out = temp_s[TEST];
  assign c_out = temp_c[TEST];
  
    
  initial begin
    // get logfile name if specified on command line
    // otherwise, construct one that make sense
    if (!$value$plusargs("LOGNAME=%s", logName)) begin
      case(TEST)
        0:  logName = "4_bit_test";
        1:  logName = $psprintf("%0d_bit_test",NUMBITS);
        default: logName = "unspecified_test";
      endcase
    end
    
    // open the logfile for writing
    f = $fopen($psprintf("%s.log",logName),"w");
    $fwrite(f, "  Starting Simulation\n");
    $fwrite(f, "=========================\n");

    
    // build the input stimulus and compare to expectations
    // this small solution space allows for an exhaustive test
    for (i=0; i < NUMBITS*4; i=i+1) begin
      for (j=0; j < NUMBITS*4; j=j+1) begin
        for (k=0; k < 2; k=k+1) begin
          testsRun = testsRun + 1;
          #100  a = i;
                b = j;
                c_in = k;
          // use x and z in the comparison
          #300 if ((a + b + c_in) !== {c_out,s_out}) begin
              errors = errors + 1;
              $fwrite(f, "  ERROR: %2d + %2d + %1d != %2d\n",
                  a, b, c_in, {c_out,s_out});
          end
          else begin
            $fwrite(f, "  %2d + %2d + %1d = %2d\n",
                a, b, c_in, {c_out, s_out});
          end
        end
      end
    end
    
    $fwrite (f, "=========================\n");
    $fwrite (f, "  Simulation Complete\n");
    $fwrite (f, "  ran %0d tests\n", testsRun);
    $fwrite (f, "  found %0d errors\n", errors);
    $fwrite (f, "=========================\n");
    
    $display(   "\n     =========================");
    $display(   "       Simulation Complete");
    $display("     %8d tests  run", testsRun);
    $display(   "     %8d errors found", errors);
    $display(   "       See logfile:\n         %s.log\n       for more details", logName);
    $display(   "     =========================\n");
    
    $fclose(f);
    $finish();
  
	end // initial
endmodule
