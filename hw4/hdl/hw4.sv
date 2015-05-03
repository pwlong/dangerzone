`timescale 1ns/1ps
/*!*****************************************************************************
*
*	@file		    hw4.sv
*
*	@author		  Paul Long <paul@thelongs.ws>
*	@date		    04 May 2015
*	@copyright	Paul Long, 2015
*
*	@brief		  Hypothetical transit ticket machine controller
*
*             One-hot Moore machine implemented in SystemVerilog. The 
*             controller is responsible for counting deposited money, lighting
*             indicator lamps and activating ticket and change dispensers.
*             Relies on external bill acceptor logic to supply a single input
*             at a time for one clock cycle and only when it is appropriate.
*             If the machine is ready to begin a transaction the Ready signal
*             is asserted (and de-asserted once a transaction begins). Once
*             a transaction is initiated, the Bill signal is asserted until
*             the cost of a ticket has been accepted. If change needs to be
*             dispensed, the ReturnTen signal is asserted for one clock cycle.
*             The Dispense signal is then asserted for one clock cycle and the
*             machine then returns to the Ready state.
*             State encodings are chosen to represent the desired outputs when 
*             in each state.
*             
* @parameter  TIXCOST   Price of the ticket (must be in $10 increments)
*            
* @input      Ten       A ten dollar bill has been inserted
* @input      Twenty    A	twenty dollar bill has been inserted
*       
* @output     Ready     Turn on green ready LED
* @output     Bill      Turn on red LED to indicate more money is needed
* @output     Dispense  Dispense a ticket
* @output     ReturnTen Return a ten dollar bill in change
*             
*******************************************************************************/


module hw4 #(
  parameter TIXCOST = 40 )(
  input     bit Clk, RstN,
  input     bit Ten, Twenty,
  output    bit Ready, Bill, Dispense, ReturnTen
);

  ;
  int       Total   = 0;
  
  //
  //  Data Structures
  //
  enum int       {READY_OS,
                  BILL_OS,
                  DISPENSE_OS,
                  RETURNTEN_OS
                  } StateOS_e;
  
  enum bit [3:0] {READY     = 4'b1 << READY_OS,
                  BILL      = 4'b1 << BILL_OS,
                  DISPENSE  = 4'b1 << DISPENSE_OS,
                  RETURNTEN = 4'b1 << RETURNTEN_OS} ps=READY, ns=READY;
  

  //
  //  state transition sequential logic
  //
  always_ff @(posedge Clk or negedge RstN) begin
    if (!RstN) ps <= READY;
    else       ps <= ns;
  end
  
  
  //
  // next state combinational logic
  //
  always_comb begin
    ns = ps;
    unique case(ps)
         READY: if (Total) ns = BILL;
          BILL: begin
                  unique case (1'b1)
                    Total === TIXCOST: ns = DISPENSE;
                    Total  >  TIXCOST: ns = RETURNTEN;
                    Total  <  TIXCOST: ns = BILL;
                  endcase
                end
     RETURNTEN: ns = DISPENSE;
      DISPENSE: ns = READY;      
    endcase
  end
  
  //
  //  Output assignment block
  //  state encoding = state outputs
  //
  always_comb begin
    {Ready, Bill, Dispense, ReturnTen} = ps;
  end
  
  //
  //  Deposited amount accumulator
  //
  //  zeroed on system reset and at end 
  //  of transaction (ns signal from FSM)
  //  otherwise keeps a running total of deposits
  //
  always_ff @(posedge Clk or negedge RstN) begin
    if (!RstN) Total <= 0;
    else begin
      Total <= Total;
      unique case (1'b1)
        (Ten^Twenty): begin
                        if (Ten) Total <= Total + 10;
                        else     Total <= Total + 20;                   
                      end
       !(Ten|Twenty): Total <= Total;
        (Ten&Twenty): $display("\t\t***Illegal inputs detected");
                    // in a real machine I might flash all the lights, return bills,
                    // force a graceful shut down and phone home for help
      endcase
    end
    if (ns===DISPENSE) Total <= 0;
  end  
   
endmodule