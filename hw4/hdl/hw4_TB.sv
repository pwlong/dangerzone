`timescale 1ns/1ps
/*!*****************************************************************************
*
*	@file		    hw4_TB.sv
*
*	@author		  Paul Long <paul@thelongs.ws>
*	@date		    04 May 2015
*	@copyright	Paul Long, 2015
*
*	@brief		  Test bench for Hypothetical transit ticket machine
*             Currently depends on manual verification so all output
*             is displayed on screen (as well as saved to HW4.log)
*
*
*******************************************************************************/

module TB ();

  //
  //  Internal signals
  //
  parameter  TIXCOST = 40;     // ticket cost
  localparam PERIOD  = 10;     // clock period
  localparam RUPPER  = 10;     // randomization bounds      
  const bit  NoDisp  = 0;      // output display flag
    
  bit Clk, RstN=1;            // DUT connections
  bit Ten, Twenty;
  bit Ready, Bill, Dispense, ReturnTen;
  
  int StateCoverage[string];  // coverage data storage
  int MissedState;

  //
  // Instantiate DUT & ClockGen
  //
  pClock #(PERIOD) C (Clk);   
  hw4 #(TIXCOST) M (.*);
  
  //
  //  Collect coverage data
  //
  //  For each state we hit, add it to the coverage
  //  array. Later loop through the states and see
  //  if they exist in the coverage array. It might be
  //  nice to count how may time a state is hit, but 
  //  that is overkill for this assignment.
  //
  always @(posedge Clk)
    StateCoverage[M.ps.name] = 1;
  
  //  Testing begins here
  //
  //  Reset the DUT and turn on signal monitoring.
  //  Tests are described in DisplayHdr task call.
  //
  //  TODO: add a test that asserts both inputs at the same
  //        time to test display of error message.
  //  TODO: automate (like you did for state coverage) checking
  //        if you have moved across every state transition arc.
  // 
  initial begin
    Reset(NoDisp);
    $monitor("\t\t| %4d    %0d   %0d  %4b   %4b  %4b    %2d  |",
    $time, Ten, Twenty, {Ready, Bill, Dispense, ReturnTen}, M.ps, M.ns, M.Total); 
    
    
    // These eight tests cover every possible path
    // through the machine that leads to a ticket.
    // These are all done with input asserted for one
    // clock cycle and a random (between 1 and 10) cycle
    // delay between inputs
    $display("\n\n");
    $display("\t\t===========================================");
    $display("\t\t=  Testing all paths through the machine  =");
    $display("\t\t===========================================\n");
    DisplayHdr("10 10 10 10 random input delay");
    repeat (4) CycleInput(10);
    Reset();
    VerifyStates();

    DisplayHdr("10 10 10 20 random input delay");
    repeat (3) CycleInput(10);
    CycleInput(20);
    Reset();
    VerifyStates();
   
    DisplayHdr("10 10 20 random input delay");
    repeat (2) CycleInput(10);
    CycleInput(20);
    Reset();
    VerifyStates();

    DisplayHdr("10 20 10 random input delay");
    CycleInput(10);
    CycleInput(20);
    CycleInput(10);
    Reset();
    VerifyStates();

    DisplayHdr("10 20 20 random input delay");
    CycleInput(10);
    repeat (2) CycleInput(20);
    Reset();
    VerifyStates();
    
    DisplayHdr("20 10 10 random input delay");
    CycleInput(20);
    repeat (2) CycleInput(10);
    Reset();
    VerifyStates();
   
    DisplayHdr("20 10 20 random input delay");
    CycleInput(20);
    CycleInput(10);
    CycleInput(20);
    Reset();
    VerifyStates();

    DisplayHdr("20 20 random input delay");
    repeat (2) CycleInput(20);
    Reset();
    VerifyStates();
    
    // This test covers all six possible combinations of inputs
    // across a ticket dispense boundary (with and without
    // requiring change to be dispensed). There is no delay
    // between successive inputs. 
    $display("\n\n");
    $display("\t  =======================================================");
    $display("\t  =  Testing all paths across ticket dispense boundary  =");
    $display("\t  =======================================================");   
    
    DisplayHdr("10 10 20|20 10 10|10 10 10 10|20 20|10 20 10|\n\t\t10 10 10 20|20 10 20|10 20 10\n\t\tno input delay");
    repeat (2)CycleInput(10,0,1,1);
    repeat (2)CycleInput(20,0,1,1);
    repeat (6)CycleInput(10,0,1,1);
    repeat (2)CycleInput(20,0,1,1);
    repeat (1)CycleInput(10,0,1,1);
    repeat (1)CycleInput(20,0,1,1);
    repeat (1)CycleInput(10,0,1,1);
    repeat (3)CycleInput(10,0,1,1);
    repeat (2)CycleInput(20,0,1,1);
    repeat (1)CycleInput(10,0,1,1);
    repeat (1)CycleInput(20,0,1,1);
    repeat (1)CycleInput(10,0,1,1);
    repeat (1)CycleInput(20,0,1,1);
    repeat (1)CycleInput(10,0,1,1);
    
    Reset();
    VerifyStates();
 
    $finish;

  end
  
  //
  //  Loop through the possible states and see if they
  //  have been stored in coverage array (ie. were entered)
  //  This task messes with the present state of the DUT so 
  //  it is placed back in ready state after verification
  //
  task VerifyStates();
    M.ps = M.ps.first();
    for (int i=1; i <= M.ps.last(); i=i<<1) begin
      if (!StateCoverage.exists(M.ps.name())) begin
        MissedState ++;
        $display("\t\t|     Never got into %9s state      |", M.ps.name());
      end
      M.ps = M.ps.next();
    end
    if (!MissedState) $display("\t\t|        All states were entered          |");
    $display("\t\t===========================================\n\n");
    M.ps = M.ps.first();
    MissedState = 0;
    StateCoverage = {};
    
    return;
  endtask

  //
  //  Display a pretty header for each test
  //  Takes a string describing the test
  //
  task DisplayHdr(string msg);
    $display("\t\tInput vector & timing for this test");
    $display("\t\t%S\n\t\tTicket cost = %0d", msg.toupper, M.TIXCOST);
    $display("\t\t===========================================");
    $display("\t\t| time   10  20  TDBR    PS    NS   total |");
    $display("\t\t===========================================");
    return;
  endtask
  
  //
  //  Reset the DUT
  //  Takes an optional flag to disable printing
  //  of the reset message
  //  
  task Reset(bit ShowMsg=1);
    #(PERIOD*2)
    #PERIOD RstN = 1'b0;
    #PERIOD RstN = 1'b1;
    if(ShowMsg)
      $display("\t\t|=========== system was reset ============|");
    return;
  endtask
  
  //
  //  Cycles specified input high then low
  //  Takes in:
  //        Signal    int corresponding to signal name
  //
  //        RandDelay flag indicating if delay before asserting
  //                  input should be randomized (defaults to yes)
  //
  //        Delay     Number of clock cycles to wait before asserting
  //                  input (ignored if RandDelay is set, defaults to 1)
  //
  //        RTZ       Flag indicating if input should be de-asserted
  //                  (defaults to yes)
  //                  
  
  task CycleInput(int Signal, int RandDelay=1, int Delay=1, int RTZ=1);

    if (RandDelay) Delay = $urandom_range(RUPPER);
       
    repeat (Delay) @(negedge Clk);
      if      (Signal === 20) Twenty = '1;
      else if (Signal === 10) Ten    = '1;
      else begin
        $display("No valid Input name specified, exiting sim");
        $stop;
      end
      
    if (RTZ)
      @(negedge Clk);
        if (Signal === 20) Twenty = '0;
        else               Ten    = '0;

    return;
  endtask
  

  
endmodule
    