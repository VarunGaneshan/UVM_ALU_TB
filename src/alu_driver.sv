class alu_driver extends uvm_driver #(alu_sequence_item);
  `uvm_component_utils(alu_driver)
  alu_sequence_item drv_trans;
  virtual alu_if vif;

  uvm_analysis_port #(alu_sequence_item) drv_port;


  function new(string name="alu_driver",uvm_component parent=null);
    super.new(name,parent);
    drv_port = new("drv_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_if)::get(this,"","vif",vif)) begin
      `uvm_fatal("NOVIF","No virtual interface found")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      seq_item_port.get_next_item(drv_trans);
      drive();
      seq_item_port.item_done();
    end
  endtask

  // Function to check if command is two operand
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

  task drive_dut();
    vif.drv_cb.ce <= drv_trans.ce;
    vif.drv_cb.inp_valid <= drv_trans.inp_valid;
    vif.drv_cb.mode <= drv_trans.mode;
    vif.drv_cb.cmd <= drv_trans.cmd;
    vif.drv_cb.cin <= drv_trans.cin;
    vif.drv_cb.opa <= drv_trans.opa;
    vif.drv_cb.opb <= drv_trans.opb;
  endtask

  task drive();
    int retry_count,delay_cycles;
    bit valid_match; 
        // Enable randomization for cmd and mode initially
        drv_trans.rand_mode(1);
        if(is_two_op(drv_trans.cmd, drv_trans.mode)) begin
            `uvm_info(get_type_name(), $sformatf("[%0t] Transaction - Two operand operation detected", $time), UVM_LOW);
            if(drv_trans.inp_valid == 2'b11) begin
                `uvm_info(get_type_name(), $sformatf("[%0t] Correct inp_valid found on transaction", $time), UVM_LOW);
                drive_dut();
            end else begin
                valid_match = 0;
                for(retry_count = 0; retry_count < 16; retry_count++) begin
                    if(drv_trans.inp_valid == 2'b11) begin
                        `uvm_info(get_type_name(), $sformatf("[%0t] Correct inp_valid found on retry %0d", $time, retry_count), UVM_LOW);
                        `uvm_info(get_type_name(), $sformatf("[%0t] New values - cmd=%0d, mode=%0d, inp_valid=%0b, opa=%0d, opb=%0d, cin=%0b, ce=%0b", $time, drv_trans.cmd, drv_trans.mode, drv_trans.inp_valid, drv_trans.opa, drv_trans.opb, drv_trans.cin, drv_trans.ce), UVM_LOW);
                        drive_dut();
                        valid_match = 1;
                        break;
                    end else begin
                        `uvm_info(get_type_name(), $sformatf("[%0t] Incorrect inp_valid=%b, driving DUT", $time, drv_trans.inp_valid), UVM_LOW);
                        drive_dut();
                        // Wait one cycle before next retry
                        repeat(1) @(vif.drv_cb);
                    end
                    // Disable randomization for cmd and mode after first iteration
                    drv_trans.cmd.rand_mode(0);
                    drv_trans.mode.rand_mode(0);  
                    // Re-randomize only inp_valid, opa, opb, cin, ce
                    if(!drv_trans.randomize()) begin
                        `uvm_info(get_type_name(), $sformatf("[%0t] Randomization failed for retry %0d", $time, retry_count), UVM_LOW);
                    end
                  
                end
                // If all 16 retries failed, move to next transaction
                if(!valid_match) begin
                      `uvm_info(get_type_name(), $sformatf("[%0t] All 16 retries failed for transaction, moving to next", $time), UVM_LOW);
                end
            end
            
        end else begin
            // Single operand operation - drive normally
            `uvm_info(get_type_name(), $sformatf("[%0t] Transaction - Single operand operation", $time), UVM_LOW);
            drive_dut();
        end
    drv_port.write(drv_trans);
    delay_cycles = get_delay_cycles(drv_trans.cmd, drv_trans.mode);
    repeat(delay_cycles+1) @(vif.drv_cb);
  endtask
endclass
