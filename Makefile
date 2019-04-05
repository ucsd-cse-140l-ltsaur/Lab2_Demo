# TOOLSDIR = /usr/local/bin
TOOLSDIR = ../toolchain-icestorm/toolchain-icestorm/bin
YOSYS=yosys.exe
ARARCHNEPNR=arachne-pnr.exe
ICEPACK=icepack.exe
SRC = latticehx1k.v \
      FourBitAdder.v \
	FullAdder.v \
	uart.v \
	Lab2_140L.v
lab2.bin : lab2.asc lab2.blif

lab2.blif : $(SRC)
	$(TOOLSDIR)/$(YOSYS) -p  'synth_ice40 -top latticehx1k -blif lab2.blif' $(SRC)
lab2.asc : lab2.blif
#	$(TOOLSDIR)/$(ARARCHNEPNR) -r -d 1k -o lab2.asc -p lab2.pcf lab2.blif
	$(TOOLSDIR)/$(ARARCHNEPNR) -r -d 1k -o lab2.asc -p lab2.pcf lab2.blif
lab2.bin : lab2.asc
	$(TOOLSDIR)/$(ICEPACK) lab2.asc lab2.bin

clean:
	rm lab2.blif lab2.asc lab2.bin
