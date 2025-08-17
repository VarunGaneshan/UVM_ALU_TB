class alu_sequence_item extends uvm_sequence_item;
  rand bit                     ce, mode, cin;
  rand bit [1:0]               inp_valid;
  rand bit [`CMD_WIDTH-1:0]    cmd;
  rand bit [`OP_WIDTH-1:0]     opa, opb;
  
  `ifdef MUL_OP
    bit [(2*`OP_WIDTH)-1:0] res;
  `else
    bit [`OP_WIDTH:0] res;
  `endif
  
  bit cout, oflow, g, l, e, err;

  `uvm_object_utils_begin(alu_sequence_item)
      `uvm_field_int(ce, UVM_DEFAULT)
      `uvm_field_int(mode, UVM_DEFAULT)
      `uvm_field_int(cin, UVM_DEFAULT)
      `uvm_field_int(inp_valid, UVM_DEFAULT)
      `uvm_field_int(cmd, UVM_DEFAULT)
      `uvm_field_int(opa, UVM_DEFAULT)
      `uvm_field_int(opb, UVM_DEFAULT)
      `uvm_field_int(res, UVM_DEFAULT)
      `uvm_field_int(cout, UVM_DEFAULT)
      `uvm_field_int(oflow, UVM_DEFAULT)
      `uvm_field_int(g, UVM_DEFAULT)
      `uvm_field_int(l, UVM_DEFAULT)
      `uvm_field_int(e, UVM_DEFAULT)
      `uvm_field_int(err, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name="alu_sequence_item");
    super.new(name);
  endfunction

  constraint ce_c {
    ce dist {1 := 98, 0 := 2}; // Clock enable mostly active
  }

  constraint mode_c {
    mode dist {0 := 50, 1 := 50}; // Equal distribution between arithmetic and logical in base test
  }  
  
  constraint cin_c {
    cin dist {0 := 75, 1 := 25}; // Carry in occasionally
  }

  // Constraint for valid commands based on mode
  constraint cmd_mode_c {
    if (mode == 1) {
      cmd inside {`ADD, `SUB, `ADD_CIN, `SUB_CIN, `INC_A, `DEC_A, `INC_B, `DEC_B, `CMP, `INC_MUL, `SHL_MUL};
    } else {
      cmd inside {`AND, `NAND, `OR, `NOR, `XOR, `XNOR, `NOT_A, `NOT_B, `SHR1_A, `SHL1_A, `SHR1_B, `SHL1_B, `ROL, `ROR};
    }
  }
  
  // Input valid constraints based on command
  constraint inp_valid_c { 
     if (mode == 1) {
      if (cmd == `INC_A || cmd == `DEC_A) {
        inp_valid == 2'b01;
      } else if (cmd == `INC_B || cmd == `DEC_B) {
        inp_valid == 2'b10;
      } else {
        inp_valid == 2'b11;
      }
    } else { // mode == 0
      if (cmd == `NOT_A || cmd == `SHL1_A || cmd == `SHR1_A) {
        inp_valid == 2'b01;
      } else if (cmd == `NOT_B || cmd == `SHL1_B || cmd == `SHR1_B) {
        inp_valid == 2'b10;
      } else {
        inp_valid == 2'b11;
      }
    }
  }

endclass

/*
class alu_arith extends alu_transaction;
  constraint cmd_mode_c {
    cmd inside {`ADD, `SUB, `ADD_CIN, `SUB_CIN, `INC_A, `DEC_A, `INC_B, `DEC_B, `CMP, `INC_MUL, `SHL_MUL};
  }

  constraint mode_c {
    mode == 1; 
  }

  constraint inp_valid_c { 
      if (cmd == `INC_A || cmd == `DEC_A) {
        inp_valid == 2'b01;
      } else if (cmd == `INC_B || cmd == `DEC_B) {
        inp_valid == 2'b10;
      } else {
        inp_valid dist {2'b11 := 50, 2'b01 := 25, 2'b10 := 25}; 
      }
    } 

endclass

class alu_logical extends alu_transaction;
  constraint cmd_mode_c {
    cmd inside {`AND, `NAND, `OR, `NOR, `XOR, `XNOR, `NOT_A, `NOT_B, `SHR1_A, `SHL1_A, `SHR1_B, `SHL1_B, `ROL, `ROR};
  }

  constraint mode_c {
    mode == 0; 
  }

  constraint inp_valid_c { 
      if (cmd == `NOT_A || cmd == `SHL1_A || cmd == `SHR1_A) {
        inp_valid == 2'b01;
      } else if (cmd == `NOT_B || cmd == `SHL1_B || cmd == `SHR1_B) {
        inp_valid == 2'b10;
      } else {
        inp_valid dist {2'b11 := 50, 2'b01 := 25, 2'b10 := 25};
      }
    }
endclass

*/