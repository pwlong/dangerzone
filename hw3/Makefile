VLOG = \
	hdl/staggAddQueue_TB.sv \
	hdl/hw2files/paramClock.sv \
	hdl/hw2files/staggeredAdder.sv \
	hdl/hw2files/nBitCarryLookAheadAdder.sv \
	hdl/hw2files/CarryLookAheadAdder4Bit.sv \
	hdl/ipv6_header_pkg.sv \
	hdl/ipv6_testing.sv \
	hdl/hw3_p3.sv

sim: 
	vlib work
	vlog -source $(VLOG)

p1: sim
	vsim -c staggAdd_TB -do exhaustive.do
	vsim -c staggAdd_TB -do directed.do

p2: sim
	vsim -c ipv6Testing -do run.do

p3: sim
	vsim -c hw3_p3 -do run.do
  
  
clean: 
	rm -rf work/ *.log transcript *.zip stim/*.log *.vstf

workspace:
	mkdir hdl
	mkdir stim

package: clean
	zip Paul_L_HW3.zip * hdl/* stim/*
