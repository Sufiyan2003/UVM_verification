/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 08_04_2026
--  Description: This is the cache agent
------------------------------------------------------------------------------*/


class cache_agent extends  uvm_component;
	`uvm_component_utils(cache_agent)

	uvm_sequencer #(cache_tx) c_seqr;
	cache_driver c_driver;
	cache_monitor c_monitor;

	function new(string name="cache_agent", uvm_component parent);
		super.new(name,parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		c_seqr = uvm_sequencer#(cache_tx)::type_id::create("seqr", this);
		c_driver = cache_driver::type_id::create("c_driver", this);
		c_monitor = cache_monitor::type_id::create("c_monitor", this);
	endfunction

	function void connect_phase(uvm_phase phase);
		c_driver.seq_item_port.connect(c_seqr.seq_item_export);
	endfunction
endclass : cache_agent
