`include "defines.sv"
class alu_sequence extends uvm_sequence #(alu_seq_item);
`uvm_object_utils(alu_sequence)

function new(string name = "alu_sequence");
	super.new(name);
endfunction

task body();
	arithmetic_seq();
	logical_seq();
	arithmetic_seq_corner();
	logical_seq_corner();
endtask
task arithmetic_seq();
	for(int i = 0; i <= 10; i = i + 1)begin
		repeat(10)begin
			req = alu_seq_item::type_id::create("req");
				
			start_item(req);
			assert(req.randomize()with{MODE == 1;CMD == i;});
			finish_item(req);
		end	
	end	
endtask
task logical_seq();
	for(int i = 0; i <= 13; i = i + 1)begin
		repeat(10)begin
			req = alu_seq_item::type_id::create("req");
				
			start_item(req);
			assert(req.randomize()with{MODE == 0;CMD == i;});
			finish_item(req);
		end	
	end	
endtask
task arithmetic_seq_corner();
	for(int i = 0; i <= 10; i = i + 1)begin
		repeat(10)begin
			req = alu_seq_item::type_id::create("req");
				
			start_item(req);
			assert(req.randomize()with{MODE == 1;CMD == i;OPA == 8'hFF;OPB == 8'hFF;});
			finish_item(req);
		end	
	end
	req = alu_seq_item::type_id::create("req");
repeat(10)begin
    start_item(req);
    assert(req.randomize() with {
        MODE      == 1;
        CMD       == 4'b1000;
        CE        == 1;
        INP_VALID == 2'b11;
        OPA       == 8'd10;
        OPB       == 8'd20;
    });
    finish_item(req);	
end
endtask
task logical_seq_corner();
	for(int i = 0; i <= 13; i = i + 1)begin
		repeat(10)begin
			req = alu_seq_item::type_id::create("req");
				
			start_item(req);
			assert(req.randomize()with{MODE == 0;CMD == i;OPA == 8'hFF;OPB == 8'hFF;});
			finish_item(req);
		end	
	end	
endtask
endclass
