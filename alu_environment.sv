class alu_env extends uvm_env;
  `uvm_component_utils(alu_env)
  alu_agent agent;
  alu_scoreboard scoreboard;
  alu_subscriber subscriber;

  function new(string name="alu_env",uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = alu_agent::type_id::create("agent", this);
    scoreboard = alu_scoreboard::type_id::create("scoreboard", this);
    subscriber = alu_subscriber::type_id::create("subscriber", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.monitor.mon_port.connect(scoreboard.sb_fifo.analysis_export);
    agent.driver.drv_port.connect(subscriber.drv_fifo.analysis_export);
    agent.monitor.mon_port.connect(subscriber.mon_fifo.analysis_export);
  endfunction

endclass
