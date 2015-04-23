`timescale 1ns/1ps
/*!*****************************************************************************
*
*	@file		    staggAddQueue_TB.sv
*
*	@author		  Paul Long <paul@thelongs.ws>
*	@date		    22 April 2015
*	@copyright	Paul Long, 2015
*
*	@brief		  Test bench for nBit (in multiples of 8) staggered pipeline adder
              using structs and queues
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

    parameter  N             = 16;      // bit width of adder
    parameter  FILENAME      = "Test";  // [stimulus|log] filename
    parameter  CLKPERIOD     = 10;      // testbench clock period
    localparam R_LOWER       = 1;       // randomizer bounds
    localparam R_UPPER       = 10;      
    localparam PIPELINEDEPTH = 4;       
    
    // DUT ports
    logic  [N-1:0]  a=0, b=0, s;
    logic           c=0, cout;  
    bit           clk, rst;
  
    // create a struct to hold input vectors
    // as they traverse the pipeline
    typedef struct {
      logic [N-1:0] a;
      logic [N-1:0] b;
      logic         c;
    } operand;
    operand op_q[$], tempOperands;
    
    
    // internal variables
    integer numTestsRun=0;      // some counters
    integer errorCount=0;
    integer numCyclesRun=0;
    integer in_f, out_f;        // file handles
    integer rc;                 // file operations return code
    int     delay = 0;          // flag to determine if stimulus should be set
                                // this cycle (random generates 2-val variables)
    
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
    
    // fill the results queue so we can pop with impunity
    // even as the pipeline gets it's initial fill
     for (int i=0; i<PIPELINEDEPTH; i++)  begin
       op_q.push_back('{a:0, b:0, c:0});
     end
   
    // toggle reset
    rst = 0;
    #CLKPERIOD rst = 1;
    
    // logfile header
    $fwrite (out_f,"|=time=|  |===== in ====|  |==== ps0 ====|  |===== ps1 =====|  |==== ps2 ====|  |==out==|  |=err=|  |tests|  |delay|\n");
    $fwrite (out_f,"|      |  |    a     b c|  |    a     b c|  | ah  bh  sumL c|  | sumH  sumL c|  |co  sum|  |     |  |     |  |     |\n");    
                 
  // open the stimulus file and iterate
  while (!$feof(in_f)) begin
    @(negedge clk)
      // first time in here there is no stimulus delay
      // could pick a random one first but this is fine
      if (!delay) begin
        // pick a random cycle-count delay until we fetch the next stimulus
        delay = $urandom_range(R_UPPER,R_LOWER);
        
        // scan in a line and grab stimulus vales
        // TODO: allow comments in the stim file(s)
        rc = $fscanf(in_f, "%d %d %d\n", a, b, c);
        
        numTestsRun++;
        $fwrite (out_f,"--------------------------------------------------------------------------------------------------------------------\n");
      end

      // push operands onto queue; if no new operands, use the old ones
      // because DUT will still have that (old) stimulus applied
      op_q.push_back('{a:a, b:b, c:c});
      
      // dump pipeline registers and some other debug stuff to the logfile
      $fwrite(out_f,"%7d    %5d %5d %1d    %5d %5d %1d    %3d %3d %5d %1d    %5d %5d %1d    %1d %5d    %5d    %5d    %4d",    
                $time,
                a, b, c,
                stagAdd.s0a, stagAdd.s0b, stagAdd.s0c,
                stagAdd.s1a, stagAdd.s1b, stagAdd.s1SumLow, stagAdd.s1c,
                stagAdd.s2SumHigh, stagAdd.s2SumLow, stagAdd.s2c,
                cout, s,
                errorCount,
                numTestsRun,
                delay);
      
        // compare results and log as appropriate
        tempOperands = op_q.pop_front();
        
        // results will be x until the pipeline initially fills up
        // don't test for those results b/c your test will fail
        if ( ({cout,s} !== tempOperands.a + tempOperands.b + tempOperands.c)  && !(numCyclesRun < PIPELINEDEPTH)) begin
          // this is the error case
          $display("\t***Error: %d + %d + %d != %d", 
                  tempOperands.a, tempOperands.b, tempOperands.c, {cout,s});
          $fwrite(out_f,"   %d + %d + %d != %d  ***Error***\n", 
                  tempOperands.a, tempOperands.b, tempOperands.c, {cout,s});
          
          errorCount++;
        end
        else begin
          $fwrite(out_f,"   %d + %d + %d  = %d\n", 
                  tempOperands.a, tempOperands.b, tempOperands.c, {cout,s});
        end
        
      // some cycles don't present stimulus, this counts cycles
      numCyclesRun++;
      // decrement delay counter
      delay--;
  end //while
  
  $fwrite (out_f, "=========================\n");
  $fwrite (out_f, "  Simulation Complete\n");
  $fwrite (out_f, "  ran %0d tests\n", numTestsRun);
  $fwrite (out_f, "  found %0d errors\n", errorCount);
  $fwrite (out_f, "  ran for %0d cycles\n", numCyclesRun);
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