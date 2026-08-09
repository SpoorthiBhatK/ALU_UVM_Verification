`include "defines.sv"

class alu_seq_item extends uvm_sequence_item;

rand bit [`DW-1:0] OPA;
rand bit [`DW-1:0] OPB;
rand bit CE, MODE, CIN;
rand bit [`CW-1:0] CMD;
rand bit [1:0] INP_VALID;

bit [`DW*2-1:0]RES;
bit COUT, OFLOW, G, L, E, ERR;

constraint m_v{
	MODE -> CMD inside {[0:10]};
	!MODE -> CMD inside {[0:13]};
}
constraint cmd_dst{ 
	if (MODE)
	        CMD dist { [0:10] := 1 };
	else
        	CMD dist { [0:13] := 1 };
}
constraint vld{INP_VALID dist{3:/2, [0:2]:/1};}

`uvm_object_utils_begin(alu_seq_item)
`uvm_field_int(OPA, UVM_ALL_ON | UVM_DEC)
`uvm_field_int(OPB, UVM_ALL_ON | UVM_DEC)
`uvm_field_int(CIN, UVM_ALL_ON | UVM_DEC)
`uvm_field_int(CMD, UVM_ALL_ON | UVM_DEC)
`uvm_field_int(MODE, UVM_ALL_ON | UVM_DEC)		
`uvm_field_int(CE, UVM_ALL_ON | UVM_DEC)
`uvm_field_int(INP_VALID, UVM_ALL_ON | UVM_DEC)
`uvm_field_int(COUT, UVM_ALL_ON | UVM_DEC);
`uvm_field_int(OFLOW, UVM_ALL_ON | UVM_DEC);
`uvm_field_int(G, UVM_ALL_ON | UVM_DEC);
`uvm_field_int(L, UVM_ALL_ON | UVM_DEC);
`uvm_field_int(E, UVM_ALL_ON | UVM_DEC);
`uvm_field_int(ERR, UVM_ALL_ON | UVM_DEC);
`uvm_object_utils_end

function new(string name = "seq_item");
	super.new(name);
endfunction

endclass
