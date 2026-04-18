/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 08_04_2026
--  Description: This is the cache environment
------------------------------------------------------------------------------*/

class cache_env extends uvm_env;
	`uvm_component_utils(cache_env)
	
	cache_agent 	      c_agent;
	cache_responder_agent mem_agent;
	cache_out_monitor     passive_mon;
	cache_scoreboard      cache_scbrd;

	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		c_agent 	= cache_agent::type_id::create("cache_agent", this);
		passive_mon = cache_out_monitor::type_id::create("passive_mon", this);
		mem_agent 	= cache_responder_agent::type_id::create("mem_agent", this);
		cache_scbrd = cache_scoreboard::type_id::create("cache_scbrd", this);	
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		c_agent.c_monitor.cache_inp_port.connect(cache_scbrd.cache_in_port);
		mem_agent.mem_monitor.mem_rsp_port.connect(cache_scbrd.mem_fill_port);
		passive_mon.cache_out_port.connect(cache_scbrd.cache_out_port);
		
	endfunction : connect_phase
endclass : cache_env