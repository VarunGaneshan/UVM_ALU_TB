`timescale 1ns/1ns
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "defines.sv"
`include "alu_if.sv"
`include "alu_design.sv"
  `include "alu_sequence_item.sv"
  `include "alu_sequence.sv"
  `include "alu_sequencer.sv"
  `include "alu_driver.sv"
  `include "alu_monitor.sv"
  `include "alu_agent.sv"
  `include "alu_scoreboard.sv"
  `include "alu_subscriber.sv"
  `include "alu_environment.sv"
  `include "alu_test.sv"
  `include "alu_bind.sv"
  `include "alu_assertions.sv"
module top;
  bit clk;
  bit rst;

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst = 0;
   //#delay rst=1;
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
    run_test("alu_base_test");
    repeat(10) @(posedge clk);
    $finish;
  end
  
endmodule

