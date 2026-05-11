# Amir Azam Rajabian

**Power Electronics Researcher**  
am.azrajabian@gmail.com

---

## Research — Phase-Leg Crosstalk in Si Power Converters

My research focuses on the analytical modelling and experimental validation of **inductive-load phase-leg crosstalk** in Si IGBT and Si MOSFET half-bridge converters.

**Crosstalk** (false turn-on / Miller turn-on) is the parasitic gate-emitter voltage spike induced on a passive switch when its complementary device commutates. If the spike exceeds the threshold voltage, an unintended shoot-through event occurs. My work derives a closed-form Laplace-domain model that predicts crosstalk amplitude as a function of gate resistance, emitter inductance, device capacitances, and switching speed — validated experimentally at 400 V / 22 A using the IXGH60N60C2 IGBT.

---

## Publications

| | Venue | Title | DOI |
|-|-------|-------|-----|
| **[C1]** | PEDSTC 2022 | Investigating the Effect of the Power Path Parasitic Inductance on Si-IGBT Crosstalk | [10.1109/PEDSTC53976.2022.9767324](https://doi.org/10.1109/PEDSTC53976.2022.9767324) |
| **[C2]** | EPE'22 ECCE Europe | Characterization of Si-IGBT Crosstalk with a Concentration on Power Circuit Parasitic Elements | [10.1109/EPE22ECCEEurope50083.2022.9907736](https://doi.org/10.1109/EPE22ECCEEurope50083.2022.9907736) |
| **[J1]** | IEEE JESTIE 2024 | Interrelation of Gate Resistance and Emitter/Source Inductance Impact on Inductive Load Phase-Leg Crosstalk | [10.1109/JESTIE.2024.3476274](https://doi.org/10.1109/JESTIE.2024.3476274) |
| **[TPEL]** | IEEE TPEL *(In Preparation)* | Extension to Si MOSFET; analytical switching waveform model | — |

> All publications co-authored with S. Mohsenzade.

---

## Model Summary

The gate-emitter crosstalk voltage V_ge(t) is derived by applying KCL at three circuit nodes in the Laplace domain, driven by a ramp excitation representing the high-side switch V_CE transient. The analytical solution is inverted symbolically using MATLAB's `ilaplace()`. Key findings:

- The **positive spike** scales with Miller capacitance C_gc and dV/dt; increasing R_g reduces it
- The **negative spike** is driven by L_e–C_ge resonance; there is an optimal (R_g, L_e) design region that minimises both spikes simultaneously
- The model is validated experimentally across R_g = 10–70 Ohm and L_e = 10–52 nH

---

*For collaboration or access to the research code, contact: am.azrajabian@gmail.com*
