// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vqueue.h for the primary calling header

#include "verilated.h"

#include "Vqueue___024root.h"

VL_INLINE_OPT void Vqueue___024root___sequent__TOP__1(Vqueue___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root___sequent__TOP__1\n"); );
    // Init
    CData/*0:0*/ __Vdlyvset__queue__DOT__data_queue_q__v0;
    CData/*3:0*/ __Vdlyvval__queue__DOT__data_queue_q__v8;
    CData/*0:0*/ __Vdlyvset__queue__DOT__data_queue_q__v8;
    CData/*3:0*/ __Vdlyvval__queue__DOT__data_queue_q__v9;
    CData/*3:0*/ __Vdlyvval__queue__DOT__data_queue_q__v10;
    CData/*3:0*/ __Vdlyvval__queue__DOT__data_queue_q__v11;
    CData/*3:0*/ __Vdlyvval__queue__DOT__data_queue_q__v12;
    CData/*3:0*/ __Vdlyvval__queue__DOT__data_queue_q__v13;
    CData/*3:0*/ __Vdlyvval__queue__DOT__data_queue_q__v14;
    CData/*3:0*/ __Vdlyvval__queue__DOT__data_queue_q__v15;
    // Body
    if (vlSelf->rst_i) {
        vlSelf->queue__DOT__unnamedblk1__DOT__i = 8U;
        __Vdlyvset__queue__DOT__data_queue_q__v0 = 0U;
        __Vdlyvset__queue__DOT__data_queue_q__v8 = 0U;
        vlSelf->queue__DOT__tail_ptr_q = 0U;
        vlSelf->queue__DOT__head_ptr_q = 0U;
        __Vdlyvset__queue__DOT__data_queue_q__v0 = 1U;
    } else {
        __Vdlyvset__queue__DOT__data_queue_q__v0 = 0U;
        __Vdlyvset__queue__DOT__data_queue_q__v8 = 0U;
        vlSelf->queue__DOT__tail_ptr_q = vlSelf->queue__DOT__tail_ptr_d;
        vlSelf->queue__DOT__head_ptr_q = vlSelf->queue__DOT__head_ptr_d;
        __Vdlyvval__queue__DOT__data_queue_q__v8 = 
            vlSelf->queue__DOT__data_queue_d[7U];
        __Vdlyvset__queue__DOT__data_queue_q__v8 = 1U;
        __Vdlyvval__queue__DOT__data_queue_q__v9 = 
            vlSelf->queue__DOT__data_queue_d[6U];
        __Vdlyvval__queue__DOT__data_queue_q__v10 = 
            vlSelf->queue__DOT__data_queue_d[5U];
        __Vdlyvval__queue__DOT__data_queue_q__v11 = 
            vlSelf->queue__DOT__data_queue_d[4U];
        __Vdlyvval__queue__DOT__data_queue_q__v12 = 
            vlSelf->queue__DOT__data_queue_d[3U];
        __Vdlyvval__queue__DOT__data_queue_q__v13 = 
            vlSelf->queue__DOT__data_queue_d[2U];
        __Vdlyvval__queue__DOT__data_queue_q__v14 = 
            vlSelf->queue__DOT__data_queue_d[1U];
        __Vdlyvval__queue__DOT__data_queue_q__v15 = 
            vlSelf->queue__DOT__data_queue_d[0U];
    }
    if (__Vdlyvset__queue__DOT__data_queue_q__v0) {
        vlSelf->queue__DOT__data_queue_q[0U] = 0U;
        vlSelf->queue__DOT__data_queue_q[1U] = 0U;
        vlSelf->queue__DOT__data_queue_q[2U] = 0U;
        vlSelf->queue__DOT__data_queue_q[3U] = 0U;
        vlSelf->queue__DOT__data_queue_q[4U] = 0U;
        vlSelf->queue__DOT__data_queue_q[5U] = 0U;
        vlSelf->queue__DOT__data_queue_q[6U] = 0U;
        vlSelf->queue__DOT__data_queue_q[7U] = 0U;
    }
    if (__Vdlyvset__queue__DOT__data_queue_q__v8) {
        vlSelf->queue__DOT__data_queue_q[7U] = __Vdlyvval__queue__DOT__data_queue_q__v8;
        vlSelf->queue__DOT__data_queue_q[6U] = __Vdlyvval__queue__DOT__data_queue_q__v9;
        vlSelf->queue__DOT__data_queue_q[5U] = __Vdlyvval__queue__DOT__data_queue_q__v10;
        vlSelf->queue__DOT__data_queue_q[4U] = __Vdlyvval__queue__DOT__data_queue_q__v11;
        vlSelf->queue__DOT__data_queue_q[3U] = __Vdlyvval__queue__DOT__data_queue_q__v12;
        vlSelf->queue__DOT__data_queue_q[2U] = __Vdlyvval__queue__DOT__data_queue_q__v13;
        vlSelf->queue__DOT__data_queue_q[1U] = __Vdlyvval__queue__DOT__data_queue_q__v14;
        vlSelf->queue__DOT__data_queue_q[0U] = __Vdlyvval__queue__DOT__data_queue_q__v15;
    }
    vlSelf->queue__DOT__full = ((((IData)(vlSelf->queue__DOT__head_ptr_q) 
                                  ^ (IData)(vlSelf->queue__DOT__tail_ptr_q)) 
                                 >> 3U) & ((7U & (IData)(vlSelf->queue__DOT__head_ptr_q)) 
                                           == (7U & (IData)(vlSelf->queue__DOT__tail_ptr_q))));
    vlSelf->data_out = vlSelf->queue__DOT__data_queue_q
        [(7U & (IData)(vlSelf->queue__DOT__tail_ptr_q))];
}

VL_INLINE_OPT void Vqueue___024root___combo__TOP__3(Vqueue___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root___combo__TOP__3\n"); );
    // Body
    vlSelf->queue__DOT__tail_ptr_d = vlSelf->queue__DOT__tail_ptr_q;
    if (((IData)(vlSelf->pop) & ((IData)(vlSelf->queue__DOT__head_ptr_q) 
                                 != (IData)(vlSelf->queue__DOT__tail_ptr_q)))) {
        vlSelf->queue__DOT__tail_ptr_d = (0xfU & ((IData)(1U) 
                                                  + (IData)(vlSelf->queue__DOT__tail_ptr_q)));
    }
    vlSelf->queue__DOT__head_ptr_d = vlSelf->queue__DOT__head_ptr_q;
    if (((IData)(vlSelf->push) & (~ (IData)(vlSelf->queue__DOT__full)))) {
        vlSelf->queue__DOT__head_ptr_d = (0xfU & ((IData)(1U) 
                                                  + (IData)(vlSelf->queue__DOT__head_ptr_q)));
    }
    vlSelf->queue__DOT__data_queue_d[7U] = vlSelf->queue__DOT__data_queue_q
        [7U];
    vlSelf->queue__DOT__data_queue_d[6U] = vlSelf->queue__DOT__data_queue_q
        [6U];
    vlSelf->queue__DOT__data_queue_d[5U] = vlSelf->queue__DOT__data_queue_q
        [5U];
    vlSelf->queue__DOT__data_queue_d[4U] = vlSelf->queue__DOT__data_queue_q
        [4U];
    vlSelf->queue__DOT__data_queue_d[3U] = vlSelf->queue__DOT__data_queue_q
        [3U];
    vlSelf->queue__DOT__data_queue_d[2U] = vlSelf->queue__DOT__data_queue_q
        [2U];
    vlSelf->queue__DOT__data_queue_d[1U] = vlSelf->queue__DOT__data_queue_q
        [1U];
    vlSelf->queue__DOT__data_queue_d[0U] = vlSelf->queue__DOT__data_queue_q
        [0U];
    if (((IData)(vlSelf->push) & (~ (IData)(vlSelf->queue__DOT__full)))) {
        vlSelf->queue__DOT__data_queue_d[(7U & (IData)(vlSelf->queue__DOT__head_ptr_q))] 
            = vlSelf->data_in;
    }
}

void Vqueue___024root___eval(Vqueue___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root___eval\n"); );
    // Body
    if ((((IData)(vlSelf->clk_i) & (~ (IData)(vlSelf->__Vclklast__TOP__clk_i))) 
         | ((IData)(vlSelf->rst_i) & (~ (IData)(vlSelf->__Vclklast__TOP__rst_i))))) {
        Vqueue___024root___sequent__TOP__1(vlSelf);
        vlSelf->__Vm_traceActivity[1U] = 1U;
    }
    Vqueue___024root___combo__TOP__3(vlSelf);
    vlSelf->__Vm_traceActivity[2U] = 1U;
    // Final
    vlSelf->__Vclklast__TOP__clk_i = vlSelf->clk_i;
    vlSelf->__Vclklast__TOP__rst_i = vlSelf->rst_i;
}

#ifdef VL_DEBUG
void Vqueue___024root___eval_debug_assertions(Vqueue___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root___eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((vlSelf->clk_i & 0xfeU))) {
        Verilated::overWidthError("clk_i");}
    if (VL_UNLIKELY((vlSelf->rst_i & 0xfeU))) {
        Verilated::overWidthError("rst_i");}
    if (VL_UNLIKELY((vlSelf->push & 0xfeU))) {
        Verilated::overWidthError("push");}
    if (VL_UNLIKELY((vlSelf->pop & 0xfeU))) {
        Verilated::overWidthError("pop");}
    if (VL_UNLIKELY((vlSelf->data_in & 0xf0U))) {
        Verilated::overWidthError("data_in");}
}
#endif  // VL_DEBUG
