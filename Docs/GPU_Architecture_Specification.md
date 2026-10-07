Custom Multi-Core SIMT GPU

Architecture Specification



Version: 1.0



1.Project Objective



The objective of this project is to design and implement a scalable custom GPU architecture based on the SIMT (Single Instruction, Multiple Threads) execution model using SystemVerilog RTL.



The proposed GPU will consist of multiple Streaming Multiprocessors (SMs), where each SM contains a warp scheduler, SIMD execution units, register file, shared memory, load/store unit, and L1 cache. The complete GPU will also include an L2 cache, memory controller, and on-chip interconnect/Network-on-Chip (NoC).



The project will focus on the complete digital VLSI design flow, beginning with architectural specification and RTL design, followed by functional verification, synthesis, timing analysis, and ASIC physical implementation using an open-source RTL-to-GDSII flow.



The GPU architecture will be evaluated using parallel workloads such as vector addition, vector multiplication, matrix multiplication, and branch-divergence tests. Performance metrics including execution latency, throughput, cache hit rate, warp utilization, area, timing, and power will be analyzed.



The final objective is to demonstrate a complete, scalable, and verifiable custom GPU architecture suitable for digital VLSI and computer architecture research.





2\. GPU Architecture



3\. GPU Specifications

4\. GPU Instruction Set

5\. SIMT Execution Model

6\. Streaming Multiprocessor Architecture

7\. Memory Hierarchy

8\. NoC Architecture

9\. Verification Strategy

10\. Synthesis and ASIC Implementation

