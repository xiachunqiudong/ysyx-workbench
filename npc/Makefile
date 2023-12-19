-include "./filelist.mk"

BUILD_DIR = ./build

VFLAGS = -cc -trace --exe --build -j 8
VSRC = $(shell find $(./vsrc/single) -name "*.v" -or -name "*.sv")
CSRC = $(shell find $(./csrc) -name "*.cpp" -or -name "*.c" -or -name "*.cc")

SINGLE_V += ./vsrc/define/liang.sv
SINGLE_V += ./vsrc/single/top.sv
SINGLE_V += ./vsrc/single/ifu.sv
SINGLE_V += ./vsrc/single/idu.sv
SINGLE_V += ./vsrc/single/regfile.sv
SINGLE_V += ./vsrc/single/alu.sv
SINGLE_V += ./vsrc/single/lsu.sv
SINGLE_V += ./vsrc/single/wb.sv

sim: clean
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo Verilog file:
	@echo $(SINGLE_V)
	@echo Cpp file:
	@echo $(CSRC)
	verilator $(VFLAGS) \
	--top-module top \
	--Mdir $(BUILD_DIR) \
	-sv \
	$(SINGLE_V) $(CSRC) \
	-CFLAGS -I$(NPC_HOME)/csrc/include \
	-LDFLAGS -"lLLVM-14" \
	-LDFLAGS -"lreadline"

run: sim
	$(BUILD_DIR)/Vtop $(ARGS) $(IMG)

wave: run
	gtkwave wave.vcd

clean:
	rm -rf $(BUILD_DIR) 
	rm -f *.wave

test:
	gcc ${OBJS} -o prog -lLLVM-14

.PHONY: clean sim wave push test


-include ../Makefile

OBJS = $(shell find $(./build) -name "*.o")

