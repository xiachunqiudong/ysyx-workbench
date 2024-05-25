-include "./filelist.mk"

BUILD_DIR = ./build
SOC_PATH = /home/x/project/chip/ysyx-workbench/ysyxSoC

VFLAGS = -cc -trace --exe --build -j 8

SOC_TOP    = $(SOC_PATH)/build/ysyxSoCFull.v
V_PERIP    = $(shell find /home/x/project/chip/ysyx-workbench/ysyxSoC/perip -name "*.v")
V_INCLUDE  = $(shell find ./vsrc/define -name "*.v" -or -name "*.sv")
V_TEMPLATE = $(shell find ./vsrc/template -name "*.v" -or -name "*.sv")
V_FU       = $(shell find ./vsrc/fu -name "*.v" -or -name "*.sv")
V_SINGLE   = $(shell find ./vsrc/single    -name "*.v" -or -name "*.sv")
V_PIPE     = $(shell find ./vsrc/pipe -name "*.v" -or -name "*.sv")

VSRC = $(SOC_TOP) $(V_INCLUDE) $(V_TEMPLATE) $(V_FU)
CSRC = $(shell find $(./csrc) -name "*.cpp" -or -name "*.c" -or -name "*.cc")

VSRC += $(V_PIPE)
VSRC += $(V_PERIP)

ifeq ($(IMP), SINGLE)
	VSRC += $(V_SINGLE)
else ifeq ($(IMP), PIPE)
  VSRC += $(V_SINGLE)
else ifeq ($(IMP), OOO)
	VSRC += $(V_SINGLE)
endif

build: clean
	@echo build start!
	verilator $(VFLAGS) \
	--timescale "1ns/1ns" \
	+notimingchecks \
	--top-module ysyxSoCFull \
	--Mdir $(BUILD_DIR) \
	-sv \
	-I$(SOC_PATH)/perip/uart16550/rtl \
	-I$(SOC_PATH)/perip/spi/rtl \
	$(VSRC) $(CSRC) \
	-CFLAGS -I$(NPC_HOME)/csrc/include \
	-LDFLAGS -"lLLVM-14" \
	-LDFLAGS -"lreadline"

run: build
	$(BUILD_DIR)/Vtop $(ARGS) $(IMG)

wave: run
	gtkwave wave.vcd

clean:
	@rm -rf $(BUILD_DIR) 
	@rm -f *.wave
	@rm -rf ./log

test:
	gcc ${OBJS} -o prog -lLLVM-14

.PHONY: clean sim wave push test


-include ../Makefile

OBJS = $(shell find $(./build) -name "*.o")

