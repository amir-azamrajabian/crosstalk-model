# Theory & Analytical Derivation

## 1. Circuit Model

The passive switch Q_L (the device subject to crosstalk) is modeled as a lumped three-port network with the following parasitic elements:

```
  Gate terminal  --- L_g --- R_g --+
                                   |
                             C_gc  |  C_ge
  Collector --- L_c -----------+---+----------- Emitter
                               |
                         L_e --+
                         |
                        GND
```

**Nodes defined:**
- V_g: gate node voltage (across C_ge from gate to emitter)
- V_c: collector node voltage (referred to the emitter reference)
- V_e: emitter node voltage (parasitic emitter inductance drop)

**Excitation:**  
The high-side switch V_CE transient is imposed as a voltage source at the collector of Q_L. It is modeled as a linear ramp from V_bus to 0 over the rise time t_r.

---

## 2. KCL Node Equations (Laplace Domain)

Applying KCL at each of the three independent nodes gives:

### Node V_g (Gate Node)

```
[V_g - V_exc] / (R_g + s*L_g) + V_g*s*C_ge + [V_g - V_c]*s*C_gc = 0
```

The first term is the gate drive current (through R_g and L_g). The second is the C_ge charging current. The third is the Miller current through C_gc.

### Node V_c (Collector Node)

```
[V_c - V_g]*s*C_gc + V_c*s*C_ce + V_c / (s*L_c) = V_exc / (s*L_c)
```

C_gc current balances with C_ce charging and the collector inductance current. The right-hand side is the excitation injected through L_c.

### Node V_e (Emitter Node)

```
V_e / (s*L_e) + V_e*s*C_ge - V_g*s*C_ge = 0
```

The emitter inductance current equals the C_ge current flowing from gate to emitter.

---

## 3. Excitation Waveform

The V_CE of the high-side switch (the driving disturbance) is modeled as a **linear ramp**:

```
v_exc(t) = V_bus * (1 - t/t_r)    for  0 <= t <= t_r
         = 0                        for  t > t_r
```

In the Laplace domain this becomes:

```
V_exc(s) = V_bus * (1 - exp(-s*t_r)) / (s^2 * t_r)
```

The `(1 - exp(-s*t_r))` term captures the ramp-then-hold nature using the time-shift theorem.

---

## 4. Symbolic Solution in MATLAB

The three KCL equations are linear in {V_g, V_c, V_e}. They are assembled symbolically using MATLAB's `syms` / `solve` toolbox:

```matlab
syms Vg Vc Ve s
eq1 = ...;   % Node Vg
eq2 = ...;   % Node Vc
eq3 = ...;   % Node Ve
sol = solve([eq1, eq2, eq3], [Vg, Vc, Ve]);
```

The gate-emitter voltage of Q_L is then:

```matlab
Vge_s = sol.Vg - sol.Ve;     % V_ge(s) in Laplace domain
Vge_t = ilaplace(Vge_s);    % Inverse Laplace -> time domain
```

`ilaplace()` returns a closed-form symbolic expression. This is converted to a numeric function handle using `matlabFunction()` for fast evaluation:

```matlab
f = matlabFunction(Vge_t);
t = linspace(0, 1e-6, 5000);
vge = f(t);
```

---

## 5. Correction Factor

The linear ramp is an approximation of the actual V_CE waveform, which has a slower rise at the beginning (due to device output capacitance charging) and a steeper fall at the end (LC resonance). The linear ramp systematically *overestimates* the peak crosstalk voltage by approximately 25%.

An empirical correction factor of **0.8** is applied to the positive spike prediction:

```
V_ge,corrected = 0.8 * V_ge,model
```

This factor was calibrated against PSpice simulation results across the full R_g sweep (10-70 Ohm) and validated experimentally at four operating points.

---

## 6. Negative Spike Mechanism

After the positive spike, the energy stored in L_e and C_ge rings down, producing a **negative undershoot** below the quiescent gate-emitter voltage (typically -V_GS,off). The frequency of this resonance is:

```
f_ring = 1 / (2*pi * sqrt(L_e * C_ge))
```

For the IGBT test bench (L_e = 5 nH, C_ge = 3793 pF):

```
f_ring = 1 / (2*pi * sqrt(5e-9 * 3793e-12)) = approx. 36.5 MHz
```

The negative spike amplitude follows the relation:

```
V_ge,neg = V_ge,pos - dV_resonance
```

where dV_resonance is approximately 9.5 V for the IGBT (IXGH60N60C2) configuration. This offset is validated in `GateResistance_Comparison_JESTIE.m`.

---

## 7. Voltage-Dependent Miller Capacitance

The gate-collector (Miller) capacitance C_gc is **strongly voltage-dependent** due to the depletion-layer widening at high V_CE. It is modeled as the series combination of a fixed oxide capacitance C_ox and a voltage-dependent junction capacitance C_gc,J:

```
C_gc(V_CE) = C_ox * C_gc,J(V_CE) / (C_ox + C_gc,J(V_CE))

where  C_gc,J(V_CE) = X_param / sqrt(V_CE - V_GE,th)
```

The two parameters {C_ox, X_param} are extracted by fitting to two datasheet points:

```
C_gc(25 V) = 97 pF
C_gc(30 V) = 90 pF   (IXGH60N60C2 datasheet, V_GE = 0 V)
```

An average value is computed over the full V_CE swing from 25 V to V_bus = 400 V and used as a constant in the KCL model. This is implemented in `CGC_Capacitance_Model.m`.

---

## 8. Phase 1 / Phase 2 Switching Model (TPEL Extension)

The extended model divides the V_CE waveform into two phases. This work is in preparation for IEEE TPEL; the derivation is summarized here for completeness.

**Phase 1 (Miller Plateau):**  
Gate current flows entirely into C_gc; V_gs is clamped at the Miller plateau voltage V_GP = V_th + I_load / (2*g_fs). Two equations uniquely determine the rise time t_r and the intermediate V_CE value V_a:

```
(i)  I_load = (a * t_r^2 / 2) / (L_e + L_c)       [current rise]
(ii) t_r * (V_driver - V_GP) / R_g = C_gc,avg * (V_bus - V_a)   [charge balance]
```

where a = (V_driver - V_GP) / (R_g * C_gc,avg) is the V_CE fall rate.

**Phase 2 (Resonant Fall):**  
After the plateau, the inductor L_c and device output capacitance C_L form a resonant circuit. The analytical ODE solution gives oscillatory V_CE(t) and I_L(t) expressions.

> Code for this model extension is maintained in a separate private repository.
