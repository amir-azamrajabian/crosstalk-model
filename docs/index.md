# Wiki Home — Phase-Leg Crosstalk Research

**Author:** Amir Azam Rajabian | am.azrajabian@gmail.com  
**Repository:** [crosstalk-model](https://github.com/amir-azamrajabian/crosstalk-model)

---

## What is Phase-Leg Crosstalk?

In a half-bridge (phase-leg) power converter, two switches — a high-side switch Q_H and a low-side switch Q_L — share a common DC bus. When Q_H turns on, the rising dV/dt and dI/dt of its collector-emitter voltage couple through the parasitic capacitances (Miller capacitance C_gc, output capacitance C_ce) and parasitic inductances (emitter inductance L_e, collector inductance L_c) to the gate-emitter terminal of the passive switch Q_L.

The resulting gate-emitter voltage spike on Q_L is called **crosstalk** (or *Miller turn-on*, *false turn-on*, or *parasitic turn-on*). If the spike exceeds the threshold voltage V_th of Q_L, the device partially or fully turns on, creating a short-circuit (shoot-through) between the positive and negative DC rails — potentially destroying both switches.

This research develops a **closed-form analytical model** that predicts the peak crosstalk voltage and its dependence on:

- Gate resistance R_g
- Emitter/source inductance L_e
- Power-loop inductance L_circ
- DC-link voltage V_bus
- Device capacitances (C_ge, C_gc, C_ce)
- Switching speed (rise time t_r)

---

## Wiki Sections

| Page | Description |
|------|-------------|
| [Theory & Derivation](theory.md) | KCL node equations, Laplace transform, ramp excitation model |
| [MATLAB Code Guide](matlab-guide.md) | How to run each script and what it produces |
| [PSpice Simulation Guide](pspice-guide.md) | Simulation setup, PWL source, CSV export workflow |
| [Publications](publications.md) | Full publication list with abstracts and DOIs |
| [Device Parameters](device-parameters.md) | Complete parameter tables for IGBT (IXGH60N60C2) and Si MOSFET (IRFP450) |

---

## Key Results

- The **positive crosstalk spike** is primarily driven by the Miller capacitance C_gc and the rate of V_CE change (dV/dt). Increasing R_g reduces this component by slowing the gate charging rate.
- The **negative crosstalk spike** is caused by resonance between L_e and C_ge after the positive spike. Unlike the positive spike, increasing R_g beyond an optimal value *increases* the negative spike amplitude.
- There exists an **optimal (R_g, L_e) design point** that minimises the worst-case spike while satisfying switching-loss constraints.
- The model has been experimentally validated on a 400 V / 22 A half-bridge using the IXGH60N60C2 IGBT and extended to the IRFP450 Si MOSFET for the planned TPEL submission.

---

## Repository Layout

```
Crosstalk Project/
├── MATLAB Codes/         ← Core model + parametric studies
├── Publications/         ← Publication-specific scripts
├── Simulations/PSpice/   ← PSpice project files (organised by paper)
└── docs/                 ← This Wiki
```

See [README.md](../README.md) for the complete folder map and quick-start instructions.
