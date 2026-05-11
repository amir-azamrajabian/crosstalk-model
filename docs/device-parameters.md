# Device Parameters

Complete parameter tables for all devices and operating conditions used across the publication series.

---

## Si IGBT: IXGH60N60C2 (Baseline Device — [C1], [C2], [J1])

### Electrical Characteristics (from datasheet)

| Parameter | Symbol | Value | Unit | Notes |
|-----------|--------|-------|------|-------|
| Collector-Emitter voltage | V_CES | 600 | V | Maximum rating |
| Continuous collector current | I_C | 60 | A | At T_C = 25°C |
| Gate-Emitter threshold voltage | V_GE(th) | 5 | V | Used as V_th in model |
| Transconductance | g_fs | 20 | S | Used in Phase 1 equations |
| Input capacitance (C_iss) | C_iss | 3868 | pF | At V_GE = 0 V, V_CE = 25 V, f = 1 MHz |
| Reverse transfer capacitance | C_rss | 75 | pF | = C_gc in the model |
| Output capacitance | C_oss | 183 | pF | = C_ce in the model |
| Gate-emitter capacitance | C_ge | 3793 | pF | C_iss − C_rss |

> **Note:** C_gc (= C_rss) is voltage-dependent. The value of 75 pF is the model average computed by `CGC_Capacitance_Model.m` over the full V_CE swing (25 V to 400 V). The raw datasheet value at 25 V is 97 pF.

### Test Bench Circuit Parameters

| Parameter | Symbol | Nominal | Range Studied | Unit |
|-----------|--------|---------|---------------|------|
| DC-link voltage | V_bus | 400 | 100–650 | V |
| Power-loop inductance | L_circ | 80–180 | 60–320 | nH |
| Power-loop resistance | R_circ | 1 | — | Ω |
| Gate resistance | R_g | 20 | 3–70 | Ω |
| Gate-lead inductance | L_g | 3 | — | nH |
| Emitter inductance | L_e | 5 | 3–400 | nH |
| Collector inductance | L_c | 1 | — | nH |
| Load current | I_load | 22 | — | A |
| V_CE rise time | t_r | 50 | — | ns |
| Gate-drive voltage | V_driver | 20 | — | V |

### Experimental Emitter Inductance Values (Figure 1, [J1])

Calibrated SMD inductors inserted in the emitter/source lead of the passive switch Q_L:

| Label | Value | Oscilloscope File |
|-------|-------|-------------------|
| L_E,1 | 10 nH | ALL0009.CSV |
| L_E,2 | 23 nH | ALL0015.CSV |
| L_E,3 | 33 nH | ALL0017.CSV |
| L_E,4 | 52 nH | ALL0020.CSV (also used as load current reference) |

### Experimental Gate Resistance Values (Figure, [J1])

| Label | Value | Oscilloscope File |
|-------|-------|-------------------|
| R_g,1 | 10 Ω | Gate_1.CSV |
| R_g,2 | 15 Ω | Gate_2.CSV |
| R_g,3 | 25 Ω | Gate_3.CSV |
| R_g,4 | 70 Ω | Gate_4.CSV |

---

## Si MOSFET: IRFP450 (Extended Model — [TPEL])

Datasheet: `Publications/[TPEL]_In_Preparation/Data/IRFP450.pdf`

### Model Parameters

| Parameter | Symbol | Value | Unit | Comparison to IGBT |
|-----------|--------|-------|------|--------------------|
| DC-link voltage | V_bus | 400 | V | Same |
| Power-loop inductance | L_circ | 80 | nH | Same |
| Power-loop resistance | R_circ | 1 | Ohm | Same |
| Gate-lead inductance | L_g | 3 | nH | Same |
| Source inductance | L_e | 13 | nH | Higher vs. 5 nH IGBT |
| Drain inductance | L_c | 5 | nH | Higher vs. 1 nH IGBT |
| Gate-source capacitance | C_ge | 3850 | pF | Similar to IGBT |
| Gate-drain cap. (Miller, C_rss) | C_gc | 350 | pF | Much higher vs. 75 pF IGBT |
| Drain-source cap. (C_oss) | C_ce | 520 | pF | Higher vs. 183 pF IGBT |
| V_DS rise time | t_r | 50 | ns | Same |
| Gate resistance sweep | R_g | 5–25 | Ohm | Different range |

**Key device differences from the IGBT:**

- **C_gc = 350 pF** — The IRFP450 has a significantly larger reverse transfer capacitance (C_rss) compared to the IXGH60N60C2 IGBT (75 pF), making the Miller-induced positive crosstalk spike more pronounced.
- **L_e = 13 nH** — Higher source lead inductance than the IGBT test bench (5 nH).
- **L_c = 5 nH** — Higher drain lead inductance than the IGBT (1 nH).

---

## Miller Capacitance Model Parameters (IXGH60N60C2)

The voltage-dependent C_gc is modelled as:

```
C_gc(V_CE) = C_ox · (X_param / sqrt(V_CE − V_GE,th)) / (C_ox + (X_param / sqrt(V_CE − V_GE,th)))
```

Fitted to two datasheet points (V_GE = 0 V, f = 1 MHz):

| Datasheet point | V_CE | C_gc |
|----------------|------|------|
| Point 1 | 25 V | 97 pF |
| Point 2 | 30 V | 89 pF |

Fitted parameters (computed in `CGC_Capacitance_Model.m`):

| Parameter | Symbol | Value | Unit |
|-----------|--------|-------|------|
| Oxide capacitance | C_ox | (computed) | pF |
| Junction parameter | X_param | (computed) | pF·V^0.5 |
| Gate threshold offset | V_GE,th | 5 | V |
| Average over V_CE ∈ [25, 400] V | C_gc,avg | ≈ 75 | pF |

Run `CGC_Capacitance_Model.m` to compute the exact C_ox and X_param values for your device.

---

## Summary: Model vs. Experiment Agreement

| Study | Parameter | Range | Max model error |
|-------|-----------|-------|----------------|
| [J1] Positive spike | R_g | 10–70 Ω | < 8% |
| [J1] Negative spike | R_g | 10–70 Ω | < 12% |
| [J1] Positive spike | L_e | 3–50 nH | < 10% |
| [TPEL] Positive spike (IRFP450) | R_g | 5–25 Ohm | < 7% (vs. PSpice) |
| [TPEL] Negative spike (IRFP450) | R_g | 5–25 Ohm | < 9% (vs. PSpice) |

All errors are relative to PSpice simulation or oscilloscope measurement. The 0.8 correction factor accounts for the linear-ramp overestimation uniformly across all operating points.
