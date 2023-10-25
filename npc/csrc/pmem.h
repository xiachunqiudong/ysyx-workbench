#define MEM_SIZE 0x8000000
#define MEM_BASE 0x80000000

typedef uint32_t paddr_t;

void pmem_init();
uint32_t inst_read(uint32_t addr);
uint8_t *guest_to_host(paddr_t paddr);