# Synchronous FIFO – ASIC Design and Physical Implementation

## Overview

A parameterized synchronous FIFO designed using Verilog RTL and implemented through an open-source ASIC design flow using the SKY130A PDK.

## Design Specifications

| Parameter | Value |
|---|---|
| Data Width | 8 bits |
| FIFO Depth | 16 |
| Address Width | 4 bits |
| Clock | Single clock |
| Reset | Synchronous, active-high |
| Technology | SKY130A |

## Features

- Parameterized FIFO architecture
- Read and write pointer management
- Occupancy counter
- Full and empty flags
- Almost-full and almost-empty flags
- Pointer wrap-around
- Simultaneous read/write handling
- Boundary-condition handling

## Tools Used

- Verilog
- Icarus Verilog
- Yosys
- LibreLane
- OpenROAD
- SKY130A PDK
- Magic
- KLayout

## Functional Verification

A self-checking testbench was developed covering reset, basic read/write operations, FIFO boundaries, simultaneous operations, pointer wrap-around and data-order verification.

All implemented testbench scenarios passed.

## Synthesis Results

SKY130A technology mapping using Yosys:

- Mapped cells: 439
- Mapped cell area: 5928.19 um^2

## Physical Design Results

Physical implementation performed using LibreLane and OpenROAD.

| Metric | Result |
|---|---:|
| Standard-cell instances | 697 |
| Standard-cell area | 8067.74 um^2 |
| Core area | 11320.9 um^2 |
| Die area | 15132.3 um^2 |
| Utilization | 71.26% |
| Worst setup slack | +11.4787 ns |
| Hold slack | +0.1123 ns |
| Estimated total power | 1.3247 mW |
| DRC errors | 0 |
| LVS errors | 0 |

Power is an implementation estimate, not a silicon measurement.

## Remaining Electrical Warnings

The initial implementation reports:

- 27 maximum-slew violations at max_ss_100C_1v60
- 1 maximum-fanout violation
- 0 maximum-capacitance violations

Additional floating-net and unannotated clock-load reports are documented in the implementation results.

These issues require further investigation before claiming completely clean electrical signoff.

## Repository Structure

- `rtl/` – Verilog RTL
- `tb/` – Testbench
- `simulation/` – Simulation files
- `synthesis/` – Synthesized netlists and reports
- `physical_design/` – Configuration and physical-design results
- `docs/` – Additional documentation

## Project Status

- RTL implementation completed
- Functional testbench suite passed
- Generic and SKY130A synthesis completed
- Physical implementation completed
- GDSII generated
- DRC and LVS reported zero errors
- Remaining electrical warnings documented

## Future Work

- Investigate remaining slew and fanout violations
- Improve physical implementation
- Perform further verification and timing analysis
