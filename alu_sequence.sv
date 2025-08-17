class alu_base_sequence extends uvm_sequence #(alu_sequence_item);
  `uvm_object_utils(alu_base_sequence)
  alu_sequence_item item; 

  function new(string name="alu_base_sequence");
    super.new(name);
  endfunction

  virtual task body();
    repeat(2000) begin
      item = alu_sequence_item::type_id::create("item");
      wait_for_grant();
      item.randomize();
      item.print();
      send_request(item);
      wait_for_item_done();
    end
  endtask

endclass