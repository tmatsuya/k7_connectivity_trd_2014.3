#!/bin/sh
DMA_MODULE_NAME="xdma_k7"
RAWMODULE="xrawdata0"
ETHERAPP="xxgbeth0"
STATSFILE="xdma_stat"

if [ -d /sys/module/$DMA_MODULE_NAME ]; then
	if [ -d /sys/module/$RAWMODULE ]; then
		cd driver && sudo make remove
	elif [ -d /sys/module/$ETHERAPP ]; then
		cd driver && sudo make DRIVER_MODE=ETHERNETAPP remove
	else
		sudo rmmod $DMA_MODULE_NAME
	fi
fi
if [ -c /dev/$STATSFILE ]; then
	sudo rm -rf /dev/$STATSFILE
fi
