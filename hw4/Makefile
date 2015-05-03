all: sim


VLOG = \
	hdl/*

sim: 
	if [ ! -e ./work ]; then vlib work; fi
	vlog -source $(VLOG)

run: sim
	vsim -c TB -do run.do
	mv ./transcript ./HW4.log
	sed -i '1, /Loading sv_std.std/d' HW4.log

runP: sim
	./param.sh

clean: 
	rm -rf work/ transcript *.zip stim/*.log *.vstf

package: clean
	 find -name "*" -not \( -path ./release -prune  -o -name "*.vsdx" \) -exec zip Paul_L_HW4.zip {} \;
