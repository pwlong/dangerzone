all: sim

VLOG = \
	hdl/staggAdd_TB.sv \
	hdl/paramClock.sv \
	hdl/staggeredAdder.sv \
	hdl/nBitCarryLookAheadAdder.sv \
	hdl/CarryLookAheadAdder4Bit.sv

sim: 
	vlib work
	vlog -source $(VLOG)

run: sim
	vsim -c staggAdd_TB -do exhaustive.do
	vsim -c staggAdd_TB -do directed.do

clean: 
	rm -rf work/ *.log transcript *.zip stim/*.log *.vstf

package: clean
	zip Paul_L_HW2.zip * hdl/* stim/*
