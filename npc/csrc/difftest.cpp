#include <dlfcn.h>
#include "difftest.h"
#include "utils.h"

void (*ref_difftest_init)(int port) = nullptr;
void (*ref_difftest_regcpy)(void *dut, bool direction) = nullptr;
void (*ref_difftest_memcpy)(paddr_t addr, void *buf, uint64_t n, bool direction) = nullptr;
void (*ref_difftest_exec)(uint64_t n) = nullptr;

void init_difftest(char *ref_so_file, long img_size,int port) {
  char buf[128];

  // open the so file
  if (ref_so_file == nullptr) {
    sprintf(buf, "ref_so_file can not be null\n");
    npc_error(buf);
    assert(0);
  }

  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  if (handle == nullptr) {
    sprintf(buf, "can not open this ref so file, file name: %s\n", ref_so_file);
    npc_error(buf);
    assert(0);
  }

  sprintf(buf, "ref so file from: %s\n", ref_so_file);
  npc_info(buf);

  // init the function
  ref_difftest_init = (void (*)(int))dlsym(handle, "difftest_init");
  assert(ref_difftest_init);

  ref_difftest_regcpy = (void (*)(void *, bool))dlsym(handle, "difftest_regcpy");
  assert(ref_difftest_regcpy);
  
  ref_difftest_memcpy = (void (*)(paddr_t, void *, uint64_t, bool))dlsym(handle, "difftest_memcpy");
  assert(ref_difftest_memcpy);

  ref_difftest_exec = (void (*)(uint64_t))dlsym(handle, "difftest_exec");
  assert(ref_difftest_exec);

  ref_difftest_init(port);
  ref_difftest_memcpy(RESET_VEC, guest_to_host(RESET_VEC), img_size, true);
  // ref_difftest_regcpy();

}



void difftest_step(paddr_t pc) {
  
  npc_state state;
 
  ref_difftest_exec(1);

  ref_difftest_regcpy((void *)&state, false);

  printf("pc = %08x\n", state.pc);


}