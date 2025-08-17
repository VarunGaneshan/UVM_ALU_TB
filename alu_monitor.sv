class alu_monitor extends uvm_monitor;
  `uvm_component_utils(alu_monitor)

  alu_sequence_item mon_trans;  
  virtual alu_if vif;
  uvm_event drv2mon_ev;

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
    // Retrieve event handle from global event pool
    drv2mon_ev = uvm_event_pool::get_global("drv2mon_ev");
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      monitor_dut();
    end
  endtask

  task monitor_dut();
    $display("[%0t] MONITOR: Starting to monitor transactions", $time);
    drv2mon_ev.wait_trigger(); // Wait for event from driver
    $display("[%0t] MONITOR: Received trigger from driver for transaction", $time);
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
    mon_trans.print();
    mon_port.write(mon_trans);
  endtask
endclass
