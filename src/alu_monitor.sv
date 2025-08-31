class alu_monitor extends uvm_monitor;
  `uvm_component_utils(alu_monitor)

  alu_sequence_item mon_trans;  
  virtual alu_if vif;

  uvm_analysis_port #(alu_sequence_item) mon_port;

  function new(string name="alu_monitor", uvm_component parent=null);
    super.new(name, parent);
    mon_trans = new;
    mon_port = new("mon_port", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "No virtual interface found");
    end
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      monitor_dut();
    end
  endtask

  function int get_delay_cycles;
    input [`CMD_WIDTH-1:0] cmd;
    input mode;
    begin
      if (mode && (cmd == `INC_MUL || cmd == `SHL_MUL))
        get_delay_cycles = 4;
      else
        get_delay_cycles = 3;
    end
  endfunction

  function bit is_two_op;
    input [`CMD_WIDTH-1:0] c;
    input m;
    begin
      if (m == 1)
        is_two_op = (c == `ADD || c == `SUB || c == `ADD_CIN || c == `SUB_CIN || c == `CMP || c == `INC_MUL || c == `SHL_MUL);
      else
        is_two_op = (c == `AND || c == `NAND || c == `OR || c == `NOR || c == `XOR || c == `XNOR || c == `ROL || c == `ROR);
    end
  endfunction

  task monitor_dut();
    int delay_cycles;
    // Wait for clock edge and sample inputs
    @(vif.mon_cb);
    delay_cycles = get_delay_cycles(vif.mon_cb.cmd,vif.mon_cb.mode);
    `uvm_info(get_type_name(), $sformatf("[%0t] waiting %0d cycles for output",$time, delay_cycles), UVM_LOW);
    repeat(delay_cycles) @(vif.mon_cb);

        mon_trans.ce = vif.mon_cb.ce;
        mon_trans.inp_valid = vif.mon_cb.inp_valid;
        mon_trans.mode = vif.mon_cb.mode;
        mon_trans.cmd = vif.mon_cb.cmd;
        mon_trans.cin = vif.mon_cb.cin;
        mon_trans.opa = vif.mon_cb.opa;
        mon_trans.opb = vif.mon_cb.opb;
        mon_trans.res = vif.mon_cb.res;
        mon_trans.cout = vif.mon_cb.cout;
        mon_trans.oflow = vif.mon_cb.oflow;
        mon_trans.g = vif.mon_cb.g;
        mon_trans.l = vif.mon_cb.l;
        mon_trans.e = vif.mon_cb.e;
        mon_trans.err = vif.mon_cb.err;

    `uvm_info(get_type_name(), $sformatf("[%0t] Transaction captured after %0d cycles", $time, delay_cycles), UVM_LOW);
    mon_trans.print();
    mon_port.write(mon_trans);
  endtask
endclass
