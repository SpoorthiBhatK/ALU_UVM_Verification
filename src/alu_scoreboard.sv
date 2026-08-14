`include "defines.sv"

class alu_scoreboard extends uvm_scoreboard;

`uvm_component_utils(alu_scoreboard)

uvm_tlm_analysis_fifo #(alu_seq_item) ip_mon_fifo;
uvm_tlm_analysis_fifo #(alu_seq_item) op_mon_fifo;

alu_seq_item ip_mon;
alu_seq_item op_mon;

alu_config cfg;

bit [`DW-1:0] opa1,opb1;
bit [`CW-1:0] cmd;
bit [`DW*2-1:0] res1, res2;

bit [4:0]cnt;
bit va, vb, mode;

bit [`DW*2-1:0] last_res;
bit last_cout;
bit last_oflow;
bit last_g;
bit last_l;
bit last_e;
bit last_err; 

bit mul_first_output = 1;
alu_seq_item mul_exp_q[$];
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
		ref_model(ip_mon);

		if ((ip_mon.MODE == 1) && ((ip_mon.CMD == 4'b1001) || (ip_mon.CMD == 4'b1010))) begin

			mul_exp_q.push_back(ip_mon);
	 	    	op_mon_fifo.get(op_mon);

		    	if (mul_first_output) begin
		        	mul_first_output = 0;
		   	end
		    	else begin
		        	alu_seq_item exp;
		        	exp = mul_exp_q.pop_front();
			        check_data_exp(exp, op_mon);
		    	end

		end
		else begin
			op_mon_fifo.get(op_mon);
		    	check_data(op_mon);
		end
	    end
endtask

task check_data_exp(alu_seq_item exp, alu_seq_item cd);

    `uvm_info("Scoreboard",
        $sformatf(
        "\nExp RES: %d, actual RES: %d\nExp ERR: %d, actual ERR: %d\nExp COUT: %d, actual COUT: %d\nExp OFLOW: %d, actual OFLOW: %d\nExp G: %d, actual G: %d\nExp L: %d, actual L: %d\nExp E: %d, actual E: %d\n",
        exp.RES, cd.RES,
        exp.ERR, cd.ERR,
        exp.COUT, cd.COUT,
        exp.OFLOW, cd.OFLOW,
        exp.G, cd.G,
        exp.L, cd.L,
        exp.E, cd.E),
        UVM_NONE);

    if(exp.RES == cd.RES)
        $display("RES MATCH\n");
    else
        $display("RES MISMATCH\n");

    if(exp.ERR == cd.ERR)
        $display("ERR MATCH\n");
    else
        $display("ERR MISMATCH\n");

    if(exp.COUT == cd.COUT)
        $display("COUT MATCH\n");
    else
        $display("COUT MISMATCH\n");

    if(exp.OFLOW == cd.OFLOW)
        $display("OFLOW MATCH\n");
    else
        $display("OFLOW MISMATCH\n");

    if(exp.G == cd.G)
        $display("G MATCH\n");
    else
        $display("G MISMATCH\n");

    if(exp.L == cd.L)
        $display("L MATCH\n");
    else
        $display("L MISMATCH\n");

    if(exp.E == cd.E)
        $display("E MATCH\n");
    else
        $display("E MISMATCH\n");

endtask
task check_data(alu_seq_item cd);
	`uvm_info("Scoreboard",  $sformatf("\nExp RES: %d, actual RES: %d\nExp ERR: %d, actual ERR: %d\nExp COUT: %d, actual COUT: %d\nExp OFLOW: %d, actual OFLOW: %d\nExp G: %d, actual G: %d\nExp L: %d, actual L: %d\nExp E: %d, actual E: %d\n", ip_mon.RES, cd.RES, ip_mon.ERR, cd.ERR, ip_mon.COUT, cd.COUT, ip_mon.OFLOW, cd.OFLOW, ip_mon.G, cd.G, ip_mon.L, cd.L, ip_mon.E, cd.E), UVM_NONE)
	
	if(ip_mon.RES == cd.RES)begin
		$display("RES MATCH\n");
	end
	else begin
		$display("RES MISMATCH\n");
	end
	if(ip_mon.ERR == cd.ERR)begin
		$display("ERR MATCH\n");
	end
	else begin
		$display("ERR MISMATCH\n");
	end
	if(ip_mon.COUT == cd.COUT)begin
		$display("COUT MATCH\n");
	end
	else begin
		$display("COUT MISMATCH\n");
	end
	if(ip_mon.OFLOW == cd.OFLOW)begin
		$display("OFLOW MATCH\n");
	end
	else begin
		$display("OFLOW MISMATCH\n");
	end
	if(ip_mon.G == cd.G)begin
		$display("G MATCH\n");
	end
	else begin
		$display("G MISMATCH\n");
	end
	if(ip_mon.L == cd.L)begin
		$display("L MATCH\n");
	end
	else begin
		$display("L MISMATCH\n");
	end
	if(ip_mon.E == cd.E)begin
		$display("E MATCH\n");
	end
	else begin
		$display("E MISMATCH\n");
	end
endtask
	
task reset();
	opa1 = '0;
	opb1 = '0;
	va = '0;
	vb = '0;
	cnt = '0;
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
endtask

task mode_cmd_change(alu_seq_item t);
	if(mode != t.MODE)
		reset();
mode = t.MODE;
cmd = t.CMD;
endtask

task save_outputs(alu_seq_item t);
	last_res   = t.RES;
    	last_cout  = t.COUT;
    	last_oflow = t.OFLOW;
    	last_g     = t.G;
    	last_l     = t.L;
    	last_e     = t.E;
    	last_err   = t.ERR;
endtask

task hold_outputs(alu_seq_item t);
	t.RES    = last_res;
    	t.COUT   = last_cout;
    	t.OFLOW  = last_oflow;
    	t.G      = last_g;
    	t.L      = last_l;
    	t.E      = last_e;
    	t.ERR    = last_err;
endtask

task wait_cnt(alu_seq_item t);
	hold_outputs(t);
	
	if(va ^ vb)begin
		cnt = cnt + 1;
		if(cnt == 16)begin
			t.ERR = 1;
		    	t.RES = 0;
		    	t.COUT = 0;
		    	t.OFLOW = 0;
		    	t.G = 0;
		    	t.L = 0;
		    	t.E = 0;
			reset();
		end
	end
	else
		cnt = 0;
endtask


task ref_model(alu_seq_item t);
	if(cfg.vif.RST)begin
		reset();
		t.RES = 0; t.COUT = 0; t.OFLOW = 0; t.G = 0; t.L = 0; t.E = 0; t.ERR = 0;
	end
	else begin
	if(t.CE == 0)begin
		wait_cnt(t);
		return;
	end
	else begin
	if(t.MODE == 1)begin
			mode_cmd_change(t);
			case(t.CMD)
			//ADD
			4'b0000:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = opa1 + opb1;
						t.COUT = t.RES[`DW]?1:0;
						save_outputs(t);
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
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = opa1 + opb1;
					t.COUT = t.RES[`DW]?1:0;
					save_outputs(t);
					reset();
				      end
				endcase
				end
			//SUB
			4'b0001:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = opa1 - opb1;
						t.OFLOW = (opa1 < opb1)?1:0;
						save_outputs(t);
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
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = opa1 - opb1;
					t.OFLOW = (opa1 < opb1)?1:0;
					save_outputs(t);
					reset();
				      end
				endcase
				end
			//ADD_CIN
			4'b0010:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = opa1 + opb1 + t.CIN;
						t.COUT = t.RES[`DW]?1:0;
						save_outputs(t);
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
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = opa1 + opb1 + t.CIN;
					t.COUT = t.RES[`DW]?1:0;
					save_outputs(t);
					reset();
				      end
				endcase
				end
			//SUB_CIN
			4'b0011:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = opa1 - opb1 - t.CIN;
						t.OFLOW = (opa1 < opb1)?1:0;
						save_outputs(t);
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
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = opa1 - opb1 - t.CIN;
					t.OFLOW = (opa1 < opb1)?1:0;
					save_outputs(t);
					reset();
				      end
				endcase
				end
			//INC_A	
			4'b0100:begin
				case(t.INP_VALID)
				2'b01:begin
					store_a(t);
					t.RES = opa1 + 1;
					save_outputs(t);
					reset();
					end
				2'b11:begin
					store_a(t);
					t.RES = opa1 + 1;
					save_outputs(t);
					reset();
					end
				default: wait_cnt(t);
				endcase
				end
			4'b0101:begin
				case(t.INP_VALID)
				2'b01:begin
					store_a(t);
					t.RES = opa1 - 1;
					save_outputs(t);
					reset();
					end
				 2'b11:begin
					store_a(t);
					t.RES = opa1 - 1;
					save_outputs(t);
					reset();
					end
				default: wait_cnt(t);
				endcase
				end
			4'b0110:begin
				case(t.INP_VALID)
				2'b10:begin
					store_b(t);
					t.RES = opb1 + 1;
					save_outputs(t);
					reset();
					end
				2'b11:begin
					store_b(t);
					t.RES = opb1 + 1;
					save_outputs(t);
					reset();
					end
				default: wait_cnt(t);
				endcase				
				end

			4'b0111:begin
				case(t.INP_VALID)
				2'b10:begin
					store_b(t);
					t.RES = opb1 - 1;
					save_outputs(t);
					reset();
					end
				2'b11:begin
					store_b(t);
					t.RES = opb1 - 1;
					save_outputs(t);
					reset();
					end
				default: wait_cnt(t);
				endcase	
				end
			4'b1000:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						{t.G, t.E, t.L} = (opa1 > opb1)?3'b100:(opa1 == opb1)? 3'b01: 3'b001;
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						{t.G, t.E, t.L} = (opa1 > opb1)?3'b100:(opa1 == opb1)? 3'b01: 3'b001;
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					{t.G, t.E, t.L} = (opa1 > opb1)?3'b100:(opa1 == opb1)? 3'b01: 3'b001;
					save_outputs(t);
					reset();
				      end
				endcase
				end

			4'b1001: begin
				case(t.INP_VALID)
				2'b00: begin
					wait_cnt(t);
				end
				2'b01: begin
				   	store_a(t);
				    	if(vb) begin
						res1 = (opa1 + 1) & 8'hFF;
						res2 = (opb1 + 1) & 8'hFF;
						t.RES = res1 * res2;
						save_outputs(t);
						reset();
		                        end
				    	else begin
						wait_cnt(t);
				         end
					end
				2'b10: begin
					    store_b(t);
					    if(va) begin
						res1 = (opa1 + 1) & 8'hFF;
						res2 = (opb1 + 1) & 8'hFF;

						t.RES = res1 * res2;

						save_outputs(t);
						reset();
					    end
					    else begin
						wait_cnt(t);
					    end
					end
				2'b11: begin
					    opa1 = t.OPA;
					    opb1 = t.OPB;

					    res1 = (opa1 + 1) & 8'hFF;
					    res2 = (opb1 + 1) & 8'hFF;

					    t.RES = res1 * res2;

					    save_outputs(t);
					    reset();
					end
			    endcase

			end
			4'b1010: begin
			    	case(t.INP_VALID)
				2'b00: begin
                			wait_cnt(t);
				end
				2'b01: begin
				    		store_a(t);
				    	if(vb) begin
						res1 = (opa1 << 1) & 8'hFF;
						res2 = opb1;
						t.RES = res1 * res2;
						save_outputs(t);
						reset();
					    end
				    	else begin
						wait_cnt(t);
					end
				end
				2'b10: begin
				    		store_b(t);
				       	if(va) begin
						res1 = (opa1 << 1) & 8'hFF;;
						res2 = opb1;
						t.RES = res1 * res2;
						save_outputs(t);
						reset();
				    	end
				    	else begin
						wait_cnt(t);
				    	end
				end
				2'b11: begin
					    opa1 = t.OPA;
					    opb1 = t.OPB;
					    res1 = (opa1 << 1) & 8'hFF;;
					    res2 = opb1;
					    t.RES = res1 * res2;
					    save_outputs(t);
					    reset();
					end

			    endcase

			end
		endcase
	end
//Logical
	else begin
		case(t.CMD)
			4'b0000:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, (opa1 & opb1)};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, (opa1 & opb1)};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, (opa1 & opb1)};
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b0001: begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, ~(opa1 & opb1)};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, ~(opa1 & opb1)};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, ~(opa1 & opb1)};
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b0010:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, (opa1 | opb1)};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, (opa1 | opb1)};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, (opa1 | opb1)};
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b0011:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, ~(opa1 | opb1)};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, ~(opa1 | opb1)};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, ~(opa1 | opb1)};
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b0100: begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, (opa1 ^ opb1)};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, (opa1 ^ opb1)};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, (opa1 ^ opb1)};
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b0101:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, ~(opa1 ^ opb1)};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, ~(opa1 ^ opb1)};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, ~(opa1 ^ opb1)};
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b0110:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, ~opa1};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, ~opa1};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, ~opa1};
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b0111:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {1'b0, ~opb1};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {1'b0, ~opb1};
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, ~opb1};
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b1000:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					t.RES = {1'b0, opa1 >> 1};
					save_outputs(t);
					reset();
				      end
				2'b10:reset();
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, opa1 >> 1};
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b1001:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					t.RES = {1'b0, opa1 << 1};
					save_outputs(t);
					reset();
					end
				2'b10:reset();
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, opa1 << 1};
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b1010:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:reset();
				2'b10:begin
					store_b(t);
					t.RES = {1'b0, opb1 >> 1};
					save_outputs(t);
					reset();
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, opb1 >> 1};
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b1011: begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:reset();
				2'b10:begin
					store_b(t);
					t.RES = {1'b0, opb1 << 1};
					save_outputs(t);
					reset();
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {1'b0, opb1 << 1};
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b1100:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {(opa1 << opb1[$clog2(`DW)-1:0]) | (opa1 >> (`DW - opb1[$clog2(`DW)-1:0]))};
						t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {(opa1 << opb1[$clog2(`DW)-1:0]) | (opa1 >> (`DW - opb1[$clog2(`DW)-1:0]))};
						t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {(opa1 << opb1[$clog2(`DW)-1:0]) | (opa1 >> (`DW - opb1[$clog2(`DW)-1:0]))};
					t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
					save_outputs(t);
					reset();
				      end
				endcase
				end
			4'b1101:begin
				case(t.INP_VALID)
				2'b00:wait_cnt(t);
				2'b01:begin
					store_a(t);
					if(vb)begin
						t.RES = {(opa1 >> opb1[$clog2(`DW)-1:0]) | (opa1 << (`DW - opb1[$clog2(`DW)-1:0]))};
						t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b10:begin
					store_b(t);
					if(va)begin
						t.RES = {(opa1 >> opb1[$clog2(`DW)-1:0]) | (opa1 << (`DW - opb1[$clog2(`DW)-1:0]))};
						t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
						save_outputs(t);
						reset();
					end
					else
						wait_cnt(t);
				      end
				2'b11:begin
					store_ab(t);
					t.RES = {(opa1 >> opb1[$clog2(`DW)-1:0]) | (opa1 << (`DW - opb1[$clog2(`DW)-1:0]))};
					t.ERR = opb1[(`DW-1):$clog2(`DW)]?1:0;
					save_outputs(t);
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
endtask
endclass


