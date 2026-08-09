`include "defines.sv"

class alu_config extends uvm_object;
`uvm_object_utils(alu_config)

virtual alu_interface vif;

uvm_active_passive_enum alu_inp_agent_is_active;
uvm_active_passive_enum alu_op_agent_is_active;

function new(string name = "alu_config");
	super.new(name);
endfunction
endclass

