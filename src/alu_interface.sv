`timescale 1ns/1ns
`include "defines.sv"
interface alu_interface(input bit CLK, RST);
	//IP	
	logic [`DW-1:0] OPA;
	logic [`DW-1:0] OPB;
	logic CE, MODE, CIN;
	logic [`CW-1:0] CMD;
	logic [1:0] INP_VALID;

	//OP
	logic [`DW*2-1:0]RES;
	logic COUT, OFLOW, G, L, E, ERR;
clocking drv_cb@(posedge CLK);
default input #0 output #1;
output OPA, OPB, CIN, CMD, INP_VALID, CE, MODE; 
endclocking

clocking ip_mon_cb@(posedge CLK);
default input #0 output #1;
input OPA, OPB, CIN, CMD, INP_VALID, CE, MODE; 
endclocking

clocking op_mon_cb@(posedge CLK);
default input #0 output #1;
input RES, COUT, OFLOW, G, L, E, ERR;
endclocking

modport DRV(clocking drv_cb);
modport I_MON(clocking ip_mon_cb);
modport O_MON(clocking op_mon_cb);

endinterface

