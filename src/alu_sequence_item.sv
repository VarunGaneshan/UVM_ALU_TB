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

  constraint values{
    soft 
    opa==1;
    opb==1;
    ce==1;
  }
endclass
