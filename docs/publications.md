# Publications

All work in this repository supports the following peer-reviewed publications. All papers are authored by **A. Azam Rajabian and S. Mohsenzade** unless noted otherwise.

---

## [C1] PEDSTC 2022 — Conference Paper 1

**Full citation:**  
A. Azam Rajabian and S. Mohsenzade, "Investigating the Effect of the Power Path Parasitic Inductance on Si-IGBT Crosstalk," in *Proc. 13th Power Electronics, Drive Systems, and Technologies Conference (PEDSTC)*, Tehran, Iran, Feb. 2022.  
**DOI:** [10.1109/PEDSTC53976.2022.9767324](https://doi.org/10.1109/PEDSTC53976.2022.9767324)

**Contribution:**  
First conference presentation of the analytical KCL model. Demonstrates how power-loop inductance L_circ controls the dI/dt of the commutation current and thereby scales the positive crosstalk spike amplitude. Parametric study: L_circ = 60–320 nH at fixed R_g = 20 Ω, V_bus = 400 V.

**Associated MATLAB files:**  
- `MATLAB Codes/02_Parametric_Analysis/Parametric_Analysis.m` — Study 1 (L_circ sweep, Figure 1)
- `MATLAB Codes/04_Simulation_Plots/PSpice_Results_Plotter.m` — Figures 1–2 (L_circ comparison)
- `MATLAB Codes/03_Input_Modeling/Switching_Waveform_Plotter.m`

**Associated PSpice folder:**  
`Simulations/PSpice/[C1]_PEDSTC_2022/`

---

## [C2] EPE'22 ECCE Europe 2022 — Conference Paper 2

**Full citation:**  
A. Azam Rajabian et al., "Characterization of Si-IGBT Crosstalk with a Concentration on Power Circuit Parasitic Elements," in *Proc. 24th European Conference on Power Electronics and Applications (EPE'22 ECCE Europe)*, Hanover, Germany, Sep. 2022.  
**DOI:** [10.1109/EPE22ECCEEurope50083.2022.9907736](https://doi.org/10.1109/EPE22ECCEEurope50083.2022.9907736)

**Contribution:**  
Extends the [C1] model with a V_bus parametric study and introduces the voltage-dependent Miller capacitance model (C_gc fitting). Shows that the positive spike scales approximately linearly with V_bus, while the negative spike has a weaker dependence. Introduces the C_ox / X_param two-parameter C_gc(V_CE) model.

**Associated MATLAB files:**  
- `MATLAB Codes/01_Core_Model/CGC_Capacitance_Model.m` — C_gc(V_CE) model and fitting
- `MATLAB Codes/02_Parametric_Analysis/Parametric_Analysis.m` — Study 2 (V_bus sweep, Figure 2)
- `MATLAB Codes/04_Simulation_Plots/PSpice_Results_Plotter.m` — Figures 3–4 (V_bus comparison)

**Associated PSpice folder:**  
`Simulations/PSpice/[C2]_EPE_2022/`

---

## [J1] IEEE JESTIE 2024 — Journal Paper

**Full citation:**  
A. Azam Rajabian and S. Mohsenzade, "Interrelation of Gate Resistance and Emitter/Source Inductance Impact on Inductive Load Phase-Leg Crosstalk," *IEEE Journal of Emerging and Selected Topics in Industrial Electronics*, 2024.  
**DOI:** [10.1109/JESTIE.2024.3476274](https://doi.org/10.1109/JESTIE.2024.3476274)

**Contribution:**  
The primary journal publication. Key contributions:

1. **Closed-form crosstalk model** as a function of both R_g and L_e simultaneously — revealing their interrelated effect (increasing R_g and L_e both affect the positive spike but in opposing ways for the negative spike).
2. **Optimal (R_g, L_e) design region** that minimises worst-case spike amplitude for a given load current.
3. **Experimental validation** with a 400 V / 22 A double-pulse test bench using the IXGH60N60C2 IGBT at four gate resistance values (10, 15, 25, 70 Ω) and four emitter inductance values (10, 23, 33, 52 nH).

**Associated MATLAB files:**  
- `Publications/[J1]_JESTIE_2024/MATLAB/CrosstalkModel_JESTIE.m`
- `Publications/[J1]_JESTIE_2024/MATLAB/GateResistance_Comparison_JESTIE.m`
- `Publications/[J1]_JESTIE_2024/MATLAB/Experimental_Analysis_JESTIE.m`
- `MATLAB Codes/02_Parametric_Analysis/Parametric_Analysis.m` — Study 3 (R_g sweep, Figure 3)
- `MATLAB Codes/04_Simulation_Plots/PSpice_Results_Plotter.m` — Figures 5–6 (R_g comparison)

**Associated PSpice folder:**  
`Simulations/PSpice/[J1]_JESTIE_2024/`

---

## [TPEL] IEEE Transactions on Power Electronics — In Preparation

**Planned citation:**  
A. Azam Rajabian and S. Mohsenzade, *IEEE Transactions on Power Electronics* (In Preparation).

**Planned contributions:**

1. **Si MOSFET extension (IRFP450):** Applies the analytical crosstalk model to the IRFP450 Si MOSFET (International Rectifier), which has a significantly larger reverse transfer capacitance (C_rss = 350 pF) and higher package parasitics (L_e = 13 nH, L_c = 5 nH) compared to the IGBT. Validates against PSpice simulation across R_g = 5–25 Ohm. Datasheet: `Publications/[TPEL]_In_Preparation/Data/IRFP450.pdf`.

2. **Analytical switching waveform model:** Derives the V_CE(t) waveform analytically from circuit equations (Miller plateau + LC resonant fall) rather than using curve-fitted polynomials. This removes the dependency on per-device empirical fitting and makes the input model fully physics-based.

3. **Phase 1/Phase 2 analytical expressions:** Closed-form symbolic solutions for:
   - Rise time t_r and intermediate voltage V_a (Miller plateau phase)
   - Inductor current I_L(t) and V_CE(t) during the resonant fall phase

**Associated MATLAB files:**  
- `Publications/[TPEL]_In_Preparation/MATLAB/MOSFET_Comparison_TPEL.m`
- `Publications/[TPEL]_In_Preparation/MATLAB/SwitchingEquations_TPEL.m`
- `Publications/[TPEL]_In_Preparation/MATLAB/SwitchingInput_Generator_TPEL.m`

**Associated PSpice folder:**  
`Simulations/PSpice/[TPEL]_In_Preparation/`

---

## Citation Template (BibTeX)

```bibtex
@INPROCEEDINGS{AzamRajabian2022PEDSTC,
  author    = {Azam Rajabian, Amir and Mohsenzade, Saeed},
  title     = {Investigating the Effect of the Power Path Parasitic Inductance on {Si-IGBT} Crosstalk},
  booktitle = {Proc. 13th Power Electronics, Drive Systems, and Technologies Conference (PEDSTC)},
  year      = {2022},
  doi       = {10.1109/PEDSTC53976.2022.9767324}
}

@INPROCEEDINGS{AzamRajabian2022EPE,
  author    = {Azam Rajabian, Amir and others},
  title     = {Characterization of {Si-IGBT} Crosstalk with a Concentration on Power Circuit Parasitic Elements},
  booktitle = {Proc. 24th European Conference on Power Electronics and Applications (EPE'22 ECCE Europe)},
  year      = {2022},
  doi       = {10.1109/EPE22ECCEEurope50083.2022.9907736}
}

@ARTICLE{AzamRajabian2024JESTIE,
  author  = {Azam Rajabian, Amir and Mohsenzade, Saeed},
  title   = {Interrelation of Gate Resistance and Emitter/Source Inductance Impact on Inductive Load Phase-Leg Crosstalk},
  journal = {IEEE Journal of Emerging and Selected Topics in Industrial Electronics},
  year    = {2024},
  doi     = {10.1109/JESTIE.2024.3476274}
}
```
