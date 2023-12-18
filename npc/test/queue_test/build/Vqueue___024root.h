// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vqueue.h for the primary calling header

#ifndef VERILATED_VQUEUE___024ROOT_H_
#define VERILATED_VQUEUE___024ROOT_H_  // guard

#include "verilated.h"

class Vqueue__Syms;
VL_MODULE(Vqueue___024root) {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk_i,0,0);
    VL_IN8(rst_i,0,0);
    VL_IN8(push,0,0);
    VL_IN8(pop,0,0);
    VL_IN8(data_in,3,0);
    VL_OUT8(data_out,3,0);
    CData/*0:0*/ queue__DOT__full;
    CData/*3:0*/ queue__DOT__head_ptr_d;
    CData/*3:0*/ queue__DOT__head_ptr_q;
    CData/*3:0*/ queue__DOT__tail_ptr_d;
    CData/*3:0*/ queue__DOT__tail_ptr_q;
    CData/*0:0*/ __Vclklast__TOP__clk_i;
    CData/*0:0*/ __Vclklast__TOP__rst_i;
    IData/*31:0*/ queue__DOT__unnamedblk1__DOT__i;
    VlUnpacked<CData/*3:0*/, 8> queue__DOT__data_queue_d;
    VlUnpacked<CData/*3:0*/, 8> queue__DOT__data_queue_q;
    VlUnpacked<CData/*0:0*/, 3> __Vm_traceActivity;

    // INTERNAL VARIABLES
    Vqueue__Syms* vlSymsp;  // Symbol table

    // CONSTRUCTORS
    Vqueue___024root(const char* name);
    ~Vqueue___024root();
    VL_UNCOPYABLE(Vqueue___024root);

    // INTERNAL METHODS
    void __Vconfigure(Vqueue__Syms* symsp, bool first);
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);


#endif  // guard
