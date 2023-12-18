// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VQUEUE__SYMS_H_
#define VERILATED_VQUEUE__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vqueue.h"

// INCLUDE MODULE CLASSES
#include "Vqueue___024root.h"

// SYMS CLASS (contains all model state)
class Vqueue__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vqueue* const __Vm_modelp;
    bool __Vm_activity = false;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode = 0;  ///< Used by trace routines when tracing multiple models
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vqueue___024root               TOP;

    // CONSTRUCTORS
    Vqueue__Syms(VerilatedContext* contextp, const char* namep, Vqueue* modelp);
    ~Vqueue__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

#endif  // guard
