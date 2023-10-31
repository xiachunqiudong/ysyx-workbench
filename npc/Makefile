BUILD_DIR = ./build

VFLAGS = -cc -trace --exe --build -j 8
VSRC = $(shell find $(./vsrc) -name "*.v")
CSRC = $(shell find $(./csrc) -name "*.cpp" -or -name "*.c" -or -name "*.cc")

sim: clean
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo $(VSRC)
	@echo $(CSRC)
	@verilator $(VFLAGS) \
	--top-module top \
	--Mdir $(BUILD_DIR) \
	-CFLAGS "-I /home/xiadong/project/chip/ysyx-workbench/npc/csrc/include" \
	-I./vsrc/include $(VSRC) $(CSRC) \
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

