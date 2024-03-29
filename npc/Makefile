-include "./filelist.mk"

BUILD_DIR = ./build

VFLAGS = -cc -trace --exe --build -j 8

V_INCLUDE  = $(shell find ./vsrc/define -name "*.v" -or -name "*.sv")
V_TEMPLATE = $(shell find ./vsrc/template -name "*.v" -or -name "*.sv")
V_FU       = $(shell find ./vsrc/fu -name "*.v" -or -name "*.sv")
V_SINGLE   = $(shell find ./vsrc/single    -name "*.v" -or -name "*.sv")
V_PIPE     = $(shell find ./vsrc/pipe -name "*.v" -or -name "*.sv")

VSRC = $(V_INCLUDE) $(V_TEMPLATE) $(V_FU)
CSRC = $(shell find $(./csrc) -name "*.cpp" -or -name "*.c" -or -name "*.cc")

VSRC += $(V_PIPE)

ifeq ($(IMP), SINGLE)
	VSRC += $(V_SINGLE)
else ifeq ($(IMP), PIPE)
  VSRC += $(V_SINGLE)
else ifeq ($(IMP), OOO)
	VSRC += $(V_SINGLE)
endif

sim: clean
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo Verilog file:
	@echo $(VSRC)
	@echo Cpp file:
	@echo $(CSRC)
	verilator $(VFLAGS) \
	--top-module top \
	--Mdir $(BUILD_DIR) \
	-sv \
	$(VSRC) $(CSRC) \
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
	rm -rf ./log

test:
	gcc ${OBJS} -o prog -lLLVM-14

.PHONY: clean sim wave push test


-include ../Makefile

OBJS = $(shell find $(./build) -name "*.o")

