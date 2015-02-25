obj-m := sguser.c
obj-m := xrawdata1.o
xrawdata1-objs :=  sguser.o 

ifeq ($(DRIVER_MODE),RAWETHERNET)
EXTRA_CFLAGS += -DRAW_ETH
endif
ifeq ($(OS_TYPE),64)
EXTRA_CFLAGS += -DX86_64
endif
EXTRA_CFLAGS += -DK7_TRD -DX86_PC -DUSE_IO_MACROS -DNWLDMA -DPM_SUPPORT -DFIFO_EMPTY_CHECK -I $(XRAWDATA1_PATH)  -DBACK_PRESSURE -I $(ROOTDIR)/include/

all:
	$(MAKE) $(CFLAGS) -C $(KDIR) SUBDIRS=$(PWD)/xrawdata1 

clean: 
	   rm -rf *.o *.ko *.mod.* .c* .t*

# LOGGING: ---------------------------------------------------------------
# Add to EXTRA_CFLAGS, based on the logging level desired:
# -DDEBUG_NORMAL: To enable normal logging levels 
# -DDEBUG_VERBOSE: To enable verbose logging levels 
#
