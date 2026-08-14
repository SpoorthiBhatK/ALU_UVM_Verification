`include "defines.sv"
class alu_subscriber extends uvm_subscriber #(alu_seq_item);

`uvm_component_utils(alu_subscriber)

alu_seq_item drv;

covergroup inp_cg;
OPA_cp: coverpoint drv.OPA
{
bins zero = {8'h00};
bins max  = {8'hFF};
bins low  = {[8'h01:8'h7F]};
bins high = {[8'h80:8'hFE]};
}
OPB_cp: coverpoint drv.OPB
{
bins zero = {8'h00};
bins max  = {8'hFF};
bins low  = {[8'h01:8'h7F]};
bins high = {[8'h80:8'hFE]};
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
}
MODE_CMD: cross MODE_cp, CMD_cp
{
ignore_bins art_in = binsof(MODE_cp) intersect {1} && binsof(CMD_cp)intersect {[11:13]};
}
CMD_INP_VALID: cross CMD_cp, INP_VALID_cp;
MODE_INP_VALID: cross MODE_cp, INP_VALID_cp;
endgroup

function new(string name, uvm_component parent);
	super.new(name, parent);
	inp_cg = new();
endfunction

virtual function void write(alu_seq_item t);     // write() - receives transactions from the DRIVER
	drv = t;
   	inp_cg.sample();
    	`uvm_info(get_name(),"[DRIVER]:INPUT RECIEVED",UVM_HIGH)
endfunction
 
function void report_phase(uvm_phase phase);
	super.report_phase(phase);
    	`uvm_info(get_name(),$sformatf("INPUT COVERAGE = %0f\n",inp_cg.get_coverage()),UVM_NONE);
endfunction
 
endclass
