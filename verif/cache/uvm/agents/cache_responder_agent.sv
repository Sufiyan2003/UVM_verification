/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 08_04_2026
--  Description: This is the cache passive agent, responsible for fulfilling missed 
--  requests (WHY THOUGH find a better way to do it twin)
------------------------------------------------------------------------------*/


class cache_responder_agent extends  uvm_component;
	`uvm_component_utils(cache_responder_agent)

	uvm_sequencer #(cache_mem_rsp) c_seqr;
	cache_memory_driver mem_driver;
	ext_mem_monitor mem_monitor;

	function new(string name="cache_responder_agent", uvm_component parent);
		super.new(name,parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		c_seqr = uvm_sequencer#(cache_mem_rsp)::type_id::create("seqr", this);
		mem_driver = cache_memory_driver::type_id::create("mem_driver", this);
		mem_monitor = ext_mem_monitor::type_id::create("mem_monitor",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		mem_driver.seq_item_port.connect(c_seqr.seq_item_export);
	endfunction
endclass : cache_responder_agent