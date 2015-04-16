`timescale 1ns/1ps
/*!*****************************************************************************
*
*	@file		    staggAdd_TB.sv
*
*	@author		  Paul Long <paul@thelongs.ws>
*	@date		    15 April 2015
*	@copyright	Paul Long, 2015
*
*	@brief		  Test bench for nBit (in multiples of 8) staggered pipeline adder
*
* @parameter  FILENAME  Used as the base of the input stimulus file and also
*                       as base of the logfile name
*                       
* @parameter  N         Width of the inputs and output
*                     
* @parameter  CLKPERIOD This parameter is passed into the instantiated
*                       clock module
*
*
*******************************************************************************/



module staggAdd_TB ();

    parameter N         = 16;
    parameter FILENAME  = "Test";
    parameter CLKPERIOD = 10;
    
    // DUT ports
    reg  [N-1:0]  a=0, b=0, s;
    reg           c=0, cout;  
    bit           clk, rst;
    // shift reg to account for pipeline depth when checking results
    logic [3:0][N:0] sumHistory = 64'b0;
    
    // internal variables
    integer numTestsRun=0;      // some counters
    integer errorCount=0;
    integer in_f, out_f;        // file handles
    integer rc;                 // file operations return code
    
  // instantiate adder & clock
  nBitStaggeredAdder #(N)
    stagAdd (
    .clk    (clk),
    .rst    (rst),
    .a_in   (a),
    .b_in   (b),
    .c_in   (c),
    .s_out  (s),
    .c_out  (cout)
    
  );
  
  pClock #(.PERIOD(CLKPERIOD)) clock (clk);
  
 
  initial begin
    // open the needed files
    in_f  = $fopen($psprintf("%s.stim",FILENAME), "r");
    out_f = $fopen($psprintf("%s.log",FILENAME), "w");
    
    // toggle reset
    rst = 0;
    #CLKPERIOD rst = 1;
    
    // logfile header
    $fwrite (out_f,"|=time=|  |===== in ====|  |==== ps0 ====|  |===== ps1 =====|  |==== ps2 ====|  |==out==|  |========= sumHist =========|  |=err=|  |tests|\n");
    $fwrite (out_f,"|      |  |    a     b c|  |    a     b c|  | ah  bh  sumL c|  | sumH  sumL c|  |co  sum|  |                           |  |     |  |     |\n");    
                 
  // open the stimulus file and iterate                     
  while (!$feof(in_f)) begin 
    //string comment; //throwaway to get fscanf to behave with comments in stimFile
    @(negedge clk)
      // scan in a line and grab stimulus vales
      rc = $fscanf(in_f, "%d %d %d\n", a, b, c);
      
      // shift in the result of this stimulus.
      // correctness comparison has to account for pipeline depth
      sumHistory[0] <= a+b+c;    
      sumHistory[1] <= sumHistory[0];
      sumHistory[2] <= sumHistory[1];
      sumHistory[3] <= sumHistory[2];
      
      // dump pipeline registers and some other debug stuff to the logfile
      $fwrite(out_f,"%7d    %5d %5d %1d    %5d %5d %1d    %3d %3d %5d %1d    %5d %5d %1d    %1d %5d    %6d %6d %6d %6d    %5d    %5d\n",    
                $time,
                a, b, c,
                stagAdd.s0a, stagAdd.s0b, stagAdd.s0c,
                stagAdd.s1a, stagAdd.s1b, stagAdd.s1SumLow, stagAdd.s1c,
                stagAdd.s2SumHigh, stagAdd.s2SumLow, stagAdd.s2c,
                cout, s,
                sumHistory[0], sumHistory[1], sumHistory[2], sumHistory[3],
                errorCount,
                numTestsRun);

      // if current output !== sumHistory[3]) there is an error
      // first time pipeline fills sumHistory[3] will have an x and cause an error
      // (if we pay attention to Xs for this comparison) so I use != instead of !==
      if ( {cout,s} != sumHistory[3] ) begin
        errorCount++;
      end
      numTestsRun++;
  end //while
  
  $fwrite (out_f, "=========================\n");
  $fwrite (out_f, "  Simulation Complete\n");
  $fwrite (out_f, "  ran %0d tests\n", numTestsRun);
  $fwrite (out_f, "  found %0d errors\n", errorCount);
  $fwrite (out_f, "=========================\n");
  
  $display("\n     =========================");
  $display("       Simulation Complete");
  $display("     %8d tests  run", numTestsRun);
  $display("     %8d errors found", errorCount);
  $display("       See logfile:\n         %s.log\n       for more details", FILENAME);
  $display("     =========================\n");
  $fclose(in_f);
  $fclose(out_f);
  
  $finish;
  end //initial
  
  
  
 endmodule