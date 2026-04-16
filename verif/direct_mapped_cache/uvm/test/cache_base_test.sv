/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 09_04_2026
--  Description: This is the base_Test
------------------------------------------------------------------------------*/

class cache_base_test extends uvm_test;
	`uvm_component_utils(cache_base_test)

	cache_env     env;
	cache_req_seq seq;

	function new(string name="cache_base_test", uvm_component parent);
		super.new(name,parent);
	endfunction : new


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = cache_env::type_id::create("env", this);
		seq = cache_req_seq::type_id::create("seq", this);
	endfunction

	// this task will be overriden by the class that extends base test
	virtual task main_phase(uvm_phase phase);
		// custom implementPtion in derived tests
		// this will be overriden with that
		phase.raise_objection(this);
		seq.start(env.c_agent.c_seqr);
		phase.drop_objection(this);
	endtask : main_phase


	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction

endclass : cache_base_test


