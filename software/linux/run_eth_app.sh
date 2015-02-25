#!/bin/sh
compilation_error=1
module_insertion_error=2
compilation_clean_error=3

/bin/sh remove_modules.sh
cd driver
make DRIVER_MODE=ETHERNETAPP clean
if [ "$?" != "0" ]; then
	echo "Error in cleaning Ethernet App Driver"
	exit $compilation_clean_error;
fi
make DRIVER_MODE=ETHERNETAPP
if [ "$?" != "0" ]; then
	echo "Error in compiling Ethernet App Driver"
	exit $compilation_error;
fi
sudo make DRIVER_MODE=ETHERNETAPP insert 
if [ "$?" != "0" ]; then
	echo "Error in inserting Ethernet App Driver"
	exit $module_insertion_error;
fi
cd ../
cd util
./dualnic_setup
