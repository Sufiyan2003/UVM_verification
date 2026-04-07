/*------------------------------------------------------------------------------
-- Author: Muhamamd Sufiyan Sadiq 
--  Date: 07_04_2026
--  
--  
------------------------------------------------------------------------------*/

// ths is the monitor to sample signals on input and ouput interface
class cache_monitor extends uvm_component;
	`uvm_component_utils(cache_monitor)

	// virtual interfaces
	virtual cache_if #(32,32) cache_vif;
	virtual cache_of #(32)    cache_vof;
	
	// transactions
	cache_tx  cache_inp_tx;
	cache_rsp cache_rsp_tx;

	// monitor application ports
	uvm_analysis_port #(cache_tx)  cache_inp_port;
	uvm_analysis_port #(cache_rsp) cache_rsp_port;


	function new(string name = "cache_monitor");
		super.new(name);
		cache_inp_tx = new();
		cache_rsp_tx = new();
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		cache_inp_port = new("cache_inp_port", this);
		cache_rsp_port = new("cache_rsp_port", this);

		// get interfaces
		if(!uvm_config_db#(virtual cache_if #(32,32))::get(this, "", "cache_vif", cache_vif))
			`uvm_fatal("[CACHE_MONITOR]", "Unable to get cache input interface")

		if(!uvm_config_db#(virtual cache_of #(32))::get(this, "", "cache_vof", cache_vof))
			`uvm_fatal("[CACHE_MONITOR]", "Unable to get cache response interface")
	endfunction : build_phase


	virtual task main_phase(uvm_phase phase);
		super.main_phase(phase);
		fork
			begin // thread to sample input interface
				forever begin
					@(posedge cache_vif.clk);
					cache_inp_tx.address = cache_vif.address;
					cache_inp_tx.wr_cmd = cache_vif.write_addr;
					cache_inp_tx.rd_cmd = cache_vif.read_addr;
					cache_inp_tx.data = cache_vif.write_data;
					cache_inp_port.write(cache_inp_tx);
					@(posedge cache_vif.clk);
				end
			end
			begin // thread to sample output interface
				forever begin
					@(posedge cache_vof.clk);
					cache_rsp_tx.hit = cache_vof.hit;
					cache_rsp_tx.miss = cache_vof.miss;
					cache_rsp_tx.data_valid = cache_vof.valid_data;
					cache_rsp_tx.data_out = cache_vof.o_data;
					cache_rsp_port.write(cache_rsp_tx);
					@(posedge cache_vof.clk);
				end
			end
		join
	endtask : main_phase


endclass : cache_monitor

