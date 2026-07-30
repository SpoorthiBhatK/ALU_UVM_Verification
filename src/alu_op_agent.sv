`include "defines.sv"
class alu_op_agent extends uvm_agent;

`uvm_component_utils(alu_op_agent)

alu_op_monitor op_mon;
alu_config o_m_cfg;

function new(string name = "alu_op_agent", uvm_component parent);
	super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(alu_config)::get(this, "", "alu_config", o_m_cfg))
	        `uvm_fatal(get_type_name(), "Failed to get alu_config")

	if(o_m_cfg.alu_op_agent_is_active == UVM_PASSIVE)
	begin
		op_mon = alu_op_monitor::type_id::create("op_mon", this);
	end
endfunction

endclass  
