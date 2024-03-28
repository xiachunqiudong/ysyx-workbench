#ifndef __PMEM__
#define __PMEM__

// NPC Memory Config
#define MEM_SIZE  0x8000000
#define MEM_BASE  0x80000000

#define MMIO_SIZE 0x8000000
#define MMIO_BASE 0xa0000000

#define SRIAL_BASE 0xa00003f8
#define SRIAL_SIZE 0x8

#define RTC_BASE 0xa0000048
#define RTC_SIZE 0x8

#define IN_MEM(addr)   (addr >= MEM_BASE && addr < (MEM_BASE + MEM_SIZE))
#define IN_SRIAL(addr) (addr >= SRIAL_BASE && addr < (SRIAL_BASE + SRIAL_SIZE))
#define IN_RTC(addr)   (addr >= RTC_BASE && addr < (RTC_BASE + RTC_SIZE))

void init_pmem();
uint32_t inst_read(paddr_t addr);
uint8_t *guest_to_host(paddr_t paddr);


#endif