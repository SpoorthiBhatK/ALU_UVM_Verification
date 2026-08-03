`include "defines.sv"
class alu_env extends uvm_env;

`uvm_component_utils(alu_env)

alu_inp_agent inp_agt;
alu_op_agent op_agt;
alu_scoreboard scb;
alu_subscriber sub;
alu_config m_cfg;

function new(string name = "env", uvm_component parent);
	super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(alu_config)::get(this,"","alu_config",m_cfg))
		`uvm_fatal(get_type_name(),"Output_agt Getting Failed")	
	inp_agt = alu_inp_agent::type_id::create("inp_agt", this);
	op_agt = alu_op_agent::type_id::create("op_agt", this);
	scb = alu_scoreboard::type_id::create("scb", this);
	sub = alu_subscriber::type_id::create("sub", this);
endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	inp_agt.inp_mon.inp_m_port.connect(scb.ip_mon_fifo.analysis_export);
	inp_agt.inp_mon.inp_m_port.connect(sub.analysis_export);
	op_agt.op_mon.op_m_port.connect(scb.op_mon_fifo.analysis_export);
endfunction
endclass
