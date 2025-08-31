# UVM_ALU_TB

A comprehensive UVM (Universal Verification Methodology) testbench for ALU (Arithmetic Logic Unit) verification.

## Project Structure

```
UVM_ALU_TB/
├── README.md              # Project documentation
├── top.sv                 # Top-level testbench module
└── src/                   # Source files directory
    ├── defines.sv         # Global definitions and constants
    ├── alu_if.sv          # ALU interface definition
    ├── alu_design.sv      # ALU design under test (DUT)
    ├── alu_pkg.sv         # UVM package with all verification components
    ├── alu_sequence_item.sv    # Transaction item definition
    ├── alu_sequence.sv         # Test sequences
    ├── alu_sequencer.sv        # UVM sequencer
    ├── alu_driver.sv           # UVM driver
    ├── alu_monitor.sv          # UVM monitor
    ├── alu_agent.sv            # UVM agent
    ├── alu_scoreboard.sv       # UVM scoreboard for checking
    ├── alu_subscriber.sv       # Coverage collector
    ├── alu_environment.sv      # UVM environment
    ├── alu_test.sv            # Test cases
    ├── alu_bind.sv            # Bind statements for assertions
    └── alu_assertions.sv      # SystemVerilog assertions
```

## Features

- **Complete UVM Testbench**: Full UVM environment with driver, monitor, scoreboard, and coverage
- **ALU Operations**: Support for arithmetic and logical operations
  - Arithmetic: ADD, SUB, INC, DEC, CMP, etc.
  - Logical: AND, OR, XOR, NOT, shift operations, etc.
- **Comprehensive Coverage**: Functional coverage for inputs and outputs
- **Assertions**: SystemVerilog assertions for protocol and functional checking
- **Configurable**: Parameterized design with configurable operand width

## ALU Operations

### Arithmetic Mode (MODE=1)
- ADD, SUB: Basic addition and subtraction
- ADD_CIN, SUB_CIN: Addition/subtraction with carry input
- INC_A, DEC_A: Increment/decrement operand A
- INC_B, DEC_B: Increment/decrement operand B
- CMP: Compare operation
- INC_MUL, SHL_MUL: Multiply operations (when MUL_OP is defined)

### Logical Mode (MODE=0)
- AND, NAND, OR, NOR, XOR, XNOR: Basic logical operations
- NOT_A, NOT_B: Bitwise NOT operations
- SHR1_A, SHL1_A: Shift operations on operand A
- SHR1_B, SHL1_B: Shift operations on operand B
- ROL, ROR: Rotate operations

## Compilation

To compile and run the testbench:

```bash
# Using VCS (Synopsys)
vcs -sverilog top.sv +define+UVM_NO_DPI -ntb_opts uvm-1.2

# Using QuestaSim (Mentor Graphics)
vlog top.sv
vsim top -c -do "run -all"

# Using Xcelium (Cadence)
xrun top.sv -uvm
```

## Configuration

Key parameters can be configured in `src/defines.sv`:
- `OP_WIDTH`: Operand width (default: 8 bits)
- `CMD_WIDTH`: Command width (default: 4 bits)  
- `no_of_trans`: Number of transactions (default: 1500)
- `MUL_OP`: Enable multiplication operations (commented out by default)

## Running Tests

The testbench runs the base test by default. You can modify the test name in `top.sv`:

```systemverilog
run_test("alu_base_test");
```