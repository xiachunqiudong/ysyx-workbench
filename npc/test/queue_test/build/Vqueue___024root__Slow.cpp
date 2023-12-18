// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vqueue.h for the primary calling header

#include "verilated.h"

#include "Vqueue__Syms.h"
#include "Vqueue___024root.h"

void Vqueue___024root___ctor_var_reset(Vqueue___024root* vlSelf);

Vqueue___024root::Vqueue___024root(const char* _vcname__)
    : VerilatedModule(_vcname__)
 {
    // Reset structure values
    Vqueue___024root___ctor_var_reset(this);
}

void Vqueue___024root::__Vconfigure(Vqueue__Syms* _vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->vlSymsp = _vlSymsp;
}

Vqueue___024root::~Vqueue___024root() {
}
