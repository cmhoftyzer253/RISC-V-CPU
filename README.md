# **TBD: A 64-bit RISC-V CPU in SystemVerilog**

<img width="1168" height="755" alt="image" src="https://github.com/user-attachments/assets/ed6ea207-5f66-47c6-b288-477802db59b7" />

## Motivation
After discovering my interest in digital hardware design during my Electrical Engineering degree, I started this project to satisfy my interest in the field with several main goals in mind:

1.  Escape "tutorial hell" and build a substantial project independently.
2.  Gain a deeper understanding of how CPUs and digital hardware operate and are designed.
3.  Explore architectural trade-offs and how high-level design decisions affect power, timing, and area.
4.  Become a better digital hardware designer by working on a challenging project.

This project is a **64-bit RISC-V RV64IM** core. This core goes beyond typical single-cycle toy processors built in courses, implementing advanced architecture features, a realistic memory hierarchy, and system-level integration.

## Key Microarchitectural Features

### Execution Units
* **Pipelined Multiplier:**
    * Splits operands into upper and lower segments and performs two parallel 32-bit multiplications per clock cycle.
    * **Latency:** 3 cycles for word, 5 cycles for double word instructions.
* **Non-Restoring Divider:**
    * **Latency:** Varies from 1-64 clock cycles depending on operand sizes.
    * Small operands ($\le 15$, unsigned or positive) are purely combinational and are completed in one clock cycle.
    * Input shifting is performed before the non-restoring division loop to eliminate redundant division steps.

### Memory System
* **Caches:**
    * 32 KiB Instruction and Data caches.
    * Both are 4-way Set Associative with a write-back eviction policy.
    * Interfaces with main memory using **AXI4-Lite** protocol.
* **Clock Domain Crossing (CDC):**
    * My FPGA has a 512MB DDR3 memory, operating on a separate clock from the CPU core.
    * **Asynchronous FIFOs** move data between DDR and CPU clock domains.

### Peripherals & System
* **Boot ROM:** 4KiB of Boot ROM memory dedicated to boot instructions.
* **Exception Handling:** Full hardware support for exceptions.
* **Interrupts:** Supports software, timer, counter overflow, and a gateway for 8 external interrupts.

## Current Status: Verification
I am currently focused on verification of the core. While I've written directed testbenches for individual modules, this is not sufficient for a project of this complexity. I am currently learning more about verification and developing a testbench setup that will cover:

* **Block Level:** Verification of individual modules.
* **Integration:** Verification of key interfaces such as Fetch $\leftrightarrow$ I-Cache, Memory $\leftrightarrow$ D-Cache, PLIC $\leftrightarrow$ Trap Controller.
* **System Level:** Running full test suites to ensure correct behavior for I, M, and privileged instructions.

## Roadmap & Next Steps
I view this as a long-term project with the goal of emulating as closely as possible the features and architecture of a commercial CPU/SoC. There are several features and design improvements I plan to work on next:

* **Distributed Control Logic:** Move control signal generation from solely being done during Decode stage to a distributed model. This will save power and area by eliminating unnecessary pipeline registers.
* **Multiplier Updates:** Implement a Wallace or Dadda tree instead of using DSP slices.
* **ISA Extensions:** Add Floating Point (F) and Atomic (A) extensions.
* **Branch Prediction:** Improve pipeline performance by adding a branch predictor.
* **Privilege Modes:** Add User and Supervisor modes for security and future OS support.
* **Peripheral Expansion:** Add support for standard protocols (UART, SPI, USB, VGA) to support real-world IO.

## Long Term Vision
My long-term goal for this project is to move from a softcore CPU project to a full computing system. This would include:

* **Software:** Boot an OS like Linux or XV6 and add a graphical interface.
* **Hardware:** Move from FPGA devboard to custom PCB with a surface mounted FPGA or ASIC tapeout, DDR memory, and dedicated peripheral ports including USB, Ethernet, and HDMI.
