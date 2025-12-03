# 📰 Newspaper Vending Machine FSM in Verilog HDL

*Model a real-life vending scenario: The machine dispenses a newspaper once coins totaling 15 units (5- and 10-unit coins) are inserted.*

---

## Table of Contents

- [About](#about)
- [Features](#features)
- [FSM Architecture](#fsm-architecture)
- [Simulation & Output](#simulation--output)
- [File Structure](#file-structure)
- [How to Run](#how-to-run)
- [License](#license)
- [Contact](#contact)

---

## About

This project implements a **Newspaper Vending Machine** as a concise Finite State Machine (FSM) in Verilog. The machine dispenses a newspaper ("newspaper" output = 1) when a combination of coins adds up to 15 units. It is a textbook hardware design problem, simulating real vending logic: coins of 5 or 10 units can be entered, and the machine supports proper resets and synchronous operation.

---

## Features

- **FSM-based design:** Accurately tracks coins to dispense output only at the correct sum.
- **Versatile simulation:** Demonstrates functionality with various coin sequences.
- **Robust testbench:** Includes real-world usage and reset scenarios.
- **Synthesizable code:** Suitable for FPGAs/ASICs and educational purposes.

---

## FSM Architecture

| State | Meaning                  | Transitions                                      |
|-------|--------------------------|--------------------------------------------------|
| s0    | 0 units (Initial/Reset)  | 5 → s5, 10 → s10, else s0                        |
| s5    | 5 units                  | 5 → s10, 10 → s15, else s5                       |
| s10   | 10 units                 | 5/10 → s15, else s10                             |
| s15   | 15 units (Dispense)      | (outputs newspaper=1), resets to s0 on next clk   |

- **Coin Input Encoding:**  
  - `2'b00` = No coin  
  - `2'b01` = 5-unit coin  
  - `2'b10` = 10-unit coin

---

## Simulation & Output

**Testbench Scenarios:**
- 3 × 5-unit coins
- (5-unit + 10-unit) coin
- 2 × 10-unit coins (overpayment)
- Reset at runtime

#### Output Example

```text
  Time   Reset Newspaper
   420     0       1   // Dispense after 3 × 5-unit coins
   460     0       0
   660     0       1   // Dispense after 5 + 10 coins
   700     0       0
  1100     0       1   // Dispense after two 10-coins (with gap)
  1140     0       0
```

#### Waveform

Generate with:
```sh
gtkwave wave.vcd
```
Analyze clock, resets, input coins, and dispensing pulses visually.

---

## File Structure

```
.
├── news.v      // FSM implementation (newspaper vending logic)
├── newstb.v    // Testbench (instantiates FSM, applies stimulus)
├── README.md   // Project documentation
```

---

## How to Run

**1. Simulation**  
Use Icarus Verilog or your favorite simulator:

```sh
iverilog -o newstb newstb.v news.v
vvp newstb
```

**2. View Waveforms**  
```sh
gtkwave wave.vcd
```

---

## License

This project is licensed under the [MIT License](LICENSE).  
&copy; 2025 Tejas R Mallah

---

## Contact

- **LinkedIn:** [Tejas R Mallah](https://www.linkedin.com/posts/tejas-r-mallah-28052b283_verilog-fpga-digitaldesign-activity-7364343834392113152-s981?utm_source=share&utm_medium=member_desktop&rcm=ACoAAET0mcABoSmVvowkUz7qcSZkG2bhRVZnDQ4)
- **Email:** tejasmallah@gmail.com

---

_Always open to opportunities and collaboration in digital design, FPGA, and hardware verification!_

```
#Verilog #DigitalDesign #FSM #VendingMachine #FPGA #RTL #HardwareDesign #Testbench #StateMachine
```
