obj-m := xbasic_types.o
obj-m += xxgethernet.o
obj-m += xxgethernet_control.o
obj-m += xgadapter.o
obj-m := xxgbeth1.o
xxgbeth1-objs := xbasic_types.o xxgethernet.o xxgethernet_control.o xgadapter.o
ifeq ($(OS_TYPE),64)
EXTRA_CFLAGS += -DX86_64
endif
# Comment the following when using 1000BASE-X mode
EXTRA_CFLAGS += -DK7_TRD -DAXI_VERSION  -DX86_PC -DXENV_LINUX -DUSE_IO_MACROS -DPHYSETUP -DXGEMAC_MAC2__ -DUSE_NW_PATH1 -DMDIO_CHANGES -DPM_SUPPORT  -I $(XETHERNET1_PATH) -I $(ROOTDIR)/include 
#EXTRA_CFLAGS += -DK7_TRD -DAXI_VERSION  -DX86_PC -DXENV_LINUX -DUSE_IO_MACROS -DPHYSETUP -DXGEMAC_MAC2__ -DUSE_NW_PATH1 -DPM_SUPPORT  -I $(XETHERNET1_PATH) -I $(ROOTDIR)/include 

#-DDEBUG_VERBOSE -DXGEMAC_DEBUG_ 

#-DENABLE_JUMBO

# Uncomment the following to use 1000BASE-X mode
#EXTRA_CFLAGS += -DX86_PC -DXENV_LINUX -DUSE_IO_MACROS -DPHYSETUP -I $(ROOTDIR)/xxgbeth -I $(ROOTDIR)/include -DUSE_1000BASEX 

# Add this to EXTRA_FLAGS to enable jumbo frames 
#-DENABLE_JUMBO

#xgadapter.o:
#	gcc $(CFLAGS) $(EXTRA_CFLAGS) -I. -I../include/ -I $(KDIR)/include -E xgadapter.c

all:
	$(MAKE) $(CFLAGS) -C $(KDIR) SUBDIRS=$(PWD)/xxgbeth1 
	
clean: 
	   rm -rf *.o *.ko *.mod.* .c* .t* .*.cmd 

# LOGGING: ---------------------------------------------------------------
# Add to EXTRA_CFLAGS, based on the logging level desired:
# -DDEBUG: To enable logging in TEMAC (xxgethernet*) code
# -DDEBUG_NORMAL: To enable normal logging levels in Adapter (xgadapter.c)
# -DDEBUG_VERBOSE: To enable verbose logging levels in Adapter (xgadapter.c)

