cmd_/home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1/xxgethernet_control.o := gcc -Wp,-MD,/home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1/.xxgethernet_control.o.d  -nostdinc -isystem /usr/lib/gcc/i686-redhat-linux/4.6.3/include -I/usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include -Iarch/x86/include/generated -Iinclude  -include /usr/src/kernels/3.3.1-3.fc16.i686/include/linux/kconfig.h -D__KERNEL__ -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -fno-delete-null-pointer-checks -O2 -m32 -msoft-float -mregparm=3 -freg-struct-return -mpreferred-stack-boundary=2 -march=i686 -mtune=generic -maccumulate-outgoing-args -Wa,-mtune=generic32 -ffreestanding -fstack-protector -DCONFIG_AS_CFI=1 -DCONFIG_AS_CFI_SIGNAL_FRAME=1 -DCONFIG_AS_CFI_SECTIONS=1 -pipe -Wno-sign-compare -fno-asynchronous-unwind-tables -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -Wframe-larger-than=1024 -Wno-unused-but-set-variable -fno-omit-frame-pointer -fno-optimize-sibling-calls -g -pg -Wdeclaration-after-statement -Wno-pointer-sign -fno-strict-overflow -fconserve-stack -DCC_HAVE_ASM_GOTO -DK7_TRD -DAXI_VERSION -DX86_PC -DXENV_LINUX -DUSE_IO_MACROS -DPHYSETUP -DXGEMAC_MAC2__ -DUSE_NW_PATH1 -DMDIO_CHANGES -DPM_SUPPORT -I /home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1 -I /home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/include  -DMODULE  -D"KBUILD_STR(s)=\#s" -D"KBUILD_BASENAME=KBUILD_STR(xxgethernet_control)"  -D"KBUILD_MODNAME=KBUILD_STR(xxgbeth1)" -c -o /home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1/xxgethernet_control.o /home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1/xxgethernet_control.c

source_/home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1/xxgethernet_control.o := /home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1/xxgethernet_control.c

deps_/home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1/xxgethernet_control.o := \
  /home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1/xxgethernet.h \
  /home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/include/xstatus.h \
  /home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/include/xbasic_types.h \
  include/linux/types.h \
    $(wildcard include/config/uid16.h) \
    $(wildcard include/config/lbdaf.h) \
    $(wildcard include/config/arch/dma/addr/t/64bit.h) \
    $(wildcard include/config/phys/addr/t/64bit.h) \
    $(wildcard include/config/64bit.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/types.h \
  include/asm-generic/types.h \
  include/asm-generic/int-ll64.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/bitsperlong.h \
  include/asm-generic/bitsperlong.h \
  include/linux/posix_types.h \
  include/linux/stddef.h \
  include/linux/compiler.h \
    $(wildcard include/config/sparse/rcu/pointer.h) \
    $(wildcard include/config/trace/branch/profiling.h) \
    $(wildcard include/config/profile/all/branches.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/enable/warn/deprecated.h) \
  include/linux/compiler-gcc.h \
    $(wildcard include/config/arch/supports/optimized/inlining.h) \
    $(wildcard include/config/optimize/inlining.h) \
  include/linux/compiler-gcc4.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/posix_types.h \
    $(wildcard include/config/x86/32.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/posix_types_32.h \
  /home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1/xxgethernet_hw.h \
  /home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/include/xdebug.h \
  /home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/include/xio.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/io.h \
    $(wildcard include/config/x86/64.h) \
    $(wildcard include/config/x86/oostore.h) \
    $(wildcard include/config/x86/ppro/fence.h) \
    $(wildcard include/config/paravirt.h) \
    $(wildcard include/config/xen.h) \
  include/linux/string.h \
    $(wildcard include/config/binary/printf.h) \
  /usr/lib/gcc/i686-redhat-linux/4.6.3/include/stdarg.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/string.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/string_32.h \
    $(wildcard include/config/x86/use/3dnow.h) \
    $(wildcard include/config/kmemcheck.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/page.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/page_types.h \
  include/linux/const.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/page_32_types.h \
    $(wildcard include/config/highmem4g.h) \
    $(wildcard include/config/highmem64g.h) \
    $(wildcard include/config/page/offset.h) \
    $(wildcard include/config/x86/pae.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/page_32.h \
    $(wildcard include/config/hugetlb/page.h) \
    $(wildcard include/config/debug/virtual.h) \
    $(wildcard include/config/flatmem.h) \
    $(wildcard include/config/x86/3dnow.h) \
  include/asm-generic/memory_model.h \
    $(wildcard include/config/discontigmem.h) \
    $(wildcard include/config/sparsemem/vmemmap.h) \
    $(wildcard include/config/sparsemem.h) \
  include/asm-generic/getorder.h \
  include/asm-generic/iomap.h \
    $(wildcard include/config/has/ioport.h) \
    $(wildcard include/config/pci.h) \
    $(wildcard include/config/generic/iomap.h) \
  include/linux/linkage.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/linkage.h \
    $(wildcard include/config/x86/alignment/16.h) \
  include/linux/stringify.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/byteorder.h \
  include/linux/byteorder/little_endian.h \
  include/linux/swab.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/swab.h \
    $(wildcard include/config/x86/bswap.h) \
  include/linux/byteorder/generic.h \
  include/asm-generic/pci_iomap.h \
    $(wildcard include/config/no/generic/pci/ioport/map.h) \
    $(wildcard include/config/generic/pci/iomap.h) \
  include/linux/vmalloc.h \
    $(wildcard include/config/mmu.h) \
    $(wildcard include/config/smp.h) \
  include/linux/spinlock.h \
    $(wildcard include/config/debug/spinlock.h) \
    $(wildcard include/config/generic/lockbreak.h) \
    $(wildcard include/config/preempt.h) \
    $(wildcard include/config/debug/lock/alloc.h) \
  include/linux/typecheck.h \
  include/linux/preempt.h \
    $(wildcard include/config/debug/preempt.h) \
    $(wildcard include/config/preempt/tracer.h) \
    $(wildcard include/config/preempt/count.h) \
    $(wildcard include/config/preempt/notifiers.h) \
  include/linux/thread_info.h \
    $(wildcard include/config/compat.h) \
  include/linux/bitops.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/bitops.h \
    $(wildcard include/config/x86/cmov.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/alternative.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/asm.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/cpufeature.h \
    $(wildcard include/config/x86/invlpg.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/required-features.h \
    $(wildcard include/config/x86/minimum/cpu/family.h) \
    $(wildcard include/config/math/emulation.h) \
    $(wildcard include/config/x86/cmpxchg64.h) \
    $(wildcard include/config/x86/p6/nop.h) \
  include/asm-generic/bitops/fls64.h \
  include/asm-generic/bitops/find.h \
    $(wildcard include/config/generic/find/first/bit.h) \
  include/asm-generic/bitops/sched.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/arch_hweight.h \
  include/asm-generic/bitops/const_hweight.h \
  include/asm-generic/bitops/le.h \
  include/asm-generic/bitops/ext2-atomic-setbit.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/thread_info.h \
    $(wildcard include/config/debug/stack/usage.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/processor.h \
    $(wildcard include/config/x86/vsmp.h) \
    $(wildcard include/config/cc/stackprotector.h) \
    $(wildcard include/config/m386.h) \
    $(wildcard include/config/m486.h) \
    $(wildcard include/config/x86/debugctlmsr.h) \
    $(wildcard include/config/cpu/sup/amd.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/processor-flags.h \
    $(wildcard include/config/vm86.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/vm86.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/ptrace.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/ptrace-abi.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/segment.h \
  include/linux/init.h \
    $(wildcard include/config/modules.h) \
    $(wildcard include/config/hotplug.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/paravirt_types.h \
    $(wildcard include/config/x86/local/apic.h) \
    $(wildcard include/config/paravirt/debug.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/desc_defs.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/kmap_types.h \
    $(wildcard include/config/debug/highmem.h) \
  include/asm-generic/kmap_types.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/pgtable_types.h \
    $(wildcard include/config/compat/vdso.h) \
    $(wildcard include/config/proc/fs.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/pgtable_32_types.h \
    $(wildcard include/config/highmem.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/pgtable-2level_types.h \
  include/asm-generic/pgtable-nopud.h \
  include/asm-generic/pgtable-nopmd.h \
  include/asm-generic/ptrace.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/math_emu.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/sigcontext.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/current.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/percpu.h \
    $(wildcard include/config/x86/64/smp.h) \
  include/linux/kernel.h \
    $(wildcard include/config/preempt/voluntary.h) \
    $(wildcard include/config/debug/atomic/sleep.h) \
    $(wildcard include/config/prove/locking.h) \
    $(wildcard include/config/ring/buffer.h) \
    $(wildcard include/config/tracing.h) \
    $(wildcard include/config/numa.h) \
    $(wildcard include/config/compaction.h) \
    $(wildcard include/config/ftrace/mcount/record.h) \
  include/linux/log2.h \
    $(wildcard include/config/arch/has/ilog2/u32.h) \
    $(wildcard include/config/arch/has/ilog2/u64.h) \
  include/linux/printk.h \
    $(wildcard include/config/printk.h) \
    $(wildcard include/config/dynamic/debug.h) \
  include/linux/dynamic_debug.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/bug.h \
    $(wildcard include/config/bug.h) \
    $(wildcard include/config/debug/bugverbose.h) \
  include/asm-generic/bug.h \
    $(wildcard include/config/generic/bug.h) \
    $(wildcard include/config/generic/bug/relative/pointers.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/div64.h \
  include/asm-generic/percpu.h \
    $(wildcard include/config/have/setup/per/cpu/area.h) \
  include/linux/threads.h \
    $(wildcard include/config/nr/cpus.h) \
    $(wildcard include/config/base/small.h) \
  include/linux/percpu-defs.h \
    $(wildcard include/config/debug/force/weak/per/cpu.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/system.h \
    $(wildcard include/config/ia32/emulation.h) \
    $(wildcard include/config/x86/32/lazy/gs.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/cmpxchg.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/cmpxchg_32.h \
    $(wildcard include/config/x86/cmpxchg.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/nops.h \
    $(wildcard include/config/mk7.h) \
  include/linux/irqflags.h \
    $(wildcard include/config/trace/irqflags.h) \
    $(wildcard include/config/irqsoff/tracer.h) \
    $(wildcard include/config/trace/irqflags/support.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/irqflags.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/paravirt.h \
    $(wildcard include/config/transparent/hugepage.h) \
    $(wildcard include/config/paravirt/spinlocks.h) \
  include/linux/cpumask.h \
    $(wildcard include/config/cpumask/offstack.h) \
    $(wildcard include/config/hotplug/cpu.h) \
    $(wildcard include/config/debug/per/cpu/maps.h) \
    $(wildcard include/config/disable/obsolete/cpumask/functions.h) \
  include/linux/bitmap.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/msr.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/msr-index.h \
  include/linux/ioctl.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/ioctl.h \
  include/asm-generic/ioctl.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/errno.h \
  include/asm-generic/errno.h \
  include/asm-generic/errno-base.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/cpumask.h \
  include/linux/personality.h \
  include/linux/cache.h \
    $(wildcard include/config/arch/has/cache/line/size.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/cache.h \
    $(wildcard include/config/x86/l1/cache/shift.h) \
    $(wildcard include/config/x86/internode/cache/shift.h) \
  include/linux/math64.h \
  include/linux/err.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/ftrace.h \
    $(wildcard include/config/function/tracer.h) \
    $(wildcard include/config/dynamic/ftrace.h) \
  include/linux/atomic.h \
    $(wildcard include/config/arch/has/atomic/or.h) \
    $(wildcard include/config/generic/atomic64.h) \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/atomic.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/atomic64_32.h \
  include/asm-generic/atomic-long.h \
  include/linux/list.h \
    $(wildcard include/config/debug/list.h) \
  include/linux/poison.h \
    $(wildcard include/config/illegal/pointer/value.h) \
  include/linux/bottom_half.h \
  include/linux/spinlock_types.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/spinlock_types.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/rwlock.h \
  include/linux/lockdep.h \
    $(wildcard include/config/lockdep.h) \
    $(wildcard include/config/lock/stat.h) \
    $(wildcard include/config/prove/rcu.h) \
  include/linux/rwlock_types.h \
  /usr/src/kernels/3.3.1-3.fc16.i686/arch/x86/include/asm/spinlock.h \
  include/linux/rwlock.h \
  include/linux/spinlock_api_smp.h \
    $(wildcard include/config/inline/spin/lock.h) \
    $(wildcard include/config/inline/spin/lock/bh.h) \
    $(wildcard include/config/inline/spin/lock/irq.h) \
    $(wildcard include/config/inline/spin/lock/irqsave.h) \
    $(wildcard include/config/inline/spin/trylock.h) \
    $(wildcard include/config/inline/spin/trylock/bh.h) \
    $(wildcard include/config/inline/spin/unlock.h) \
    $(wildcard include/config/inline/spin/unlock/bh.h) \
    $(wildcard include/config/inline/spin/unlock/irq.h) \
    $(wildcard include/config/inline/spin/unlock/irqrestore.h) \
  include/linux/rwlock_api_smp.h \
    $(wildcard include/config/inline/read/lock.h) \
    $(wildcard include/config/inline/write/lock.h) \
    $(wildcard include/config/inline/read/lock/bh.h) \
    $(wildcard include/config/inline/write/lock/bh.h) \
    $(wildcard include/config/inline/read/lock/irq.h) \
    $(wildcard include/config/inline/write/lock/irq.h) \
    $(wildcard include/config/inline/read/lock/irqsave.h) \
    $(wildcard include/config/inline/write/lock/irqsave.h) \
    $(wildcard include/config/inline/read/trylock.h) \
    $(wildcard include/config/inline/write/trylock.h) \
    $(wildcard include/config/inline/read/unlock.h) \
    $(wildcard include/config/inline/write/unlock.h) \
    $(wildcard include/config/inline/read/unlock/bh.h) \
    $(wildcard include/config/inline/write/unlock/bh.h) \
    $(wildcard include/config/inline/read/unlock/irq.h) \
    $(wildcard include/config/inline/write/unlock/irq.h) \
    $(wildcard include/config/inline/read/unlock/irqrestore.h) \
    $(wildcard include/config/inline/write/unlock/irqrestore.h) \
  /home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/include/xbasic_types.h \

/home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1/xxgethernet_control.o: $(deps_/home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1/xxgethernet_control.o)

$(deps_/home/xhdadvs/Downloads/drivers/k7_driver/linux_driver_app/driver/xxgbeth1/xxgethernet_control.o):
