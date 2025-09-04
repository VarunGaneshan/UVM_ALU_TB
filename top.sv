`timescale 1ns/1ns
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "src/defines.sv"
`include "src/alu_if.sv"
`include "src/alu_design.sv"
  `include "src/alu_sequence_item.sv"
  `include "src/alu_sequence.sv"
  `include "src/alu_sequencer.sv"
  `include "src/alu_driver.sv"
  `include "src/alu_monitor.sv"
  `include "src/alu_agent.sv"
  `include "src/alu_scoreboard.sv"
  `include "src/alu_subscriber.sv"
  `include "src/alu_environment.sv"
  `include "src/alu_test.sv"
  `include "src/alu_bind.sv"
  `include "src/alu_assertions.sv"
module top;
  bit clk;
  bit rst;

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst = 0;
  end

  alu_if alu_intf(clk, rst);

  alu_design DUT(
    .CLK(clk),
    .RST(rst),
    .CE(alu_intf.ce),
    .INP_VALID(alu_intf.inp_valid),
    .MODE(alu_intf.mode),
    .CMD(alu_intf.cmd),
    .CIN(alu_intf.cin),
    .OPA(alu_intf.opa),
    .OPB(alu_intf.opb),
    .RES(alu_intf.res),
    .COUT(alu_intf.cout),
    .OFLOW(alu_intf.oflow),
    .G(alu_intf.g),
    .L(alu_intf.l),
    .E(alu_intf.e),
    .ERR(alu_intf.err)
  );

  initial begin
    uvm_config_db #(virtual alu_if)::set(null, "*", "vif", alu_intf);
  end

  initial begin
    run_test("alu_reg_test");
    repeat(10) @(posedge clk);
    $stop;
  end
  
endmodule


