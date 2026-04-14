/*------------------------------------------------------------------------------
-- Author: Muhamamd Sufiyan Sadiq 
--  Date: 07_04_2026
--  
--  This is to record transactions coming inside of the cache
------------------------------------------------------------------------------*/

// ths is the monitor to sample signals on input and ouput interface
class cache_monitor extends uvm_component;
	`uvm_component_utils(cache_monitor)

	// virtual interfaces
	virtual cache_inp_if #(32,32) cache_vif;
	
	// transactions
	cache_tx  cache_inp_tx;

	// monitor application ports
	uvm_analysis_port #(cache_tx)  cache_inp_port;

	function new(string name = "cache_monitor", uvm_component parent);
		super.new(name,parent);
		cache_inp_tx = new();

	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		cache_inp_port = new("cache_inp_port", this);

		// get interfaces
		if(!uvm_config_db#(virtual cache_inp_if #(32,32))::get(this, "", "inp_vif", cache_vif))
			`uvm_fatal("[CACHE_MONITOR]", "Unable to get cache input interface")
	endfunction : build_phase


	virtual task main_phase(uvm_phase phase);
		super.main_phase(phase);
		forever begin
			@(posedge cache_vif.clk);
			cache_inp_tx.address <= cache_vif.address;
			cache_inp_tx.rd_en   <= cache_vif.rd_en;
			cache_inp_tx.wr_en   <= cache_vif.wr_en;
			cache_inp_tx.wr_data <= cache_vif.wr_data;
			cache_inp_port.write(cache_inp_tx);
			@(posedge cache_vif.clk);
		end
	endtask : main_phase


endclass : cache_monitor

