/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 08_04_2026
--  Description: This is the cache environment
------------------------------------------------------------------------------*/

class cache_env extends uvm_env;
	`uvm_component_utils(cache_env)
	
	cache_agent c_agent;

	cache_responder_agent mem_agent;

	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		c_agent = cache_agent::type_id::create("cache_env", this);
		// c_driver = cache_memory_driver::type_id::create("cache_memory_driver", this);
		mem_agent = cache_responder_agent::type_id::create("mem_agent", this);	
	endfunction
endclass : cache_env