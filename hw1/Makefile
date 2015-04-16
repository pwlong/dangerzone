all: sim

VLOG = \
	hdl/nBitAdder_TB.sv \
	hdl/CarryLookAheadAdder4Bit.sv \
	hdl/nBitCarryLookAheadAdder.sv

sim: $(VLOG)
	vlib work
	vlog -source $(VLOG)

run: sim
	vsim -c -do 8bit.do
	vsim -c -do 4bit.do

clean: 
	rm -rf work/ *.log transcript *.zip

package: clean
	zip PLong_HW1.zip * hdl/*
