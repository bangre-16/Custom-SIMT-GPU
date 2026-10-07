# Custom SIMT GPU — Verilog/SystemVerilog FPGA Project

## Overview

This project implements a custom **SIMT (Single Instruction, Multiple
Threads) GPU architecture** using Verilog/SystemVerilog. The design was
functionally verified using **ModelSim Intel FPGA Edition 2020.1** and
subsequently synthesized and physically implemented using **Intel
Quartus Prime Lite 25.1**.

Target FPGA:

- Family: Cyclone IV E
- Device: EP4CE6F17C8
- Quartus top-level: `gpu_layout_top`

## Architecture

The design contains a host interface, command and dispatch logic, a
multi-SM GPU, and a hierarchical memory subsystem.

``` text
Host Interface
      |
      v
Command & Dispatch Unit
      |
      v
   Multi-SM GPU
      |
      +--------------------+
      |                    |
      v                    v
 GPU SMs              Memory Subsystem
      |                    |
      |              +-----+-----+-----+
      |              |     |     |     |
      |             L1    L2    LSU   MC
      |                    |
      +--------------------+
               |
              NoC
```

The multi-SM configuration contains four GPU core/SM instances:

- SM\[0\]
- SM\[1\]
- SM\[2\]
- SM\[3\]

## Major RTL Components

### Compute and Control

- Control Unit
- GPU Core
- Instruction Decoder
- Program Counter
- Register File
- SIMT Controller
- Warp Scheduler
- Integrated GPU SM
- Multi-SM GPU
- GPU Top

### Memory Subsystem

- Shared Memory
- L1 Cache
- L2 Cache
- Load/Store Unit
- Memory Controller
- Memory Subsystem Integration

### System-Level Components

- NoC
- Host Interface
- Command & Dispatch Unit
- Full GPU System
- FPGA layout/top-level wrapper

## SIMT Execution

The architecture follows a SIMT execution model in which threads are
organized into warps. The warp scheduler selects work, the instruction
decoder decodes instructions, and the SIMT controller manages parallel
execution and control flow.

Simplified flow:

``` text
Host Command
     |
     v
Command & Dispatch
     |
     v
GPU / SM Selection
     |
     v
Warp Scheduling
     |
     v
Instruction Decode
     |
     v
SIMT Execution
     |
     +--> Register File
     +--> Shared Memory / L1
     +--> L2 Cache
     +--> Memory Controller
```

## Verification

RTL simulation and verification were performed with **ModelSim Intel
FPGA Edition 2020.1**.

The project was verified progressively from individual modules through
full-system integration.

### Integration Results

| Verification Stage                     |         Result |
|----------------------------------------|---------------:|
| Command & Dispatch Unit                | **60/60 PASS** |
| Memory Subsystem Integration           | **30/30 PASS** |
| Host → Dispatch → Multi-SM Integration | **73/73 PASS** |
| Full GPU System Integration            | **62/62 PASS** |

Final full-system result:

``` text
PASSED : 62
FAILED : 0

ALL FULL GPU SYSTEM INTEGRATION TESTS PASSED
```

Waveform and verification evidence is stored under:

``` text
Results/Simulation/
```

## FPGA Implementation

The verified RTL was synthesized and implemented using **Intel Quartus
Prime Lite 25.1**.

The final Quartus compilation completed successfully:

``` text
Quartus Prime Full Compilation was successful.
0 errors
29 warnings
```

### Resource Utilization

| Resource                           | Used | Available | Utilization |
|------------------------------------|-----:|----------:|------------:|
| Logic Elements                     |  545 |     6,272 |          9% |
| Registers                          |  155 |         — |           — |
| Pins                               |  162 |       180 |         90% |
| Memory Bits                        |    0 |   276,480 |          0% |
| Embedded Multiplier 9-bit Elements |    6 |        30 |         20% |
| PLLs                               |    0 |         2 |          0% |

## Timing Status

Quartus Timing Analyzer completed successfully with zero errors.

Current reported timing values:

``` text
Worst-case setup slack : -5.246 ns
Worst-case hold slack  :  0.188 ns
Minimum pulse width    : -3.000 ns
```

The design is **not fully timing constrained** and currently has
negative setup and minimum-pulse-width slack. Therefore, this
implementation should be treated as an architectural/RTL FPGA
implementation and physical-layout demonstration rather than a
timing-closed production FPGA design.

## Physical Implementation Evidence

Quartus physical implementation was inspected using:

- RTL Viewer
- Technology Map Viewer — Post-Fitting
- Chip Planner
- Routing Utilization
- Physical GPU placement

The `full_gpu_system` hierarchy was located in Chip Planner, with:

``` text
Located 641 nodes
```

Relevant evidence files are stored in:

``` text
Results/Simulation/
```

Expected evidence includes:

``` text
quartus_rtl_viewer.png
quartus_technology_map_post_fitting.png
quartus_chip_planner.png
quartus_gpu_placement.png
quartus_routing_utilization.png
```

## Project Structure

``` text
Custom-SIMT-GPU/
│
├── RTL/
│   └── Verilog/SystemVerilog design files
│
├── TB/
│   └── Unit, subsystem, and system testbenches
│
├── Simulation/
│   └── Simulation-related files
│
├── Results/
│   └── Simulation/
│       ├── Waveforms
│       ├── Verification logs
│       └── Quartus implementation evidence
│
├── Docs/
│   └── Project documentation
│
├── output_files/
│   └── Quartus compilation outputs
│
├── db/
├── incremental_db/
├── work/
│
├── Custom-SIMT-GPU.qpf
└── gpu_layout_top.qsf
```

## Tools Used

| Tool                               | Purpose                           |
|------------------------------------|-----------------------------------|
| Verilog/SystemVerilog              | RTL design                        |
| ModelSim Intel FPGA Edition 2020.1 | Simulation and verification       |
| Intel Quartus Prime Lite 25.1      | FPGA synthesis and implementation |
| Cyclone IV E EP4CE6F17C8           | Target FPGA                       |

## Verification Flow

``` text
Individual RTL Modules
        |
        v
Subsystem Verification
        |
        v
Memory Subsystem Verification
        |
        v
Host → Dispatch → Multi-SM Verification
        |
        v
Full GPU System Verification
        |
        v
Quartus Synthesis
        |
        v
Fitting / Placement / Routing
        |
        v
Physical Layout Evidence
```

## Current Status

- **RTL/module verification:** COMPLETE
- **Subsystem verification:** COMPLETE
- **Full GPU system verification:** COMPLETE
- **Quartus compilation:** COMPLETE
- **FPGA placement/routing inspection:** COMPLETE
- **Timing closure:** NOT COMPLETE

## Future Work

Possible extensions include:

1.  Add complete timing constraints and perform timing closure.
2.  Optimize logic utilization and routing.
3.  Improve clock/reset distribution.
4.  Expand the GPU instruction set.
5.  Add more realistic pipelined ALU execution.
6.  Improve cache and memory hierarchy behavior.
7.  Expand warp divergence/reconvergence support.
8.  Increase the number of SMs.
9.  Add performance counters and profiling.
10. Validate the architecture on a larger FPGA.
11. Explore ASIC implementation using an RTL-to-GDSII flow such as
    OpenLane.

## Conclusion

This project demonstrates a custom SIMT GPU from **RTL design and
module-level verification through full-system integration and FPGA
physical implementation**.

The design was functionally verified using ModelSim, successfully
compiled using Quartus Prime Lite, and physically inspected using
RTL/technology mapping, chip planning, routing, and placement tools.

The project therefore provides both functional verification evidence and
FPGA implementation evidence for the custom SIMT GPU architecture.

## Author

Darshan N S

Bachelor of Engineering (B.E.) – Electrical and Electronics Engineering (EEE)

Dayananda Sagar Academy of Technology and Management (DSATM), Bengaluru
