# Custom-SIMT-GPU

A SystemVerilog RTL implementation of a custom SIMT-style GPU architecture developed and functionally verified in ModelSim.

## Architecture

```text
                         HOST
                           |
                           v
                  +------------------+
                  | Host Interface   |
                  +------------------+
                           |
                           v
                  +------------------+
                  | Command Dispatch |
                  +------------------+
                           |
                           v
                  +------------------+
                  |   Multi-SM GPU   |
                  +------------------+
                    |   |   |   |
                   SM0 SM1 SM2 SM3
                    |
          +---------+----------------+
          |                          |
          v                          v
     Execution                  Memory Subsystem
     Components                 LSU -> L2 -> MC

                    +----------------+
                    |      NoC       |
                    +----------------+
```

## Major RTL Blocks

- Control Unit
- GPU Core
- Instruction Decoder
- Register File
- Program Counter
- Integrated GPU SM
- Warp Scheduler
- SIMT Controller
- Shared Memory
- L1 Cache
- Load/Store Unit
- L2 Cache
- Memory Controller
- NoC
- Multi-SM GPU
- GPU Top
- Host Interface
- Command & Dispatch Unit
- GPU System Integration
- Full GPU System Integration

## Verification Status

Individual modules and subsystem-level integrations were functionally verified in ModelSim. The final regression contains 117 checks and completed with zero failures.

Final regression result:

```text
PASSED : 117
FAILED : 0
ALL FINAL GPU SYSTEM REGRESSION TESTS PASSED
```

## Final Regression Coverage

The final regression checks:

- complete reset behavior
- host command reception
- command dispatch to all four SMs
- ADD, SUB, MUL, AND, OR, XOR and ADDI execution
- multi-SM execution consistency
- program-counter synchronization
- memory store path
- memory load path
- L2 miss and cache fill
- L2 cache hit
- L2 write hit
- updated cache data
- unaligned memory access detection
- simultaneous load/store rejection
- NoC packet routing
- NoC destination collision handling
- host readback
- invalid host access

## Tools

- Verilog/SystemVerilog
- ModelSim Intel FPGA Edition 2020.1

## Important Implementation Note

The current final wrapper verifies the GPU execution path, memory subsystem interface, and NoC behavior at the integrated top level. The present RTL does not expose a complete internal SM-to-LSU-to-cache-to-memory transaction path through `multi_sm_gpu`; consequently, the final regression should be described as an integrated top-level verification rather than a claim of a physically complete production GPU memory datapath.

## Final Evidence Files

Recommended files in `Results/Simulation`:

```text
final_gpu_system_test.txt
gpu_system_wave.do
gpu_system_waveform.png
final_gpu_system_wave.do
final_gpu_system_waveform.png
```

## Suggested Project Structure

```text
Custom-SIMT-GPU/
|
+-- RTL/
|   +-- all SystemVerilog RTL files
|
+-- TB/
|   +-- individual module testbenches
|   +-- tb_gpu_system.sv
|   +-- tb_full_gpu_system.sv
|   +-- tb_final_gpu_system.sv
|
+-- Simulation/
|   +-- ModelSim project files
|
+-- Results/
|   +-- Simulation/
|       +-- test results
|       +-- waveform .do files
|       +-- waveform .png files
|
+-- Docs/
|   +-- GPU_Architecture_Specification.md
|   +-- README.md
|   +-- FINAL_VERIFICATION_REPORT.md
|
+-- README.md
```
