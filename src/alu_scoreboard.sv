`include "defines.sv"

class alu_scoreboard extends uvm_scoreboard;

`uvm_component_utils(alu_scoreboard)

uvm_tlm_analysis_fifo #(alu_seq_item) ip_mon_fifo;
uvm_tlm_analysis_fifo #(alu_seq_item) op_mon_fifo;

alu_seq_item ip_mon;
alu_seq_item op_mon;

//virtual alu_interface intf;
alu_config cfg;

bit [`DW-1:0] opa1, opa2;
bit [`DW-1:0] opb1, opb2;
bit [`CW-1:0] cmd;
bit [`DW*2-1:0] res1, res2;

bit [4:0]cnt;
bit va, vb, mode;

bit [1:0]m_cnt;

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
		//`uvm_info("REFERENCE_MODEL", $sformatf("Reference model\n%s", ip_mon.sprint()), UVM_NONE)
		check_data(op_mon);
		//`uvm_info("CHECKING OUTPUTS", $sformatf(" Checking outputs\n%s", op_mon.sprint()), UVM_NONE)
	end
endtask

task check_data(alu_seq_item cd);
	`uvm_info("Scoreboard",  $sformatf("\nExp RES: %d, actual RES: %d\nExp ERR: %d, actual ERR: %d\nExp COUT: %d, actual COUT: %d\nExp OFLOW: %d, actual OFLOW: %d\nExp G: %d, actual G: %d\nExp L: %d, actual L: %d\nExp E: %d, actual E: %d\n", ip_mon.RES, cd.RES, ip_mon.ERR, cd.ERR, ip_mon.COUT, cd.COUT, ip_mon.OFLOW, cd.OFLOW, ip_mon.G, cd.G, ip_mon.L, cd.L, ip_mon.E, cd.E), UVM_NONE)
	
	if(ip_mon.RES == cd.RES)begin
		$display("RES MATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp RES: %d, actual RES: %d", ip_mon.RES, cd.RES), UVM_NONE)
	end
	else begin
		$display("RES MISMATCH\n");
 		//`uvm_info("Scoreboard",  $sformatf("Exp RES: %d, actual RES: %d", ip_mon.RES, cd.RES), UVM_NONE)
	end
	if(ip_mon.ERR == cd.ERR)begin
		$display("ERR MATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp ERR: %d, actual ERR: %d", ip_mon.ERR, cd.ERR), UVM_NONE)
	end
	else begin
		$display("ERR MISMATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp ERR: %d, actual ERR: %d", ip_mon.ERR, cd.ERR), UVM_NONE)
	end
	if(ip_mon.COUT == cd.COUT)begin
		$display("COUT MATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp COUT: %d, actual COUT: %d", ip_mon.COUT, cd.COUT), UVM_NONE)
	end
	else begin
		$display("COUT MISMATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp COUT: %d, actual COUT: %d", ip_mon.COUT, cd.COUT), UVM_NONE)
	end
	if(ip_mon.OFLOW == cd.OFLOW)begin
		$display("OFLOW MATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp OFLOW: %d, actual OFLOW: %d", ip_mon.OFLOW, cd.OFLOW), UVM_NONE)
	end
	else begin
		$display("OFLOW MISMATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp OFLOW: %d, actual OFLOW: %d", ip_mon.OFLOW, cd.OFLOW), UVM_NONE)
	end
	if(ip_mon.G == cd.G)begin
		$display("G MATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp G: %d, actual G: %d", ip_mon.G, cd.G), UVM_NONE)
	end
	else begin
		$display("G MISMATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp G: %d, actual G: %d", ip_mon.G, cd.G), UVM_NONE)
	end
	if(ip_mon.L == cd.L)begin
		$display("L MATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp L: %d, actual L: %d", ip_mon.L, cd.L), UVM_NONE)
	end
	else begin
		$display("L MISMATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp L: %d, actual L: %d", ip_mon.L, cd.L), UVM_NONE)
	end
	if(ip_mon.E == cd.E)begin
		$display("E MATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp E: %d, actual E: %d", ip_mon.E, cd.E), UVM_NONE)
	end
	else begin
		$display("E MISMATCH\n");
		//`uvm_info("Scoreboard",  $sformatf("Exp E: %d, actual E: %d", ip_mon.E, cd.E), UVM_NONE)
	end
endtask
	
task reset();
	opa1 = '0;
	opb1 = '0;
	va = 0;
	vb = 0;
	cnt = 0;
	m_cnt = 0;
endtask
task store_a(alu_seq_item t);
	opa1 = t.OPA;
	va = 1;
endtask
task store_b(alu_seq_item t);
	opb1 = t.OPB;
	vb = 1;
endtask
task store_ab(alu_seq_item t);
	opa1 = t.OPA;
	opb1 = t.OPB;
	vb = 1;
	va = 1;
	cnt = 0;
	m_cnt = 0;
endtask
task mode_cmd_change(alu_seq_item t);
	if((mode != t.MODE) || (cmd != t.CMD))
		reset();
mode = t.MODE;
cmd = t.CMD;
endtask
task wait_cnt(alu_seq_item t);
	if(va ^ vb)begin
		cnt = cnt + 1;
		if(cnt == 16)begin
			t.ERR = 1;
			reset();
		end
	end
	else
		cnt = 0;
endtask


task ref_model(alu_seq_item t);
	if(cfg.vif.RST)begin
		reset();
	end
	else begin
	if(t.CE == 0)begin
		return;
	end
	else begin
	if(t.MODE == 1)begin
		if(t.MODE == 1)begin
			mode_cmd_change(t);
			case(t.CMD)
			4'b0000:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = opa1 + opb1;
						t.COUT = t.RES[`DW]?1:0;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = opa1 + opb1;
						t.COUT = t.RES[`DW]?1:0;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = opa1 + opb1;
					t.COUT = t.RES[`DW]?1:0;
					reset();
				      end
				endcase
				end
			4'b0001:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = opa1 - opb1;
						t.OFLOW = (opa1 < opb1)?1:0;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = opa1 - opb1;
						t.OFLOW = (opa1 < opb1)?1:0;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = opa1 - opb1;
					t.OFLOW = (opa1 < opb1)?1:0;
					reset();
				      end
				endcase
				end
			4'b0010:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = opa1 + opb1 + t.CIN;
						t.COUT = t.RES[`DW]?1:0;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = opa1 + opb1 + t.CIN;
						t.COUT = t.RES[`DW]?1:0;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = opa1 + opb1 + t.CIN;
					t.COUT = t.RES[`DW]?1:0;
					reset();
				      end
				endcase
				end
			4'b0011:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = opa1 - opb1 - t.CIN;
						t.OFLOW = (opa1 < opb1)?1:0;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = opa1 - opb1 - t.CIN;
						t.OFLOW = (opa1 < opb1)?1:0;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = opa1 - opb1 - t.CIN;
					t.OFLOW = (opa1 < opb1)?1:0;
					reset();
				      end
				endcase
				end
			4'b0100:begin
				case(t.INP_VALID)
				2'b01, 2'b11:begin
					store_a(t);
					t.RES = opa1 + 1;
					reset();
					end
				default: wait_cnt(t);
				endcase
				end
			4'b0101:begin
				case(t.INP_VALID)
				2'b01, 2'b11:begin
					store_a(t);
					t.RES = opa1 - 1;
					reset();
					end
				default: wait_cnt(t);
				endcase
				end
			4'b0110:begin
				case(t.INP_VALID)
				2'b10, 2'b11:begin
					store_b(t);
					t.RES = opb1 + 1;
					reset();
					end
				default: wait_cnt(t);
				endcase				
				end

			4'b0111:begin
				case(t.INP_VALID)
				2'b10, 2'b11:begin
					store_b(t);
					t.RES = opb1 - 1;
					reset();
					end
				default: wait_cnt(t);
				endcase	
				end
			4'b1000:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						{t.G, t.E, t.L} = (opa1 > opb1)?3'b1zz:(opa1 == opb1)? 3'bz1z: 3'bzz1;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						{t.G, t.E, t.L} = (opa1 > opb1)?3'b1zz:(opa1 == opb1)? 3'bz1z: 3'bzz1;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					{t.G, t.E, t.L} = (opa1 > opb1)?3'b1zz:(opa1 == opb1)? 3'bz1z: 3'bzz1;
					reset();
				      end
				endcase
				end
			4'b1001:begin//check temp2
				case(t.INP_VALID)
				2'b00: reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
					if (m_cnt == 0) begin
						res1 = opa1 + 1;
						res2 = opb1 + 1;
					end
					if(m_cnt < 2)
						m_cnt = m_cnt + 1;
					else begin
						t.RES = res1 * res2;
						reset();
				      	end
					end
					else
						wait_cnt(t);
					end
				2'b10:begin
					store_b(t);
					if(va)begin
					if (m_cnt == 0) begin
						res1 = opa1 + 1;
						res2 = opb1 + 1;
					end
					if(m_cnt < 2)
						m_cnt = m_cnt + 1;
					else begin
						t.RES = res1 * res2;
						reset();
				      	end
					end
					else
						wait_cnt(t);
					end
				2'b11:begin
					if (!(va && vb)) 
					store_ab(t);
					if (m_cnt == 0) begin
						res1 = opa1 + 1;
						res2 = opb1 + 1;
					end
					if(m_cnt < 2)
						m_cnt = m_cnt + 1;
					else begin
						t.RES = res1 * res2;
						reset();
				      	end
					end
					endcase
				end

			4'b1010:begin//check temp2
				case(t.INP_VALID)
				2'b00: reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
					if (m_cnt == 0) begin
						res1 = opa1 << 1;
						res2 = opb1;

					end
					if(m_cnt < 2)
						m_cnt = m_cnt + 1;
					else begin
						t.RES = res1 * res2;
						reset();
				      	end
					end
					else
						wait_cnt(t);
					end
				2'b10:begin
					store_b(t);
					if(va)begin
					if (m_cnt == 0) begin
						res1 = opa1 << 1;
						res2 = opb1;

					end
					if(m_cnt < 2)
						m_cnt = m_cnt + 1;
					else begin
						t.RES = res1 * res2;
						reset();
				      	end
					end
					else
						wait_cnt(t);
					end
				2'b11:begin 
					if (!(va && vb))
					store_ab(t);
					if (m_cnt == 0) begin
						res1 = opa1 << 1;
						res2 = opb1;
					end
					if(m_cnt < 2)
						m_cnt = m_cnt + 1;
					else begin
						t.RES = res1 * res2;
						reset();
				      	end
					end
					endcase
				end
			default:reset();
			endcase
	end
//Logical
	else begin
		reset();
		case(t.CMD)
			4'b0000:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, (opa1 & opb1)};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, (opa1 & opb1)};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, (opa1 & opb1)};
					reset();
				      end
				endcase
				end
			4'b0001: begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, ~(opa1 & opb1)};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, ~(opa1 & opb1)};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, ~(opa1 & opb1)};
					reset();
				      end
				endcase
				end
			4'b0010:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, (opa1 | opb1)};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, (opa1 | opb1)};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, (opa1 | opb1)};
					reset();
				      end
				endcase
				end
			4'b0011:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, ~(opa1 | opb1)};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, ~(opa1 | opb1)};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, ~(opa1 | opb1)};
					reset();
				      end
				endcase
				end
			4'b0100: begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, (opa1 ^ opb1)};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, (opa1 ^ opb1)};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, (opa1 ^ opb1)};
					reset();
				      end
				endcase
				end
			4'b0101:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, ~(opa1 ^ opb1)};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, ~(opa1 ^ opb1)};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, ~(opa1 ^ opb1)};
					reset();
				      end
				endcase
				end
			4'b0110:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, ~opa1};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, ~opa1};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, ~opa1};
					reset();
				      end
				endcase
				end
			4'b0111:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, ~opb1};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, ~opb1};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, ~opb1};
					reset();
				      end
				endcase
				end
			4'b1000:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, opa1 >> 1};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, opa1 >> 1};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, opa1 >> 1};
					reset();
				      end
				endcase
				end
			4'b1001:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, opb1 << 1};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, opb1 << 1};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, opb1 << 1};
					reset();
				      end
				endcase
				end
			4'b1010:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, opa1 >> 1};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, opa1 >> 1};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, opa1 >> 1};
					reset();
				      end
				endcase
				end
			4'b1011: begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, opb1 << 1};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, opb1 << 1};
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, opb1 << 1};
					reset();
				      end
				endcase
				end
			4'b1100:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {opa1 << opb1[$clog2(`DW)-1:0]};
						t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {opa1 << opb1[$clog2(`DW)-1:0]};
						t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {opa1 << opb1[$clog2(`DW)-1:0]};
					t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
					reset();
				      end
				endcase
				end
			4'b1101:begin
				case(t.INP_VALID)
				2'b00:reset();
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {opa1 >> opb1[$clog2(`DW)-1:0]};
						t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {opa1 >> opb1[$clog2(`DW)-1:0]};
						t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {opa1 >> opb1[$clog2(`DW)-1:0]};
					t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
					reset();
				      end
				endcase
				end
			default:begin
				reset();
				end
			endcase
		end
		end
	end
	end
endtask
endclass


