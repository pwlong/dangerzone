`timescale 1ns/1ps 
// paramaterizable clock module
module pClock(output bit tick);
  
  // no dutycycle functionality yet
  parameter PERIOD = 10;
  parameter DUTY   = 50;
 
  
  initial begin
    //tick = 0;
    forever begin
      #(PERIOD/2) tick = 0;
      #(PERIOD/2) tick = 1;
    end
  end
endmodule