/*------------------------------------------------------------------------------
-- Author: Muhamamd Sufiyan Sadiq 
--  Date: 18_04_2026
--  
--  Passive monitor to check the output of the cache
------------------------------------------------------------------------------*/

// ths is the monitor to sample signals on input and ouput interface
class cache_out_monitor extends uvm_component;
	`uvm_component_utils(cache_out_monitor)

	// virtual interfaces
	virtual cache_out_if #(32) cache_vof;
	
	// transactions
	cache_rsp  cache_out_tx;

	// monitor application ports
	uvm_analysis_port #(cache_rsp)  cache_out_port;

	function new(string name = "cache_out_monitor", uvm_component parent);
		super.new(name,parent);
		cache_out_tx = new();
		cache_out_port = new("cache_out_port", this);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// get interfaces
		if(!uvm_config_db#(virtual cache_out_if #(32))::get(this, "", "out_vif", cache_vof))
			`uvm_fatal("[cache_out_monitor]", "Unable to get cache output interface")
	endfunction : build_phase


	virtual task main_phase(uvm_phase phase);
		super.main_phase(phase);
		forever begin
			@(posedge cache_vof.o_valid);
			cache_out_tx.hit 		= cache_vof.hit;
			cache_out_tx.miss 		= cache_vof.miss;
			cache_out_tx.o_data 	= cache_vof.o_data;
			cache_out_tx.o_valid	= cache_vof.o_valid;
			`uvm_info("cache_out_monitor", "Output sent to scoreboard", UVM_LOW)
			cache_out_tx.display_output();
			cache_out_port.write(cache_out_tx);
			
			// @(posedge cache_vof.clk);
		end
	endtask : main_phase


endclass : cache_out_monitor