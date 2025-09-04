class alu_reg_test extends uvm_test;
 `uvm_component_utils(alu_reg_test);
 alu_env env;
 virtual_sequence v_seq;

 function new(string name="alu_reg_test", uvm_component parent=null);
   super.new(name, parent);
 endfunction

 virtual function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   env = alu_env::type_id::create("env", this);
 endfunction

 virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
 endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    v_seq = virtual_sequence::type_id::create("v_seq");
    v_seq.v_seqr = env.agent.sequencer;
    v_seq.start(null);
    phase.drop_objection(this);
  endtask

endclass
