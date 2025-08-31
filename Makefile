# Makefile for UVM ALU Testbench
# Supports multiple SystemVerilog simulators

# Default simulator
SIMULATOR ?= vcs

# Source files
TOP_MODULE = top
SRC_DIR = src
SOURCES = $(TOP_MODULE).sv

# Compiler flags
VCS_FLAGS = -sverilog +define+UVM_NO_DPI -ntb_opts uvm-1.2 -debug_access+all
QUESTA_FLAGS = -sv +incdir+$(SRC_DIR) -timescale=1ns/1ps
XCELIUM_FLAGS = -uvm -access +rwc -timescale 1ns/1ps

# Default target
all: compile

# VCS compilation
vcs: clean
	@echo "Compiling with VCS..."
	vcs $(VCS_FLAGS) $(SOURCES) -o simv
	@echo "VCS compilation complete. Run with: ./simv"

# QuestaSim compilation  
questa: clean
	@echo "Compiling with QuestaSim..."
	vlib work
	vlog $(QUESTA_FLAGS) $(SOURCES)
	@echo "QuestaSim compilation complete. Run with: vsim -c $(TOP_MODULE) -do 'run -all'"

# Xcelium compilation
xcelium: clean
	@echo "Compiling with Xcelium..."
	xrun $(XCELIUM_FLAGS) $(SOURCES)

# Generic compile target (defaults to VCS)
compile:
	@echo "Compiling with $(SIMULATOR)..."
	@$(MAKE) $(SIMULATOR)

# Run simulation (VCS)
run: vcs
	@echo "Running simulation..."
	./simv

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf simv* csrc/ *.log *.vpd *.fsdb *.shm/ *.diag
	rm -rf work/ transcript *.wlf
	rm -rf xcelium.d/ *.history

# Help target
help:
	@echo "Available targets:"
	@echo "  all       - Compile with default simulator ($(SIMULATOR))"
	@echo "  vcs       - Compile with VCS"
	@echo "  questa    - Compile with QuestaSim"
	@echo "  xcelium   - Compile with Xcelium"
	@echo "  run       - Compile and run with VCS"
	@echo "  clean     - Clean build artifacts"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  SIMULATOR - Set simulator (vcs, questa, xcelium) [default: $(SIMULATOR)]"
	@echo ""
	@echo "Examples:"
	@echo "  make                    # Compile with VCS"
	@echo "  make SIMULATOR=questa   # Compile with QuestaSim"
	@echo "  make run                # Compile and run with VCS"

.PHONY: all vcs questa xcelium compile run clean help