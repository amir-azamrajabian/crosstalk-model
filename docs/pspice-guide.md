# PSpice Simulation Guide

This page explains the PSpice simulation workflow: how the half-bridge schematic is set up, how parametric sweeps are run, how results are exported as CSV, and how the PWL source is used to inject the analytically-derived V_CE waveform.

---

## Simulation Organization

PSpice files are organized by publication under `Simulations/PSpice/`:

```
Simulations/PSpice/
├── [C1]_PEDSTC_2022/      <- Power-loop inductance parametric study
├── [C2]_EPE_2022/         <- L_circ and V_bus sweeps
└── [J1]_JESTIE_2024/      <- R_g and L_e sweeps; experimental validation
```

Each subfolder contains the OrCAD `.opj` project file, schematic (`.DSN`), and any SPICE libraries (`.lib`) for the specific device under test.

> PSpice files for the in-preparation TPEL submission are maintained in a separate private repository.

---

## Half-Bridge Schematic Overview

The simulation uses a standard half-bridge (phase-leg) topology:

```
     V_bus (+)
        |
       Q_H  <-- Gate driver (PWL voltage source V_GH)
        |
        +---- Load node (L_load + R_load to negative rail)
        |
       Q_L  <-- Gate driver (off, V_GL = negative bias)
        |
     GND (-)
```

**Key parasitics modeled explicitly:**
- Power-loop inductance: `L_circ` in series with the DC bus
- Gate-lead inductance: `L_g` in series with each gate connection
- Emitter/source inductance: `L_e` between emitter terminal and PCB ground plane
- Collector/drain inductance: `L_c` between collector terminal and the half-bridge midpoint

**Device model:** The IGBT or MOSFET is represented by its large-signal SPICE model (from the manufacturer's website) in [C1], [C2], and [J1]. For the crosstalk model validation, the passive switch Q_L is sometimes simplified to an equivalent RC input network {C_ge, C_gc, C_ce} to isolate the capacitive crosstalk mechanism from the device switching dynamics.

---

## Parametric Sweeps

Cadence PSpice parametric sweeps are set up using the `PARAM` part and the `.STEP` SPICE directive:

### Gate Resistance Sweep (R_g, used in [J1])
```spice
.PARAM Rgate = 10
.STEP PARAM Rgate LIST 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
```

### Power-Loop Inductance Sweep (L_circ, used in [C1], [C2])
```spice
.PARAM Lcirc_val = 60n
.STEP PARAM Lcirc_val 60n 320n 10n
```

### DC-Link Voltage Sweep (V_bus, used in [C1], [C2])
```spice
.PARAM Vbus_val = 100
.STEP PARAM Vbus_val 100 650 10
```

---

## Exporting Results as CSV

After a transient simulation:

1. Open **Probe** (the PSpice waveform viewer).
2. Add the desired measurement: typically `V(gate_QL) - V(emitter_QL)` for V_ge, or `V(collector_QL)` for V_CE.
3. For parametric runs, use **Measure > Peak** or the **Goal Function** editor to extract the peak value per sweep step.
4. Export: **File > Export > CSV...** or use the `Eval Goal Function` to create a table.

**CSV format returned by the scripts:**
```
Row 1:  header / parameter labels
Row 2:  peak values for each sweep step (one value per column)
Cols:   2 to N+1 for N sweep steps
```

For example, `Positive_Fluctuation_RGate.csv` contains:
- Row 2, columns 2-22: positive V_ge values at R_g = 5, 6, ... 25 Ohm (21 points)

This is read in MATLAB as:
```matlab
sim = readmatrix('Positive_Fluctuation_RGate.csv');
V   = sim(2, 2:22);   % 21 peak values
```

---

## Using the Analytically-Derived PWL Source

The script `VCE_Waveform_Generator.m` exports a PSpice-compatible piecewise-linear (PWL) file `Input_Values.txt`.

**File format:**
```
t1_seconds   V1_volts
t2_seconds   V2_volts
...
```
Values are printed with 35-decimal-place precision to avoid PSpice interpolation errors at the sub-nanosecond scale.

**Inserting the PWL source in OrCAD:**
1. Place a `VPWL_FILE` part (from the PSpice source library).
2. Set the `FILE` property to the full path of `Input_Values.txt`.
3. Connect it in place of the standard gate-driver source for the high-side switch Q_H.
4. Run a transient simulation with `TMAX = 2us`, `TSTEP = 0.1ns`.

This allows the PSpice simulation to use the exact analytically-derived V_CE waveform as its stimulus, ensuring that the model and simulation operate under identical input conditions.

---

## Double-Pulse Test (DPT) Simulation

The double-pulse test verifies the test-bench operation and provides the realistic inductor current profile at the instant of commutation:

1. **First pulse** (e.g., 50 us): Q_H conducts; inductor L_load stores energy; I_L ramps up linearly.
2. **Off period** (e.g., 10 us): freewheeling diode D_FW conducts; I_L remains approximately constant.
3. **Second pulse** (e.g., 2 us): Q_H turns on against the full load current; the crosstalk transient of interest occurs at the beginning of this pulse.

The simulation waveform is exported and verified in `Experimental_Analysis_JESTIE.m` (Figure 5), showing gate-drive voltage and inductor current for the full DPT sequence.

---

## Oscilloscope Data Format (Tektronix)

Experimental captures are taken with a Tektronix oscilloscope and exported as CSV. File structure:

```
Rows 1-17:   Header block (instrument settings, date, units, etc.)
Row 18:      First data sample
Row 5017:    Last data sample  (5000 samples total)
Column 1:    Time [s]
Column 2:    Voltage [V]
```

MATLAB reads these as:
```matlab
sim = readmatrix('Gate_1.CSV');
t = sim(18:5017, 1);   % time vector
V = sim(18:5017, 2);   % voltage waveform
```

**Probe conditioning:** Raw waveforms include DC offset (up to +/-20 V due to differential probe zeroing) and nonlinear saturation at large amplitudes. Piecewise scaling corrections in `GateResistance_Comparison_JESTIE.m` restore the true waveform, calibrated by injecting a known-amplitude reference signal through the same probe chain.
