// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vqueue.h"
#include "Vqueue__Syms.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vqueue::Vqueue(VerilatedContext* _vcontextp__, const char* _vcname__)
    : vlSymsp{new Vqueue__Syms(_vcontextp__, _vcname__, this)}
    , clk_i{vlSymsp->TOP.clk_i}
    , rst_i{vlSymsp->TOP.rst_i}
    , push{vlSymsp->TOP.push}
    , pop{vlSymsp->TOP.pop}
    , data_in{vlSymsp->TOP.data_in}
    , data_out{vlSymsp->TOP.data_out}
    , rootp{&(vlSymsp->TOP)}
{
}

Vqueue::Vqueue(const char* _vcname__)
    : Vqueue(nullptr, _vcname__)
{
}

//============================================================
// Destructor

Vqueue::~Vqueue() {
    delete vlSymsp;
}

//============================================================
// Evaluation loop

void Vqueue___024root___eval_initial(Vqueue___024root* vlSelf);
void Vqueue___024root___eval_settle(Vqueue___024root* vlSelf);
void Vqueue___024root___eval(Vqueue___024root* vlSelf);
#ifdef VL_DEBUG
void Vqueue___024root___eval_debug_assertions(Vqueue___024root* vlSelf);
#endif  // VL_DEBUG
void Vqueue___024root___final(Vqueue___024root* vlSelf);

static void _eval_initial_loop(Vqueue__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    Vqueue___024root___eval_initial(&(vlSymsp->TOP));
    // Evaluate till stable
    vlSymsp->__Vm_activity = true;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial loop\n"););
        Vqueue___024root___eval_settle(&(vlSymsp->TOP));
        Vqueue___024root___eval(&(vlSymsp->TOP));
    } while (0);
}

void Vqueue::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vqueue::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vqueue___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    vlSymsp->__Vm_activity = true;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        Vqueue___024root___eval(&(vlSymsp->TOP));
    } while (0);
    // Evaluate cleanup
}

//============================================================
// Utilities

VerilatedContext* Vqueue::contextp() const {
    return vlSymsp->_vm_contextp__;
}

const char* Vqueue::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

VL_ATTR_COLD void Vqueue::final() {
    Vqueue___024root___final(&(vlSymsp->TOP));
}

//============================================================
// Trace configuration

void Vqueue___024root__trace_init_top(Vqueue___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vqueue___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vqueue___024root*>(voidSelf);
    Vqueue__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->scopeEscape(' ');
    tracep->pushNamePrefix(std::string{vlSymsp->name()} + ' ');
    Vqueue___024root__trace_init_top(vlSelf, tracep);
    tracep->popNamePrefix();
    tracep->scopeEscape('.');
}

VL_ATTR_COLD void Vqueue___024root__trace_register(Vqueue___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vqueue::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (false && levels && options) {}  // Prevent unused
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vqueue___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
