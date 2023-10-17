
ALL = test
RV = riscv64-linux-gnu-
CC = $(RV)gcc
OBJDUMP = $(RV)objdump
OBJCOPY = $(RV)objcopy

CFLAGS = -nostdlib -march=rv32im_zicsr -mabi=ilp32

all:
	@$(CC) $(CFLAGS) $(ALL).s -o $(ALL).elf
	@$(OBJDUMP) $(ALL).elf -d > $(ALL).txt
	@$(OBJCOPY) --only-section=.text -O binary $(ALL).elf $(ALL).bin

clean:
	rm -rf *.elf *.txt *.bin