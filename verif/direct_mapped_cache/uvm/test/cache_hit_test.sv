/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 09_04_2026
--  Description: This is the hit test, responsible for only hitting  the cache
------------------------------------------------------------------------------*/


class cache_hit_test extends cache_base_test;
	`uvm_component_utils(cache_hit_test)

	cache_hit_seq hit_seq;

	function new(string name="cache_hit_test", uvm_component parent);
		super.new(name,parent);
		hit_seq = new();
	endfunction

	virtual task main_phase(uvm_phase phase);
		phase.raise_objection(this);
		// super.main_phase(phase);
		hit_seq.start(env.c_agent.c_seqr);
		phase.drop_objection(this);
	endtask 

endclass : cache_hit_test


