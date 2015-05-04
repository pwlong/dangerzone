#!/bin/bash
echo""
echo""
echo "Enter ticket price by typing in the number"
echo "next to the price (and hitting enter)"
select price in "10" "20" "30" "40" "50" "60";do
	#echo $price
	vsim -c -gTIXCOST=$price TB -do run.do
	mv ./transcript ./HW4_P$price.log
	sed -i '1, /Loading sv_std.std/d' HW4_P$price.log
	break;
done
