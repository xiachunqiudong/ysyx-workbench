
gcc:
	riscv64-unknown-elf-gcc chat_test.c -nostdlib -fno-pic -march=rv64g -mcmodel=medany -mstrict-align

bin: gcc
	riscv64-unknown-elf-objcopy -O binary a.out a.bin