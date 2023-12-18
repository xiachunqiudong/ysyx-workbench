// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vqueue__Syms.h"


void Vqueue___024root__trace_chg_sub_0(Vqueue___024root* vlSelf, VerilatedVcd* tracep);

void Vqueue___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root__trace_chg_top_0\n"); );
    // Init
    Vqueue___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vqueue___024root*>(voidSelf);
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vqueue___024root__trace_chg_sub_0((&vlSymsp->TOP), tracep);
}

void Vqueue___024root__trace_chg_sub_0(Vqueue___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root__trace_chg_sub_0\n"); );
    // Init
    vluint32_t* const oldp VL_ATTR_UNUSED = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[1U])) {
        tracep->chgBit(oldp+0,(((IData)(vlSelf->queue__DOT__head_ptr_q) 
                                == (IData)(vlSelf->queue__DOT__tail_ptr_q))));
        tracep->chgBit(oldp+1,(vlSelf->queue__DOT__full));
        tracep->chgCData(oldp+2,(vlSelf->queue__DOT__head_ptr_q),4);
        tracep->chgCData(oldp+3,(vlSelf->queue__DOT__tail_ptr_q),4);
        tracep->chgCData(oldp+4,(vlSelf->queue__DOT__data_queue_q[0]),4);
        tracep->chgCData(oldp+5,(vlSelf->queue__DOT__data_queue_q[1]),4);
        tracep->chgCData(oldp+6,(vlSelf->queue__DOT__data_queue_q[2]),4);
        tracep->chgCData(oldp+7,(vlSelf->queue__DOT__data_queue_q[3]),4);
        tracep->chgCData(oldp+8,(vlSelf->queue__DOT__data_queue_q[4]),4);
        tracep->chgCData(oldp+9,(vlSelf->queue__DOT__data_queue_q[5]),4);
        tracep->chgCData(oldp+10,(vlSelf->queue__DOT__data_queue_q[6]),4);
        tracep->chgCData(oldp+11,(vlSelf->queue__DOT__data_queue_q[7]),4);
        tracep->chgIData(oldp+12,(vlSelf->queue__DOT__unnamedblk1__DOT__i),32);
    }
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[2U])) {
        tracep->chgCData(oldp+13,(vlSelf->queue__DOT__head_ptr_d),4);
        tracep->chgCData(oldp+14,(vlSelf->queue__DOT__tail_ptr_d),4);
        tracep->chgCData(oldp+15,(vlSelf->queue__DOT__data_queue_d[0]),4);
        tracep->chgCData(oldp+16,(vlSelf->queue__DOT__data_queue_d[1]),4);
        tracep->chgCData(oldp+17,(vlSelf->queue__DOT__data_queue_d[2]),4);
        tracep->chgCData(oldp+18,(vlSelf->queue__DOT__data_queue_d[3]),4);
        tracep->chgCData(oldp+19,(vlSelf->queue__DOT__data_queue_d[4]),4);
        tracep->chgCData(oldp+20,(vlSelf->queue__DOT__data_queue_d[5]),4);
        tracep->chgCData(oldp+21,(vlSelf->queue__DOT__data_queue_d[6]),4);
        tracep->chgCData(oldp+22,(vlSelf->queue__DOT__data_queue_d[7]),4);
    }
    tracep->chgBit(oldp+23,(vlSelf->clk_i));
    tracep->chgBit(oldp+24,(vlSelf->rst_i));
    tracep->chgBit(oldp+25,(vlSelf->push));
    tracep->chgBit(oldp+26,(vlSelf->pop));
    tracep->chgCData(oldp+27,(vlSelf->data_in),4);
    tracep->chgCData(oldp+28,(vlSelf->data_out),4);
}

void Vqueue___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root__trace_cleanup\n"); );
    // Init
    Vqueue___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vqueue___024root*>(voidSelf);
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
}
