`include "defines.sv"
class alu_sequence extends uvm_sequence #(alu_seq_item);
`uvm_object_utils(alu_sequence)

function new(string name = "alu_sequence");
	super.new(name);
endfunction

task body();
//	`uvm_info("Seq",$sformatf("---------------------------Arithmetic-----------------------"),UVM_NONE)
	arithmetic_seq();
//	`uvm_info("Seq",$sformatf("---------------------------Multiplication-----------------------"),UVM_NONE)
	mul_latency_seq();
//	`uvm_info("Seq",$sformatf("---------------------------Logical-----------------------"),UVM_NONE)
	logical_seq();
//	`uvm_info("Seq",$sformatf("---------------------------Corner add case-----------------------"),UVM_NONE)
	add_corner();
//	`uvm_info("Seq",$sformatf("---------------------------Corner sub case-----------------------"),UVM_NONE)
	sub_corner();
	
endtask

task logical_seq();
	for(int i = 0; i <= 8; i = i + 1)begin
		repeat(10)begin
			req = alu_seq_item::type_id::create("req");
				
			start_item(req);
			assert(req.randomize()with{MODE == 0;CMD == i;CE == 1;});
			finish_item(req);
		end	
	end	
endtask
task arithmetic_seq();
	for(int i = 0; i <= 13; i = i + 1)begin
		repeat(10)begin
			req = alu_seq_item::type_id::create("req");
				
			start_item(req);
			assert(req.randomize()with{MODE == 1;CMD == i;CE == 1;});
			finish_item(req);
		end	
	end	
endtask
task mul_latency_seq();
alu_seq_item idel_req;
bit [1:0] cnt = 2;
	for(int i = 9; i <= 10; i = i + 1)begin
		repeat(10)begin
			req = alu_seq_item::type_id::create("req");	
			start_item(req);
			assert(req.randomize()with{MODE == 1;CMD == i;CE == 1;});
			finish_item(req);
			repeat(cnt)begin
				idel_req = alu_seq_item::type_id::create("idle_req");	
				start_item(idel_req);
				assert(idel_req.randomize()with{CE == 1;INP_VALID==0;CMD == i;});
				finish_item(idel_req);
			end
		end	
	end	
endtask
task add_corner();
	repeat(10)begin
		req = alu_seq_item::type_id::create("req");
	    	start_item(req);
	    	assert(req.randomize() with {MODE == 1;CMD == 0;CE == 1;INP_VALID == 2'b11;OPA == 8'hFF;OPB == 8'hFF;CIN == 1'b1;});
		finish_item(req);
	end
endtask

task sub_corner();
	repeat(10)begin
		req = alu_seq_item::type_id::create("req");
	    	start_item(req);
	    	assert(req.randomize() with {MODE == 1;CMD == 1;CE == 1;INP_VALID == 2'b11;OPA == 8'h00;OPB == 8'hFF;CIN == 1'b1;});
		finish_item(req);
	end
endtask	


endclass




