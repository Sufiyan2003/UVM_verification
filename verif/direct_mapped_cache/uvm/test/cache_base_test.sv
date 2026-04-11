/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 09_04_2026
--  Description: This is the base_Test
------------------------------------------------------------------------------*/

class cache_base_test extends uvm_test;
	`uvm_component_utils(cache_base_test)


	function new(string name="cache_base_test", uvm_component parent);
		super.new(name,parent);
	endfunction : new




	virtual task main_phase(uvm_phase phase);
		phase.raise_objection(this);
		// custom implementPtion in derived tests
		// this will be overriden with that
		phase.drop_objection(this);
	endtask : main_phase


	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction

endclass : cache_base_test


