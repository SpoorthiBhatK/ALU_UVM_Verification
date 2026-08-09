`include "defines.sv"

class alu_driver extends uvm_driver #(alu_seq_item);
`uvm_component_utils(alu_driver)

virtual alu_interface vif_drv;
alu_config cfg;

function new(string name, uvm_component parent);
	super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(alu_config)::get(this, "", "alu_config", cfg))
		`uvm_fatal(get_type_name(), "Input_Driver config db get failed")
endfunction

function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	vif_drv = cfg.vif;
endfunction


task run_phase(uvm_phase phase);
	begin
	repeat(3)@(vif_drv.drv_cb);
	forever
		begin
			seq_item_port.get_next_item(req);
			drive(req);
			seq_item_port.item_done();	
		end
	end
endtask
task drive(alu_seq_item data2duv);
	begin
//		repeat(4)
		@(vif_drv.drv_cb);
		vif_drv.drv_cb.OPA <= data2duv.OPA;
		vif_drv.drv_cb.OPB <= data2duv.OPB;
		vif_drv.drv_cb.CIN <= data2duv.CIN;
		vif_drv.drv_cb.CE <= data2duv.CE;
		vif_drv.drv_cb.MODE <= data2duv.MODE;
		vif_drv.drv_cb.INP_VALID <= data2duv.INP_VALID;
		vif_drv.drv_cb.CMD <= data2duv.CMD;
		
		`uvm_info("INPUT_DRIVER", $sformatf("INP_VALID: %d, OPA: %d,	OPB: %d, CIN: %d, CE: %d, MODE: %d, CMD: %d", data2duv.INP_VALID, data2duv.OPA, data2duv.OPB, data2duv.CIN, data2duv.CE, data2duv.MODE, data2duv.CMD), UVM_NONE)
//@(vif_drv.drv_cb);
	end
endtask
endclass		
		






