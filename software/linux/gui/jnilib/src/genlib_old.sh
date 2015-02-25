rm -rf *.so

gcc -o libxilinxlib.so -fpermissive -DK7_TRD -DPM_SUPPORT -shared -lpthread -Wl,-soname,libxilinx.so -I/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/include   -I/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/include/linux/ -I. com_xilinx_gui_DriverInfoGen.cpp threads.cpp -static -lc

gcc -o libxilinxlibraw.so -fpermissive -DRAW_ETH -DK7_TRD -DPM_SUPPORT -shared -lpthread -Wl,-soname,libxilinxraw.so -I/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/include -I/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/include/linux/ -I. com_xilinx_gui_DriverInfoRaw.cpp threads.cpp -static -lc

gcc -o libxilinxlibdv.so -fpermissive -DK7_TRD -DDATA_VERIFY -DPM_SUPPORT -shared -lpthread -Wl,-soname,libxilinxdv.so -I/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/include -I/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/include/linux/ -I. com_xilinx_gui_DriverInfoGenDV.cpp threads.cpp -static -lc

gcc -o libxilinxlibrawdv.so -fpermissive -DRAW_ETH -DK7_TRD -DDATA_VERIFY -DPM_SUPPORT -shared -lpthread -Wl,-soname,libxilinxrawdv.so -I/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/include -I/usr/lib/jvm/java-1.6.0-openjdk-1.6.0.0/include/linux/ -I. com_xilinx_gui_DriverInfoRawDV.cpp threads.cpp -static -lc

cp *.so ../.
