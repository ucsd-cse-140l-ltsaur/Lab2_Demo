TOOLSDIR = /usr/local/bin
SRC = FourBitAdder.v \
	FullAdder.v \
	lab2empty.v \
	uart_rx_fsm.v \
	uart_tx_fsm.v \
	ice_pll.v \
	top_main.v

lab2.blif : $(SRC)
	$(TOOLSDIR)/yosys -p  'synth_ice40 -top lab2_top -blif lab2.blif' $(SRC)
lab2.asc : lab2.blif
	$(TOOLSDIR)/arachne-pnr -d 1k -o lab2.asc -p uart_pcf_sbt.pcf lab2.blif
lab2.bin : lab2.asc
	$(TOOLSDIR)/icepack lab2.asc lab2.bin
