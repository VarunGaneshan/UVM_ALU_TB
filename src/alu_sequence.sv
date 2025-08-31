class alu_base_sequence extends uvm_sequence #(alu_sequence_item);
  `uvm_object_utils(alu_base_sequence)
  alu_sequence_item item; 

  function new(string name="alu_base_sequence");
    super.new(name);
  endfunction

  virtual task body();
    int count;
    repeat(`no_of_trans) begin
      item = alu_sequence_item::type_id::create("item");
      wait_for_grant();
      item.randomize();
      `uvm_info(get_type_name(), $sformatf("[%0t] Transaction %0d: cmd=%0d, mode=%0d, inp_valid=%0b, opa=%0d, opb=%0d, cin=%0b, ce=%0b", $time, count, item.cmd, item.mode, item.inp_valid, item.opa, item.opb, item.cin, item.ce), UVM_LOW);
      send_request(item);
      wait_for_item_done();
      count++;
    end
  endtask

endclass
