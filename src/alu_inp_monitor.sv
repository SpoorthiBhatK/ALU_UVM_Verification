`include "defines.sv"

class alu_inp_monitor extends uvm_monitor;
`uvm_component_utils(alu_inp_monitor)

uvm_analysis_port #(alu_seq_item)inp_m_port;

virtual alu_interface ip_m_vif;
alu_config m_cfg;
alu_seq_item drv2mon;

function new(string name = "alu_inp_monitor", uvm_component parent);
	super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
   	if(!uvm_config_db#(alu_config)::get(this,"","alu_config",m_cfg))
		`uvm_fatal(get_type_name(),"Input_Monitor Getting Failed")
	inp_m_port=new("inp_monitor_port",this);
	//new
endfunction


function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	ip_m_vif = m_cfg.vif;
endfunction 


task run_phase(uvm_phase phase);

	forever begin
		drv2mon = alu_seq_item::type_id::create("drv2mon");
		collect_ip_monitor();
		//`uvm_info("INPUT MONITOR", $sformatf("Input Monitor\n%s", drv2mon.sprint()), UVM_NONE)
	end
endtask
virtual task collect_ip_monitor();
	begin
		//repeat(6)
		@(ip_m_vif.ip_mon_cb);
		begin
		
		drv2mon.CE = ip_m_vif.ip_mon_cb.CE;
		drv2mon.OPA = ip_m_vif.ip_mon_cb.OPA;
		drv2mon.OPB = ip_m_vif.ip_mon_cb.OPB;
		drv2mon.MODE = ip_m_vif.ip_mon_cb.MODE;
		drv2mon.CMD = ip_m_vif.ip_mon_cb.CMD;
		drv2mon.INP_VALID = ip_m_vif.ip_mon_cb.INP_VALID;

		if((drv2mon.MODE == 1) && ((drv2mon.CMD == 4'b0010) || (drv2mon.CMD == 4'b0011)))
		begin
			drv2mon.CIN = ip_m_vif.ip_mon_cb.CIN;
		end
		inp_m_port.write(drv2mon);
		end
		`uvm_info("INPUT_MONITOR", $sformatf("INP_VALID: %d, OPA: %d,	OPB: %d, CIN: %d, CE: %d, MODE: %d, CMD: %d", drv2mon.INP_VALID, drv2mon.OPA, drv2mon.OPB, drv2mon.CIN, drv2mon.CE, drv2mon.MODE, drv2mon.CMD), UVM_NONE)
	end
endtask

endclass
