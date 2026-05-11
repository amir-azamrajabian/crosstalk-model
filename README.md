# Phase-Leg Crosstalk in Si Power Converters (IGBT & MOSFET)
### Analytical Modelling, Experimental Validation & Parametric Design

**Author:** Amir Azam Rajabian  
**Affiliation:** Power Electronics Research Group  
**Contact:** am.azrajabian@gmail.com  
**Last updated:** May 2025

---

## Overview

This repository contains all MATLAB source code, PSpice simulation results (CSV exports), and documentation supporting a series of peer-reviewed publications on **inductive-load phase-leg crosstalk** in Si IGBT and Si MOSFET half-bridge converters.

**Crosstalk** (also called *false turn-on* or *Miller turn-on*) is the parasitic gate-source voltage spike induced on the passive switch Q_L when the active switch Q_H commutates. If the spike exceeds the gate threshold voltage, Q_L unintentionally turns on, causing a destructive shoot-through event. This work develops a complete analytical model — derived from Laplace-domain KCL — that predicts crosstalk amplitude as a function of gate resistance, emitter/source inductance, device capacitances, and switching speed.

---

## Publications

| Tag | Venue | Title | DOI |
|-----|-------|-------|-----|
| **[C1]** | PEDSTC 2022 | *Investigating the Effect of the Power Path Parasitic Inductance on Si-IGBT Crosstalk* | [10.1109/PEDSTC53976.2022.9767324](https://doi.org/10.1109/PEDSTC53976.2022.9767324) |
| **[C2]** | EPE'22 ECCE Europe | *Characterization of Si-IGBT Crosstalk with a Concentration on Power Circuit Parasitic Elements* | [10.1109/EPE22ECCEEurope50083.2022.9907736](https://doi.org/10.1109/EPE22ECCEEurope50083.2022.9907736) |
| **[J1]** | IEEE JESTIE 2024 | *Interrelation of Gate Resistance and Emitter/Source Inductance Impact on Inductive Load Phase-Leg Crosstalk* | [10.1109/JESTIE.2024.3476274](https://doi.org/10.1109/JESTIE.2024.3476274) |
| **[TPEL]** | IEEE TPEL *(In Preparation)* | Extension to Si MOSFET (IRFP450); full switching waveform model | — |

> A. Azam Rajabian and S. Mohsenzade are the authors of all publications listed above.

---

## Repository Structure

```
Crosstalk Project/
│
├── MATLAB Codes/                        ← Core reusable scripts
│   ├── 01_Core_Model/
│   │   ├── CrosstalkModel.m             ← Main analytical model (KCL / Laplace)
│   │   ├── NodeEquationSolver.m         ← Symbolic 3-node KCL solver
│   │   └── CGC_Capacitance_Model.m      ← Voltage-dependent Miller cap model
│   │
│   ├── 02_Parametric_Analysis/
│   │   └── Parametric_Analysis.m        ← Sweeps: Lcirc, Vbus, Rg  (parfor)
│   │
│   ├── 03_Input_Modeling/
│   │   ├── VCE_Waveform_Generator.m     ← Piecewise VCE(t) → PSpice PWL
│   │   └── Switching_Waveform_Plotter.m ← Plot IGBT switching transient
│   │
│   └── 04_Simulation_Plots/
│       └── PSpice_Results_Plotter.m     ← Six PSpice parametric study plots
│
├── Publications/
│   ├── [C1]_PEDSTC_2022/               ← Conference paper 1 (PEDSTC 2022)
│   ├── [C2]_EPE_2022/                  ← Conference paper 2 (EPE'22 ECCE)
│   ├── [J1]_JESTIE_2024/               ← Journal paper (IEEE JESTIE 2024)
│   │   └── MATLAB/
│   │       ├── CrosstalkModel_JESTIE.m
│   │       ├── GateResistance_Comparison_JESTIE.m
│   │       └── Experimental_Analysis_JESTIE.m
│   │
│   └── [TPEL]_In_Preparation/          ← Future IEEE TPEL submission
│       └── MATLAB/
│           ├── MOSFET_Comparison_TPEL.m
│           ├── SwitchingEquations_TPEL.m
│           └── SwitchingInput_Generator_TPEL.m
│
├── Simulations/                         ← PSpice simulation project files
│   └── PSpice/
│       ├── [C1]_PEDSTC_2022/
│       ├── [C2]_EPE_2022/
│       ├── [J1]_JESTIE_2024/
│       └── [TPEL]_In_Preparation/
│
├── docs/                                ← GitHub Wiki (Markdown)
│   ├── index.md
│   ├── theory.md
│   ├── matlab-guide.md
│   ├── pspice-guide.md
│   ├── publications.md
│   └── device-parameters.md
│
├── README.md
├── .gitignore
└── setup-git.ps1                        ← One-time git setup & push script
```

---

## Quick Start

### Requirements
- MATLAB R2020b or later (Symbolic Math Toolbox required)
- Parallel Computing Toolbox (for `parfor` sweeps — optional, falls back to `for`)
- PSpice / Cadence OrCAD (for simulation files; CSV exports are included)

### Running the Core Model

```matlab
% Open MATLAB, cd to the project root, then:
cd('MATLAB Codes/01_Core_Model')

% Run the model for a single operating point:
Vge = CrosstalkModel(400, 80e-9, 1, 1e-9, 20, 3e-9, 5e-9, 75e-12, 3793e-12, 183e-12, 50e-9);
```

### Running a Parametric Sweep

```matlab
cd('MATLAB Codes/02_Parametric_Analysis')
Parametric_Analysis    % Generates Figures 1–3 (Lcirc, Vbus, Rg sweeps)
```

### Reproducing Publication Figures

```matlab
% JESTIE 2024 figures:
cd('Publications/[J1]_JESTIE_2024/MATLAB')
GateResistance_Comparison_JESTIE   % Fig: Model vs. experiment over Rg
Experimental_Analysis_JESTIE       % Figs: Oscilloscope + Le sweep

% TPEL figures (Si MOSFET - IRFP450):
cd('Publications/[TPEL]_In_Preparation/MATLAB')
MOSFET_Comparison_TPEL             % Figs 3-4: IRFP450 model vs. PSpice
```

---

## Device Parameters

### Si IGBT (IXGH60N60C2) — Baseline [J1]

| Parameter | Symbol | Value | Unit |
|-----------|--------|-------|------|
| DC-link voltage | V_bus | 400 | V |
| Power-loop inductance | L_circ | 80–180 | nH |
| Power-loop resistance | R_circ | 1 | Ω |
| Gate resistance | R_g | 10–70 | Ω |
| Gate-lead inductance | L_g | 3 | nH |
| Emitter inductance | L_e | 5 | nH |
| Collector inductance | L_c | 1 | nH |
| Gate-emitter capacitance | C_ge | 3793 | pF |
| Gate-collector cap. (Miller) | C_gc | 75 | pF |
| Collector-emitter cap. | C_ce | 183 | pF |
| Rise time (V_CE) | t_r | 50 | ns |

### Si MOSFET (IRFP450, International Rectifier) — Extended [TPEL]

| Parameter | Symbol | Value | Unit |
|-----------|--------|-------|------|
| DC-link voltage | V_bus | 400 | V |
| Power-loop inductance | L_circ | 80 | nH |
| Source inductance | L_e | 13 | nH |
| Drain inductance | L_c | 5 | nH |
| Gate-source capacitance | C_ge | 3850 | pF |
| Gate-drain cap. (Miller) | C_gc | 350 | pF |
| Drain-source cap. | C_ce | 520 | pF |
| Rise time (V_DS) | t_r | 50 | ns |

---

## Analytical Model Summary

The crosstalk voltage V_ge(t) on the passive switch is derived by applying KCL at three circuit nodes — gate (V_g), collector (V_c), and emitter (V_e) — in the Laplace domain. The high-side switch commutation is modelled as a ramp excitation:

```
V_exc(s) = V_bus · (1 − e^(−s·tr)) / (s²·tr)
```

MATLAB's `ilaplace()` inverts the closed-form solution back to the time domain. A correction factor of 0.8 accounts for the linear-ramp overestimation of the actual V_CE fall. See [`docs/theory.md`](docs/theory.md) for the full derivation.

---

## License

This code is provided for academic and research use. Please cite the relevant publication(s) above if this work contributes to your research.

---

*For questions or collaboration inquiries, contact: am.azrajabian@gmail.com*
