`include "defines.sv"
class alu_sequence extends uvm_sequence #(alu_seq_item);
`uvm_object_utils(alu_sequence)

function new(string name = "alu_sequence");
	super.new(name);
endfunction

task body();
	repeat(25)begin
	req = alu_seq_item::type_id::create("req");
	begin	
		start_item(req);
		assert(req.randomize());
		finish_item(req);
		end
	end	
endtask
endclass

