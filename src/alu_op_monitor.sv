`include "defines.sv"
class alu_op_monitor extends uvm_monitor;

`uvm_component_utils(alu_op_monitor)


uvm_analysis_port #(alu_seq_item)op_m_port;

virtual alu_interface vif;
alu_config m_cfg;
alu_seq_item rd_data;

function new(string name = "alu_op_monitor", uvm_component parent);
	super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
   	if(!uvm_config_db#(alu_config)::get(this,"","alu_config",m_cfg))
		`uvm_fatal(get_type_name(),"Output_Monitor Getting Failed")
		op_m_port=new("op_m_port",this);
		//new
endfunction


function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif = m_cfg.vif;
endfunction

task run_phase(uvm_phase phase);
	repeat(7) @(vif.op_mon_cb);
	 begin
	forever begin		
		collect_data();
	end
	end
endtask

virtual task collect_data();
	rd_data = alu_seq_item::type_id::create("rd_data");
	rd_data.RES = vif.op_mon_cb.RES;
	rd_data.ERR = vif.op_mon_cb.ERR;
	rd_data.COUT = vif.op_mon_cb.COUT;
	rd_data.OFLOW = vif.op_mon_cb.OFLOW;
	rd_data.G = vif.op_mon_cb.G;
	rd_data.L = vif.op_mon_cb.L;
	rd_data.E = vif.op_mon_cb.E;

	op_m_port.write(rd_data);
	`uvm_info("OUTPUT_MONITOR", $sformatf("RES: %d, ERR: %d, COUT: %d, OFLOW: %d, G: %d, L: %d, E: %d", rd_data.RES, rd_data.ERR, rd_data.COUT, rd_data.OFLOW, rd_data.G, rd_data.L, rd_data.E), UVM_NONE)

	@(vif.op_mon_cb);

endtask

endclass



