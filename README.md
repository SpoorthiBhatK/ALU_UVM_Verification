**ALU_Verification(UVM)**

This project implements a configurable **Arithmetic Logic Unit (ALU)**
supporting arithmetic, logical, comparison, rotate, and multi-cycle
multiplication operations.

The ALU is parameterized by data width (`DW`) and command width (`CW`)
and uses an `INP_VALID`-based input-capture mechanism to accept operands
independently or simultaneously.

## Features

- Parameterizable data width (`DW`) and command width (`CW`)
- Two-stage operand capture using `INP_VALID`
- Arithmetic and logical operation modes
- 3-cycle multiplication operations with preprocessing
- Clock Enable (`CE`) support
- Asynchronous active-high Reset (`RST`)
- Carry, overflow, comparison, and error flags
- Operand wait mechanism for receiving the second operand
- 16-cycle wait window for the second operand
- Timeout error indication when the second operand is not received
- Latest operand value takes priority when operands are updated during
  the wait period
