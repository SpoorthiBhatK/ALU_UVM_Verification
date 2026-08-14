`timescale 1ns/1ns
`include "defines.sv"
`include "alu_package.sv"

interface alu_interface(input bit CLK, RST);
    import uvm_pkg::*;
	logic [`DW-1:0] OPA;
	logic [`DW-1:0] OPB;
	logic CE, MODE, CIN;
	logic [`CW-1:0] CMD;
	logic [1:0] INP_VALID;

	logic [`DW*2-1:0]RES;
	logic COUT, OFLOW, G, L, E, ERR;
clocking drv_cb@(posedge CLK);
default input #0 output #1;
output OPA, OPB, CIN, CMD, INP_VALID, CE, MODE; 
endclocking

clocking ip_mon_cb@(posedge CLK);
default input #1 output #0;
input OPA, OPB, CIN, CMD, INP_VALID, CE, MODE; 
endclocking

clocking op_mon_cb@(posedge CLK);
default input #1 output #0;
input RES, COUT, OFLOW, G, L, E, ERR;
endclocking

modport DRV(clocking drv_cb);
modport I_MON(clocking ip_mon_cb);
modport O_MON(clocking op_mon_cb);
/*
property ce_disable;
@(posedge CLK)
!CE |=> $stable(RES) && $stable(COUT) && $stable(OFLOW) && $stable(G) && $stable(E) && $stable(L) && $stable(ERR);
endproperty
assert property(ce_disable)else `uvm_info("CE", $sformatf("Assertion failed"), UVM_NONE);


property reset_outputs;
@(posedge CLK)
!RST |=> (RES == 0) && (COUT == 0) && (OFLOW == 0) && (G == 0) && (E == 0) && (L == 0) && (ERR == 0);
endproperty
assert property(reset_outputs)else `uvm_info("RESET", $sformatf("Assertion failed"), UVM_NONE);


property valid_inputs;
@(posedge CLK)
(CE && INP_VALID == 2'b11) |=> !ERR;
endproperty
assert property(valid_inputs)else `uvm_info("VALID_INPUT", $sformatf("Assertion failed"), UVM_NONE);
*/

endinterface

