`include "defines.sv"
`include "alu_interface.sv"
`include "alu.sv"
`include "alu_package.sv"

module alu_top();

import uvm_pkg::*;
import alu_package::*;

bit CLK, RST;
alu_interface duv_inf(CLK, RST);

alu #(.DW(`DW), .CW(`CW))duv(
	.CLK(duv_inf.CLK),
	.RST(duv_inf.RST),
	.CE(duv_inf.CE),
	.INP_VALID(duv_inf.INP_VALID),
	.OPA(duv_inf.OPA),
	.OPB(duv_inf.OPB),
	.CIN(duv_inf.CIN),
	.MODE(duv_inf.MODE),
	.CMD(duv_inf.CMD),

	.RES(duv_inf.RES),
	.COUT(duv_inf.COUT),
	.OFLOW(duv_inf.OFLOW),
	.G(duv_inf.G),
	.L(duv_inf.L),
	.E(duv_inf.E),
	.ERR(duv_inf.ERR));
initial begin
	CLK = 1'b0;
	forever #5 CLK = ~CLK;
end

initial begin
	RST = 1;
    	#20;
	RST = 0;
end

initial begin
	uvm_config_db #(virtual alu_interface)::set(null, "*", "alu_interface", duv_inf);
	$dumpfile("waves.vcd");
	$dumpvars;
	
	run_test();
end

endmodule
