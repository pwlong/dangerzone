`timescale 1ns/1ps 
// parameterizable clock module
module pClock(output bit clk);
  
  // no dutycycle functionality yet
  parameter PERIOD = 10;
  parameter DUTY   = 50;
 
  
  initial begin
    forever begin
      #(PERIOD/2) clk = 0;
      #(PERIOD/2) clk = 1;
    end
  end
endmodule