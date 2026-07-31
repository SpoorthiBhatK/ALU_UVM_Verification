`include "defines.sv"
class alu_test extends uvm_test;
`uvm_component_utils(alu_test)

alu_env env;
alu_config m_cfg;

function new(string name = "alu_test", uvm_component parent);
	super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);

	m_cfg = alu_config::type_id::create("m_cfg");

	 if(!uvm_config_db #(virtual alu_interface)::get(this,"","alu_interface",m_cfg.vif))
		`uvm_fatal(get_type_name,"Can't get the interface")
	m_cfg.alu_inp_agent_is_active = UVM_ACTIVE;
	m_cfg.alu_op_agent_is_active = UVM_PASSIVE;

	uvm_config_db #(alu_config)::set(this, "*", "alu_config", m_cfg);
	
	env = alu_env::type_id::create("env", this);
endfunction

function void end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
	uvm_top.print_topology();
endfunction

endclass

class test1 extends alu_test;
`uvm_component_utils(test1)

alu_sequence s1;

 function new(string name="test1",uvm_component parent);
	super.new(name,parent);
 endfunction


 function void build_phase(uvm_phase phase);
	super.build_phase(phase);
 endfunction


 task run_phase(uvm_phase phase);

	phase.raise_objection(this);
	s1=alu_sequence::type_id::create("s1");
	s1.start(env.inp_agt.sqr);
	phase.drop_objection(this);


 endtask

endclass
 
