
class alu_subscriber extends uvm_component;
  `uvm_component_utils(alu_subscriber)

  alu_sequence_item drv_trans;
  alu_sequence_item mon_trans;

  real drv_report;
  real mon_report;

  uvm_tlm_analysis_fifo #(alu_sequence_item) drv_fifo;
  uvm_tlm_analysis_fifo #(alu_sequence_item) mon_fifo;

  // Input functional coverage
  covergroup drv_cg;
    OPERAND_A: coverpoint drv_trans.opa {
      bins zero = {0};
      bins small_val = {[1:(1<<(`OP_WIDTH/2))-1]};
      bins medium_val = {[(1<<(`OP_WIDTH/2)):(1<<(`OP_WIDTH-1))-1]};
      bins large_val = {[(1<<(`OP_WIDTH-1)):(1<<`OP_WIDTH)-2]};
      bins max = {(1<<`OP_WIDTH)-1};
    }
    
    OPERAND_B: coverpoint drv_trans.opb {
      bins zero = {0};
      bins small_val = {[1:(1<<(`OP_WIDTH/2))-1]};
      bins medium_val = {[(1<<(`OP_WIDTH/2)):(1<<(`OP_WIDTH-1))-1]};
      bins large_val = {[(1<<(`OP_WIDTH-1)):(1<<`OP_WIDTH)-2]};
      bins max = {(1<<`OP_WIDTH)-1};
    }
    
    MODE: coverpoint drv_trans.mode {
      bins arithmetic = {1'b1};
      bins logical = {1'b0};
    }
    
    CMD_ARITH: coverpoint drv_trans.cmd iff (drv_trans.mode == 1) {
      bins add = {`ADD};
      bins sub = {`SUB};
      bins add_cin = {`ADD_CIN};
      bins sub_cin = {`SUB_CIN};
      bins inc_a = {`INC_A};
      bins dec_a = {`DEC_A};
      bins inc_b = {`INC_B};
      bins dec_b = {`DEC_B};
      bins cmp = {`CMP};
      bins inc_mul = {`INC_MUL};
      bins shl_mul = {`SHL_MUL};
    }

    CMD_LOGIC: coverpoint drv_trans.cmd iff (drv_trans.mode == 0) {
      bins and_op = {`AND};
      bins nand_op = {`NAND};
      bins or_op = {`OR};
      bins nor_op = {`NOR};
      bins xor_op = {`XOR};
      bins xnor_op = {`XNOR};
      bins not_a = {`NOT_A};
      bins not_b = {`NOT_B};
      bins shr1_a = {`SHR1_A};
      bins shl1_a = {`SHL1_A};
      bins shr1_b = {`SHR1_B};
      bins shl1_b = {`SHL1_B};
      bins rol = {`ROL};
      bins ror = {`ROR};
    }
    
    INP_VALID: coverpoint drv_trans.inp_valid {
      //bins none = {2'b00};
      bins a_only = {2'b01};
      bins b_only = {2'b10};
      bins both = {2'b11};
    }
    
    CIN: coverpoint drv_trans.cin {
      bins no_carry = {1'b0};
      bins carry = {1'b1};
    }
    
    CE: coverpoint drv_trans.ce {
      bins disabled = {1'b0};
      bins enabled = {1'b1};
    }

  endgroup

    // Output functional coverage
  covergroup mon_cg;
    RESULT: coverpoint mon_trans.res {
      bins zero = {0};
      `ifdef MUL_OP
      bins small_val = {[1:(1<<(`OP_WIDTH))-1]};
      bins medium_val = {[(1<<(`OP_WIDTH)):(1<<(2*`OP_WIDTH-1))-1]};
      bins large_val = {[(1<<(2*`OP_WIDTH-1)):(1<<(2*`OP_WIDTH))-1]};
      `else
      bins small_val = {[1:(1<<(`OP_WIDTH/2))-1]};
      bins medium_val = {[(1<<(`OP_WIDTH/2)):(1<<(`OP_WIDTH-1))-1]};
      bins large_val = {[(1<<(`OP_WIDTH-1)):(1<<`OP_WIDTH)-1]};
      `endif
    }
    
    COUT: coverpoint mon_trans.cout {
      bins no_carry = {1'b0};
      bins carry = {1'b1};
    }

    OFLOW: coverpoint mon_trans.oflow {
      bins no_overflow = {1'b0};
      bins overflow = {1'b1};
    }
    
    G_FLAG: coverpoint mon_trans.g {
      bins not_greater = {1'b0};
      bins greater = {1'b1};
    }

    L_FLAG: coverpoint mon_trans.l {
      bins not_less = {1'b0};
      bins less = {1'b1};
    }

    E_FLAG: coverpoint mon_trans.e {
      bins not_equal = {1'b0};
      bins equal = {1'b1};
    }
    
    ERR_FLAG: coverpoint mon_trans.err {
      bins no_error = {1'b0};
      bins error = {1'b1};
    }
    
  endgroup

  function new(string name="alu_subscriber", uvm_component parent=null);
    super.new(name, parent);
    drv_fifo = new("drv_fifo", this);
    mon_fifo = new("mon_fifo", this);
    drv_cg = new;
    mon_cg = new;
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      drv_fifo.get(drv_trans);
      drv_cg.sample();
      mon_fifo.get(mon_trans);
      mon_cg.sample();
    end
  endtask

  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    drv_report = drv_cg.get_coverage();
    mon_report = mon_cg.get_coverage();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Driver Coverage: %0.2f", drv_report), UVM_MEDIUM);
    `uvm_info(get_type_name(), $sformatf("Monitor Coverage: %0.2f", mon_report), UVM_MEDIUM);
  endfunction
endclass
