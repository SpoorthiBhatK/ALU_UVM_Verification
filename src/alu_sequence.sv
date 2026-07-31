`include "defines.sv"
class alu_sequence extends uvm_sequence #(alu_seq_item);
`uvm_object_utils(alu_sequence)

function new(string name = "alu_sequence");
	super.new(name);
endfunction

task body();
	req = alu_seq_item::type_id::create("req");
	begin	
		start_item(req);
		assert(req.randomize()with{req.CE == 'd1;
					   req.OPA == 'd10;
					   req.OPB == 'd5;
					   req.INP_VALID == 2'b11;
					   req.CIN == 'd0;
					   req.MODE == 'd1;
					   req.CMD == 'd1;});
		finish_item(req);
	end	
endtask
endclass

