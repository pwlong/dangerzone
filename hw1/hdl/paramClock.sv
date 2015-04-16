`timescale 1ns/1ps
// paramaterizable clock module
module clk(output bit tick);
  
  parameter PERIOD = 10;
  parameter DUTY   = 50;
  //sometime do the duty cycle
  
  initial begin
    #1 tick = 0;
    forever begin
      #((PERIOD/2)*(100/DUTY)) tick = 1;
      #(1-((PERIOD/2)*(100/DUTY))) tick = 0;
    end
  end
endmodule