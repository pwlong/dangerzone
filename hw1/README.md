Instructions for simulating ECE571 Homework 1

Paul Long <paul@thelongs.ws>
7 April 2015

NOTE: The 8-bit adder specified in the assignment is implemented as an n-bit adder
      with defaults set to produce 8 bits. This satisfies the requirements of the 
      assignment while providing more flexibility. For significantly larger bit counts,
      the exhaustive verification employed here will likely become untenable.

  1. Unzip the package (you probably did that already if you are reading this).
  2. To compile and run the simulation and provided tests from the command line (recommended),
     type "make run". QuestSima should start up and run the 8-bit exhaustive test then restart
		 and run the 4-bit exhaustive test. The tests will run with the correct parameters
		 specified for each test. See the provided 8bit.do and 4bit.do files for examples
		 on parameter use. A results summary will be displayed on screen and detailed log files
		 will be created for each run.
  3. To compile the simulation without starting it up, type "make".
      a. You can then manually start the simulation with any desired parameters.
      b. Once started you can manually run the simulation with any desired parameters.
 
 
 File Structure (before running make):
.
|-- 4bit.do   <------------------------- QuestaSim macro to run the 4Bit test
|-- 8bit.do   <------------------------- QuestaSim macro to run the 8Bit test
|-- Makefile  <------------------------- builds/starts the simulation (also some other fun stuff)
|-- README.md <------------------------- this file
`-- hdl
    |-- CarryLookAheadAdder4Bit.sv  <--- Verilog source for base 4Bit adder
    |-- nBitAdder_TB.sv             <--- test bench for both Verilog modules
    `-- nBitCarryLookAheadAdder.sv  <--- Verilog source for nBit adder

After running the tests, ./ will also have QuestaSim-produced files & work directory
as well as the detailed logs produced by the test bench.
