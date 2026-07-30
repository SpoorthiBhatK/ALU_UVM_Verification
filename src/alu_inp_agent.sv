`include "defines.sv"

class alu_inp_agent extends uvm_agent;

`uvm_component_utils(alu_inp_agent)

alu_driver inp_drv;
alu_inp_monitor inp_mon;
alu_sequencer sqr;
alu_config m_cfg;

function new(string name = "alu_inp_agent", uvm_component parent);
	super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(alu_config)::get(this, "", "alu_config", m_cfg))
		`uvm_fatal(get_type_name(), "input_agent Getting Failed")
	inp_mon = alu_inp_monitor::type_id::create("inp_mon", this);
	if(m_cfg.alu_inp_agent_is_active == UVM_ACTIVE)
	begin
		sqr = alu_sequencer::type_id::create("sqr", this);
		inp_drv = alu_driver::type_id::create("inp_drv", this);
	end
endfunction

function void connect_phase(uvm_phase phase);
	if(m_cfg.alu_inp_agent_is_active == UVM_ACTIVE)
	begin
		inp_drv.seq_item_port.connect(sqr.seq_item_export);
	end
endfunction

endclass
	


