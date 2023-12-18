-include $(NPC_HOME)/script/npc.mk

VSRC = $(NPC_HOME)/vsrc/template/queue.sv

sim:
	verilator $(VFLAGS) \
	--top-module queue \
	--Mdir $(BUILD_DIR) \
	$(VSRC) sim.cpp
	./build/Vqueue

