// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vqueue__Syms.h"


VL_ATTR_COLD void Vqueue___024root__trace_init_sub__TOP__0(Vqueue___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBit(c+24,"clk_i", false,-1);
    tracep->declBit(c+25,"rst_i", false,-1);
    tracep->declBit(c+26,"push", false,-1);
    tracep->declBit(c+27,"pop", false,-1);
    tracep->declBus(c+28,"data_in", false,-1, 3,0);
    tracep->declBus(c+29,"data_out", false,-1, 3,0);
    tracep->pushNamePrefix("queue ");
    tracep->declBus(c+30,"DEPTH", false,-1, 31,0);
    tracep->declBus(c+31,"PTR_WIDTH", false,-1, 31,0);
    tracep->declBit(c+24,"clk_i", false,-1);
    tracep->declBit(c+25,"rst_i", false,-1);
    tracep->declBit(c+26,"push", false,-1);
    tracep->declBit(c+27,"pop", false,-1);
    tracep->declBus(c+28,"data_in", false,-1, 3,0);
    tracep->declBus(c+29,"data_out", false,-1, 3,0);
    tracep->declBit(c+1,"empty", false,-1);
    tracep->declBit(c+2,"full", false,-1);
    tracep->declBus(c+14,"head_ptr_d", false,-1, 3,0);
    tracep->declBus(c+3,"head_ptr_q", false,-1, 3,0);
    tracep->declBus(c+15,"tail_ptr_d", false,-1, 3,0);
    tracep->declBus(c+4,"tail_ptr_q", false,-1, 3,0);
    for (int i = 0; i < 8; ++i) {
        tracep->declBus(c+16+i*1,"data_queue_d", true,(i+0), 3,0);
    }
    for (int i = 0; i < 8; ++i) {
        tracep->declBus(c+5+i*1,"data_queue_q", true,(i+0), 3,0);
    }
    tracep->pushNamePrefix("unnamedblk1 ");
    tracep->declBus(c+13,"i", false,-1, 31,0);
    tracep->popNamePrefix(2);
}

VL_ATTR_COLD void Vqueue___024root__trace_init_top(Vqueue___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root__trace_init_top\n"); );
    // Body
    Vqueue___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vqueue___024root__trace_full_top_0(void* voidSelf, VerilatedVcd* tracep);
void Vqueue___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd* tracep);
void Vqueue___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vqueue___024root__trace_register(Vqueue___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root__trace_register\n"); );
    // Body
    tracep->addFullCb(&Vqueue___024root__trace_full_top_0, vlSelf);
    tracep->addChgCb(&Vqueue___024root__trace_chg_top_0, vlSelf);
    tracep->addCleanupCb(&Vqueue___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vqueue___024root__trace_full_sub_0(Vqueue___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vqueue___024root__trace_full_top_0(void* voidSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root__trace_full_top_0\n"); );
    // Init
    Vqueue___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vqueue___024root*>(voidSelf);
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vqueue___024root__trace_full_sub_0((&vlSymsp->TOP), tracep);
}

VL_ATTR_COLD void Vqueue___024root__trace_full_sub_0(Vqueue___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vqueue___024root__trace_full_sub_0\n"); );
    // Init
    vluint32_t* const oldp VL_ATTR_UNUSED = tracep->oldp(vlSymsp->__Vm_baseCode);
    // Body
    tracep->fullBit(oldp+1,(((IData)(vlSelf->queue__DOT__head_ptr_q) 
                             == (IData)(vlSelf->queue__DOT__tail_ptr_q))));
    tracep->fullBit(oldp+2,(vlSelf->queue__DOT__full));
    tracep->fullCData(oldp+3,(vlSelf->queue__DOT__head_ptr_q),4);
    tracep->fullCData(oldp+4,(vlSelf->queue__DOT__tail_ptr_q),4);
    tracep->fullCData(oldp+5,(vlSelf->queue__DOT__data_queue_q[0]),4);
    tracep->fullCData(oldp+6,(vlSelf->queue__DOT__data_queue_q[1]),4);
    tracep->fullCData(oldp+7,(vlSelf->queue__DOT__data_queue_q[2]),4);
    tracep->fullCData(oldp+8,(vlSelf->queue__DOT__data_queue_q[3]),4);
    tracep->fullCData(oldp+9,(vlSelf->queue__DOT__data_queue_q[4]),4);
    tracep->fullCData(oldp+10,(vlSelf->queue__DOT__data_queue_q[5]),4);
    tracep->fullCData(oldp+11,(vlSelf->queue__DOT__data_queue_q[6]),4);
    tracep->fullCData(oldp+12,(vlSelf->queue__DOT__data_queue_q[7]),4);
    tracep->fullIData(oldp+13,(vlSelf->queue__DOT__unnamedblk1__DOT__i),32);
    tracep->fullCData(oldp+14,(vlSelf->queue__DOT__head_ptr_d),4);
    tracep->fullCData(oldp+15,(vlSelf->queue__DOT__tail_ptr_d),4);
    tracep->fullCData(oldp+16,(vlSelf->queue__DOT__data_queue_d[0]),4);
    tracep->fullCData(oldp+17,(vlSelf->queue__DOT__data_queue_d[1]),4);
    tracep->fullCData(oldp+18,(vlSelf->queue__DOT__data_queue_d[2]),4);
    tracep->fullCData(oldp+19,(vlSelf->queue__DOT__data_queue_d[3]),4);
    tracep->fullCData(oldp+20,(vlSelf->queue__DOT__data_queue_d[4]),4);
    tracep->fullCData(oldp+21,(vlSelf->queue__DOT__data_queue_d[5]),4);
    tracep->fullCData(oldp+22,(vlSelf->queue__DOT__data_queue_d[6]),4);
    tracep->fullCData(oldp+23,(vlSelf->queue__DOT__data_queue_d[7]),4);
    tracep->fullBit(oldp+24,(vlSelf->clk_i));
    tracep->fullBit(oldp+25,(vlSelf->rst_i));
    tracep->fullBit(oldp+26,(vlSelf->push));
    tracep->fullBit(oldp+27,(vlSelf->pop));
    tracep->fullCData(oldp+28,(vlSelf->data_in),4);
    tracep->fullCData(oldp+29,(vlSelf->data_out),4);
    tracep->fullIData(oldp+30,(8U),32);
    tracep->fullIData(oldp+31,(3U),32);
}
