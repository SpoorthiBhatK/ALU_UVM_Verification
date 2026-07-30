`include "defines.sv"

class alu_scoreboard extends uvm_scoreboard;

`uvm_component_utils(alu_scoreboard)

//bit [4:0]cnt;

uvm_tlm_analysis_fifo #(alu_seq_item) ip_mon_fifo;
uvm_tlm_analysis_fifo #(alu_seq_item) op_mon_fifo;

alu_seq_item ip_mon;
alu_seq_item op_mon;

//virtual alu_interface intf;
alu_config cfg;

function new(string name = "alu_scoreboard", uvm_component parent);
	super.new(name, parent);
	ip_mon_fifo = new("ip_mon_fifo", this);
	op_mon_fifo = new("op_mon_fifo", this);
endfunction

function void build_phase(uvm_phase phase);
    	super.build_phase(phase);

    	if(!uvm_config_db#(alu_config)::get(this, "", "alu_config", cfg))
        	`uvm_fatal(get_type_name(), "Failed to get config")
endfunction

task run_phase(uvm_phase phase);
	
	forever begin
		ip_mon = alu_seq_item::type_id::create("ip_mon");
		op_mon = alu_seq_item::type_id::create("op_mon");
		
		ip_mon_fifo.get(ip_mon);
		op_mon_fifo.get(op_mon);
		ref_model(ip_mon);
		`uvm_info("REFERENCE_MODEL", $sformatf("Reference model\n%s", ip_mon.sprint()), UVM_NONE)
		check_data(op_mon);
		`uvm_info("CHECKING OUTPUTS", $sformatf(" Checking outputs\n%s", op_mon.sprint()), UVM_NONE)
	end
endtask

task check_data(alu_seq_item cd);
	if(ip_mon.RES == cd.RES)
		$display("RES MATCH\n");
	else
		$display("RES MISMATCH\n");
 
	if(ip_mon.ERR == cd.ERR)
		$display("ERR MATCH\n");
	else
		$display("ERR MISMATCH\n");	

	if(ip_mon.COUT == cd.COUT)
		$display("COUT MATCH\n");
	else
		$display("COUT MISMATCH\n");
	if(ip_mon.OFLOW == cd.OFLOW)
		$display("OFLOW MATCH\n");
	else
		$display("OFLOW MISMATCH\n");
	if(ip_mon.G == cd.G)
		$display("G MATCH\n");
	else
		$display("G MISMATCH\n");
	if(ip_mon.L == cd.L)
		$display("L MATCH\n");
	else
		$display("L MISMATCH\n");
	if(ip_mon.E == cd.E)
		$display("E MATCH\n");
	else
		$display("E MISMATCH\n");
endtask

task ref_model(alu_seq_item t);
	bit [`DW-1:0] opa1, opa2;
	bit [`DW-1:0] opb1, opb2;
	bit [`CW-1:0] cmd;
	bit [`DW-1:0] res1, res2;
	
	if(cfg.vif.RST)begin
		opa1 = 0;
		opb1 = 0;
		cmd = 0;
	end
	else if(t.INP_VALID == 2'b01)begin
		opa1 = t.OPA;
		cmd = t.CMD;
	end
	else if(t.INP_VALID == 2'b10)begin
		opb1 = t.OPB;
		cmd = t.CMD;
	end
	else if(t.INP_VALID == 2'b11)begin
		opa1 = t.OPA;
		opb1 = t.OPB;
		cmd = t.CMD;
	end
	else begin
		opa1 = 0;
		opb1 = 0;
		cmd = 0;	
	end
	
	if(t.CE)begin
		if(cfg.vif.RST)begin
			t.RES = 'z;
			t.COUT = 1'bz;
			t.OFLOW = 1'bz;
			t.G = 1'bz;
			t.E = 1'bz;
			t.L = 1'bz;
			t.ERR = 1'bz;
		end
		else if(t.MODE)begin
			t.RES = 'z;
			t.COUT = 1'bz;
			t.OFLOW = 1'bz;
			t.G = 1'bz;
			t.E = 1'bz;
			t.L = 1'bz;
			t.ERR = 1'bz;
			case(t.CMD)
			4'b0000:begin
				t.RES = opa1 + opb1;
				t.COUT = t.RES[8]?1:0;
				end
			4'b0001:begin
				t.RES = opa1 - opb1;
				t.OFLOW = (opa1 < opb1)?1:0;
				end
			4'b0010:begin
				t.RES = opa1 + opb1 + t.CIN;
				t.COUT = t.RES[8]?1:0;
				end
			4'b0011:begin
				t.RES = opa1 - opb1 - t.CIN;
				t.OFLOW = (opa1 < opb1)?1:0;
				end
			4'b0100:t.RES = opa1 + 1;
			4'b0101:t.RES = opa1 - 1;
			4'b0110:t.RES = opb1 + 1;
			4'b0111:t.RES = opb1 - 1;
			4'b1000:{t.G, t.E, t.L} = (opa1 > opb1)?3'b1zz:(opa1 == opb1)? 3'bz1z: 3'bzz1;
			4'b1001:begin//check temp2
				res1 = opa1 + 1;
				res2 = opb1 + 1;
				t.RES = res1 * res2;
				end
			4'b1010:begin
				res1 = opa1 << 1;
				res2 = opb1;
				t.RES = res1 * res2;
				end
			default:begin
				t.RES = 'z;
				t.COUT = 1'bz;
				t.OFLOW = 1'bz;
				t.G = 1'bz;
				t.E = 1'bz;
				t.L = 1'bz;
				t.ERR = 1'bz;
				end
			endcase
		end
		else begin
			t.RES = 'z;
			t.COUT = 1'bz;
			t.OFLOW = 1'bz;
			t.G = 1'bz;
			t.E = 1'bz;
			t.L = 1'bz;
			t.ERR = 1'bz;
			case(t.CMD)
			4'b0000: t.RES = {1'b0, (opa1 & opb1)};
			4'b0001: t.RES = {1'b0, ~(opa1 & opb1)};
			4'b0010: t.RES = {1'b0, (opa1 | opb1)};
			4'b0011: t.RES = {1'b0, ~(opa1 | opb1)};
			4'b0100: t.RES = {1'b0, (opa1 ^ opb1)};
			4'b0101: t.RES = {1'b0, ~(opa1 ^ opb1)};
			4'b0110: t.RES = {1'b0, ~opa1};
			4'b0111: t.RES = {1'b0, ~opb1};
			4'b1000: t.RES = {1'b0, opa1 >> 1};
			4'b1001: t.RES = {1'b0, opb1 << 1};
			4'b1010: t.RES = {1'b0, opa1 >> 1};
			4'b1011: t.RES = {1'b0, opb1 << 1};
			4'b1100:begin
				t.RES = {opa1 << opb1[$clog2(`DW)-1:0]};
				t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
				end
			4'b1101:begin
				t.RES = {opa1 >> opb1[$clog2(`DW)-1:0]};
				t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
				end
			default:begin
				t.RES = 'z;
				t.COUT = 1'bz;
				t.OFLOW = 1'bz;
				t.G = 1'bz;
				t.E = 1'bz;
				t.L = 1'bz;
				t.ERR = 1'bz;
				end
			endcase
		end

	end
endtask
endclass


