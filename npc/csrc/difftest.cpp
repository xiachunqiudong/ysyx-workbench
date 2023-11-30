#include <dlfcn.h>
#include "difftest.h"
#include "common.h"

void (*ref_difftest_init)(int port) = nullptr;
void (*ref_difftest_regcpy)(void *dut, bool direction) = nullptr;
void (*ref_difftest_memcpy)() = nullptr;

void ref_init() {
  // difftest_init(10);
}

void init_difftest(char *ref_so_file, char * img_file) {
  
  if (ref_so_file == nullptr) {
    printf("ref_so_file can not be null\n");
    assert(0);
  }

  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  if (handle == nullptr) {
    printf("can not open this ref so file, file name: %s\n", ref_so_file);
    assert(0);
  }

  ref_difftest_regcpy = (void (*)(void *, bool))dlsym(handle, "difftest_regcpy");
  assert(ref_difftest_regcpy);
  
  ref_difftest_init = (void (*)(int))dlsym(handle, "difftest_init");
  assert(ref_difftest_init);

  
  ref_difftest_init(0);

}

