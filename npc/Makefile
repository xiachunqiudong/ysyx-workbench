BUILD_DIR = ./build

VFLAGS = -cc -trace --exe --build -j 16
VSRC = $(shell find $(./vsrc) -name "*.v")
CSRC = $(shell find $(./csrc) -name "*.cpp" -or -name "*.c")


sim: clean
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo $(VSRC)
	@echo $(CSRC)
	@verilator $(VFLAGS) \
	--top-module top \
	--Mdir $(BUILD_DIR) \
	-I./vsrc/include $(VSRC) $(CSRC)
	

run: sim
	$(BUILD_DIR)/Vtop $(ARGS) $(IMG)
	gtkwave wave.vcd

wave: run
	gtkwave wave.vcd

clean:
	rm -rf $(BUILD_DIR) 
	rm -f *.wave

.PHONY: clean sim wave push


-include ../Makefile
