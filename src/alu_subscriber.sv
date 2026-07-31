`include "defines.sv"
class alu_subscriber extends uvm_subscriber;

`uvm_component_utils(alu_subscriber)

alu_seq_item drv;
alu_Seq_item mon;
covergroup inp_cg;
OPA_cp: coverpoint drv.OPA
{
option.auto_bin_max = 3;
}
OPB_cp: coverpoint drv.OPB
{
option.auto_bin_max = 3;
}
CIN_cp:coverpoint drv.CIN
{
bins md_low = {0};
bins md_high = {1};
}
CMD_cp: coverpoint drv.CMD
{
bins cd[] = {[0:13]};
}
INP_VALID_cp: coverpoint drv.INP_VALID
{
bins in_val[] = {[0:3]};
}
CE_cp: coverpoint drv.CE
{
bins ce_low = {0};
bins ce_high = {1};
}
MODE_cp: coverpoint drv.MODE
{
bins md_low = {0};
bins md_high = {1};
}; 
endgroup
function new(string name, uvm_component parent);
	super.new(name, parent);
	inp_cg = new();
endfunction

virtual function void write(apb_sequence_item t);     // write() - receives transactions from the DRIVER
	drv = t;
   	input_cg.sample();
    	`uvm_info(get_name,"[DRIVER]:INPUT RECIEVED",UVM_HIGH)
endfunction
 
 
function void report_phase(uvm_phase phase);
	super.report_phase(phase);
    	`uvm_info(get_name,$sformatf("INPUT COVERAGE = %0f\n",inp_cg.get_coverage(),UVM_NONE);
endfunction
 
endclass
