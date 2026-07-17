# MATLAB Code Guide

This page describes every MATLAB script in the public repository: what it does, what inputs it needs, and what outputs it produces. Run scripts in the order listed within each section to avoid dependency issues.

---

## Prerequisites

| Toolbox | Required by |
|---------|-------------|
| Symbolic Math Toolbox | `CrosstalkModel.m`, `NodeEquationSolver.m`, `CGC_Capacitance_Model.m` |
| Parallel Computing Toolbox | `Parametric_Analysis.m`, `GateResistance_Comparison_JESTIE.m` (optional; falls back to `for` loop) |

MATLAB R2020b or later is recommended. Earlier versions may not support `fontsize()` and `fontname()` shorthand calls; replace with `set(gca, 'FontSize', ...)` equivalents if needed.

---

## 01_Core_Model

### `CrosstalkModel.m`

**Role:** The central function of the entire codebase. All parametric scripts call this.

**Function signature:**
```matlab
function Vge = CrosstalkModel(Vbus, Lcirc, Rcirc, Lc, Rg, Lg, Le, Cgc, Cge, Cce, tr)
```

**What it does:**
1. Assembles three KCL equations at the gate (V_g), collector (V_c), and emitter (V_e) nodes of Q_L in the Laplace domain.
2. Calls `NodeEquationSolver` to solve symbolically for V_g, V_c, V_e.
3. Computes V_ge(s) = V_g - V_e and applies the linear-ramp excitation V_exc(s).
4. Calls MATLAB's `ilaplace()` to convert to the time domain.
5. Converts the symbolic result to a function handle via `matlabFunction()`.
6. Evaluates over t = 0 to 1 us, applies the 0.8 correction factor, and plots the waveform.

**Returns:** A `matlab.graphics.chart.primitive.Line` object (the plotted line). The caller extracts `.YData` for peak detection.

**Example:**
```matlab
Vge = CrosstalkModel(400, 80e-9, 1, 1e-9, 20, 3e-9, 5e-9, 75e-12, 3793e-12, 183e-12, 50e-9);
peak_positive = max(Vge.YData);
peak_negative = min(Vge.YData);
```

---

### `NodeEquationSolver.m`

**Role:** Utility function that solves the three symbolic KCL equations.

**Function signature:**
```matlab
function sol = NodeEquationSolver(eq1, eq2, eq3)
```

**What it does:** Wraps `solve([eq1, eq2, eq3], [Vg, Vc, Ve])`. Returns a struct with fields `.Vg`, `.Vc`, `.Ve`.

**Note:** `Vg`, `Vc`, `Ve` must be declared as `syms` in the caller before passing equations.

---

### `CGC_Capacitance_Model.m`

**Role:** Extracts the voltage-dependent Miller capacitance model and computes the average C_gc over the full V_CE swing.

**Inputs:** Hardcoded datasheet values for IXGH60N60C2:
- C_gc(25 V) = 97 pF
- C_gc(30 V) = 90 pF (Note: original file uses 89 pF; recalibrate if using a different device)

**Outputs:**
- Console: fitted C_ox and X_param values
- Figure: C_gc(V_CE) curve from 25 V to 400 V
- Console: computed C_gc,avg

**When to run:** Once per device. Copy the printed C_gc,avg value into `Parametric_Analysis.m` and `GateResistance_Comparison_JESTIE.m` if refitting to a new device.

---

## 02_Parametric_Analysis

### `Parametric_Analysis.m`

**Role:** Generates the three main parametric study figures from [C1], [C2], and [J1].

**Inputs:** All parameters hardcoded (IGBT baseline values; see README Device Parameters table).

**Outputs (three figures):**

| Figure | X-axis | Y-axis | Publication |
|--------|--------|--------|-------------|
| Fig 1 | L_circ (60-320 nH) | V_ge,max (V) | [C2] |
| Fig 2 | V_bus (100-650 V) | V_ge,max (V) | [C1] |
| Fig 3 | R_g (3-25 Ohm) | V_ge,max (V) | [J1] |

**Performance note:** Each parfor iteration calls `CrosstalkModel`, which internally calls `ilaplace()`. First run may take 5-10 minutes due to Symbolic Math Toolbox caching. Subsequent runs are faster.

---

## 03_Input_Modeling

### `VCE_Waveform_Generator.m`

**Role:** Builds the piecewise analytic V_CE(t) waveform used as the PSpice PWL source.

**Inputs:**
- `VCE_First_Pulse.csv`: PSpice-exported pre-switching steady-state (must be in the same folder or on the MATLAB path)

**Waveform segments:**
1. Steady state: V_CE = V_bus (from CSV)
2. Ramp onset: extended flat segment at V_bus (50 points, 0.1 ns each)
3. Phase 1 (Miller plateau): linear fall from V_bus to V_a

**Outputs:**
- Figure 1: complete composite V_CE(t) waveform
- `Input_Values.txt`: PSpice-compatible PWL data (time [s] | voltage [V], 35-decimal precision)

**How to use the output in PSpice:** In your Cadence OrCAD schematic, place a `VPWL` source and set the `FILE =` attribute to the path of `Input_Values.txt`.

---

### `Switching_Waveform_Plotter.m`

**Role:** Reads raw PSpice CSV output and plots the IGBT switching transient with a zoom-in inset.

**Inputs:**
- `I_IGBT.csv`: collector current I_C(t) from PSpice
- `VCE_High.csv`: collector-emitter voltage V_CE(t) from PSpice

**Outputs:**
- Figure 1: full switching transient (V_CE and I_C overlaid)
- Figure 2: zoomed-in view of the commutation interval

**CSV format expected:** Two-column files; column 1 = time [s], column 2 = value.

---

## 04_Simulation_Plots

### `PSpice_Results_Plotter.m`

**Role:** Reads CSV exports from PSpice parametric sweeps and produces six publication-quality comparison plots.

**Inputs (six CSV files; must be on MATLAB path):**

| File | Content |
|------|---------|
| `Positive_Fluctuation.csv` | Positive V_ge vs. L_circ |
| `Negative_Fluctuation.csv` | Negative V_ge vs. L_circ |
| `Positive_Fluctuation_Vdc.csv` | Positive V_ge vs. V_bus |
| `Negative_Fluctuation_Vdc.csv` | Negative V_ge vs. V_bus |
| `Positive_Fluctuation_RGate.csv` | Positive V_ge vs. R_g |
| `Negative_Fluctuation_RGate.csv` | Negative V_ge vs. R_g |

**Outputs:** Figures 1-6, each overlaying analytical model predictions against PSpice simulation results.

---

## Publications/[J1]_JESTIE_2024/MATLAB

### `CrosstalkModel_JESTIE.m`

Identical in function to `CrosstalkModel.m` in the core model folder, but with the JESTIE-specific publication header and using the exact IGBT parameters from the [J1] paper. Use this version to reproduce the exact figures in the published paper.

---

### `GateResistance_Comparison_JESTIE.m`

**Role:** Compares the analytical model against four experimental measurements.

**Inputs:** Oscilloscope CSV files:
- `Gate_1.CSV`: R_g = 10 Ohm
- `Gate_2.CSV`: R_g = 15 Ohm
- `Gate_3.CSV`: R_g = 25 Ohm
- `Gate_4.CSV`: R_g = 70 Ohm

**Waveform conditioning:** Each oscilloscope capture is corrected for DC offset (channel bias) and probe compression at large signal amplitudes (piecewise scaling).

**Outputs:** Figure 1: positive and negative V_ge vs. R_g (model and experiment, 4 traces)

---

### `Experimental_Analysis_JESTIE.m`

**Role:** Generates five figures for the experimental section of [J1].

| Figure | Content | Input CSVs |
|--------|---------|------------|
| Fig 1 | Overlaid oscilloscope waveforms at L_e = {10, 23, 33, 52} nH | ALL0009, ALL0015, ALL0017, ALL0020.CSV |
| Fig 2 | V_ge (pos + neg) vs. L_e from PSpice | Inductance_Comparison.csv, Positive_SpikeL.csv |
| Fig 3 | Optimal design: positive peak vs. L_e (R_g = 10 Ohm) | Optimal_Design_Case.csv |
| Fig 4 | Optimal design: negative peak vs. L_e (R_g = 10 Ohm) | Optimal_Design_Case_N.csv |
| Fig 5 | Double-pulse test waveform | Double_Pulse_Test.csv |
