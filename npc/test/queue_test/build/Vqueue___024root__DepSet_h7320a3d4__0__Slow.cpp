// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vqueue.h for the primary calling header

#include "verilated.h"

#include "Vqueue___024root.h"

VL_ATTR_COLD void Vqueue___024root___settle__TOP__2(Vqueue___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root___settle__TOP__2\n"); );
    // Body
    vlSelf->data_out = vlSelf->queue__DOT__data_queue_q
        [(7U & (IData)(vlSelf->queue__DOT__tail_ptr_q))];
    vlSelf->queue__DOT__tail_ptr_d = vlSelf->queue__DOT__tail_ptr_q;
    if (((IData)(vlSelf->pop) & ((IData)(vlSelf->queue__DOT__head_ptr_q) 
                                 != (IData)(vlSelf->queue__DOT__tail_ptr_q)))) {
        vlSelf->queue__DOT__tail_ptr_d = (0xfU & ((IData)(1U) 
                                                  + (IData)(vlSelf->queue__DOT__tail_ptr_q)));
    }
    vlSelf->queue__DOT__full = ((((IData)(vlSelf->queue__DOT__head_ptr_q) 
                                  ^ (IData)(vlSelf->queue__DOT__tail_ptr_q)) 
                                 >> 3U) & ((7U & (IData)(vlSelf->queue__DOT__head_ptr_q)) 
                                           == (7U & (IData)(vlSelf->queue__DOT__tail_ptr_q))));
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

VL_ATTR_COLD void Vqueue___024root___eval_initial(Vqueue___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root___eval_initial\n"); );
    // Body
    vlSelf->__Vclklast__TOP__clk_i = vlSelf->clk_i;
    vlSelf->__Vclklast__TOP__rst_i = vlSelf->rst_i;
}

VL_ATTR_COLD void Vqueue___024root___eval_settle(Vqueue___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root___eval_settle\n"); );
    // Body
    Vqueue___024root___settle__TOP__2(vlSelf);
    vlSelf->__Vm_traceActivity[2U] = 1U;
    vlSelf->__Vm_traceActivity[1U] = 1U;
    vlSelf->__Vm_traceActivity[0U] = 1U;
}

VL_ATTR_COLD void Vqueue___024root___final(Vqueue___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root___final\n"); );
}

VL_ATTR_COLD void Vqueue___024root___ctor_var_reset(Vqueue___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clk_i = VL_RAND_RESET_I(1);
    vlSelf->rst_i = VL_RAND_RESET_I(1);
    vlSelf->push = VL_RAND_RESET_I(1);
    vlSelf->pop = VL_RAND_RESET_I(1);
    vlSelf->data_in = VL_RAND_RESET_I(4);
    vlSelf->data_out = VL_RAND_RESET_I(4);
    vlSelf->queue__DOT__full = VL_RAND_RESET_I(1);
    vlSelf->queue__DOT__head_ptr_d = VL_RAND_RESET_I(4);
    vlSelf->queue__DOT__head_ptr_q = VL_RAND_RESET_I(4);
    vlSelf->queue__DOT__tail_ptr_d = VL_RAND_RESET_I(4);
    vlSelf->queue__DOT__tail_ptr_q = VL_RAND_RESET_I(4);
    for (int __Vi0=0; __Vi0<8; ++__Vi0) {
        vlSelf->queue__DOT__data_queue_d[__Vi0] = VL_RAND_RESET_I(4);
    }
    for (int __Vi0=0; __Vi0<8; ++__Vi0) {
        vlSelf->queue__DOT__data_queue_q[__Vi0] = VL_RAND_RESET_I(4);
    }
    vlSelf->queue__DOT__unnamedblk1__DOT__i = 0;
    for (int __Vi0=0; __Vi0<3; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }
}
