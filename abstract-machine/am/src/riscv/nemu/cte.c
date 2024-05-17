#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

// @return: Context*
// @parameter: Event, Context*
static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
  Context *next = NULL;
  if (user_handler) {
    Event ev = {0};
    switch (c->mcause) {
      case 11: 
        ev.event = EVENT_YIELD; 
        c->mepc = c->mepc + 4;
        break;
      default: ev.event = EVENT_ERROR; break;
    }
    // printf("mcause: %d, mstatus: %d, mepc: %x\n", c->mcause, c->mstatus, c->mepc);
    next = user_handler(ev, c);
  }
  assert(next != NULL);
  return next;
}

extern void __am_asm_trap(void);

bool cte_init(Context*(*handler)(Event, Context*)) {
  // initialize exception entry
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));

  // register event handler
  user_handler = handler;

  return true;
}

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
  Context *kctx = (Context *)(kstack.end - sizeof(Context));
  memset(kctx, 0, sizeof(Context));
  kctx->mepc = (uintptr_t)entry;
  kctx->gpr[10] = (uintptr_t)arg;
  *(Context **)kstack.start = kctx;
  return kctx;
}

void yield() {
#ifdef __riscv_e
  asm volatile("li a5, -1; ecall");
#else
  asm volatile("li a7, -1; ecall");
#endif
}

bool ienabled() {
  return false;
}

void iset(bool enable) {
}
