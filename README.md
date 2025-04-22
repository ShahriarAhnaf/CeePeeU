# 5-Stage Pipelined Scalar CPU

## Overview

This project implements a **5-stage pipelined scalar CPU** based on a classic RISC architecture. The pipeline is structured into the following stages:

1. **IF (Instruction Fetch)**
2. **ID (Instruction Decode & Register Fetch)**
3. **EX (Execute / ALU operations)**
4. **MEM (Memory Access)**
5. **WB (Write Back)**

The goal is to achieve higher instruction throughput by overlapping the execution of instructions while managing hazards and pipeline control mechanisms effectively.

---

## Pipeline Design Stages

### 1. Instruction Fetch (IF)
- Fetches the next instruction from instruction memory.
- Updates the Program Counter (PC).
- Can be stalled by control hazards (e.g., unresolved branches).

### 2. Instruction Decode (ID)
- Decodes the instruction.
- Reads operands from the register file.
- Generates control signals for the rest of the pipeline.
- Handles hazards through forwarding or stalling if required.

### 3. Execute (EX)
- Performs ALU operations.
- Calculates memory addresses for load/store.
- Handles branch condition evaluation.
- Selects operands through a forwarding unit to avoid data hazards.

### 4. Memory Access (MEM)
- Performs read/write operations on data memory.
- Interacts with the memory subsystem, which may include stalling if memory is slow or unaligned.

### 5. Write Back (WB)
- Writes the result back to the register file.
- Final stage in the instruction lifecycle.

---

## Key Design Considerations

### 🔄 Pipeline Stalling
- Stalling occurs when an instruction in the pipeline must wait for a previous one to complete.
- Common stalling cases:
  - Data hazards (RAW: Read After Write)
  - Load-use hazards (e.g., using a loaded value in the next instruction)
  - Structural hazards (resource contention)
- Implemented via control signals that prevent pipeline registers from updating.

### ⚠️ Pipeline Hazards

#### 1. Data Hazards
- Resolved using:
  - **Data forwarding** (from EX/MEM/WB to earlier stages)
  - **Stalling** when forwarding is not possible (e.g., load-use hazards)

#### 2. Control Hazards
- Caused by branches and jumps.
- Solutions:
  - **Branch prediction** (static or dynamic)
  - **Flush instructions** if the branch is mispredicted
  - Delay slots (less common in modern designs)

#### 3. Structural Hazards
- Occur when hardware resources are insufficient.
- Avoided by ensuring separate read/write paths or using separate instruction/data memories (Harvard architecture).

### ⏱️ Combinational vs Sequential Logic

#### Combinational Logic:
- No memory elements, outputs depend solely on current inputs.
- Used for ALUs, decoders, control logic, and address generation.

#### Sequential Logic:
- Includes memory elements (flip-flops, latches).
- Used for registers, pipeline latches, PC updates, and state machines.

---

## Performance Metrics

- **CPI (Cycles Per Instruction)**: Ideal CPI = 1, increases due to stalls.
- **IPC (Instructions Per Cycle)**: Targeting IPC ≈ 1 with efficient hazard handling.
- **Throughput**: Measured in instructions per second (IPS).
- **Latency**: Number of cycles from instruction fetch to write-back.

---

## Future Extensions

- Dynamic branch prediction (e.g., 2-bit predictors)
- Out-of-order execution
- Superscalar extensions
- Hazard visualizer and simulation tools

---

## References

- Hennessy, John L., and David A. Patterson. *Computer Architecture: A Quantitative Approach*.
- Patterson, David A., and John L. Hennessy. *Computer Organization and Design*.
- MIT 6.004 - Computation Structures
- RISC-V Specifications

---

## Credits


The project structure heavily borrows the AWS EC2 FPGA HDK structure, [see here](https://github.com/aws/aws-fpga).
