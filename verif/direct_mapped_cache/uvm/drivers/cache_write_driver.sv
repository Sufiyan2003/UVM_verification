/*------------------------------------------------------------------------------
-- Author: Muhamamd Sufiyan Sadiq 
--  Date: 07_04_2026
--  
--  This driver is present to fulfill a missed request into the cache
------------------------------------------------------------------------------*/

`uvm_analysis_imp_decl(_missed_trans);
class cache_write_driver extends uvm_driver #(cache_rsp);
	`uvm_component_utils(cache_write_driver)

	cache_rsp cache_rsp_tx;
	virtual cache_wr_port #(32) wr_port;
	bit [31:0] outstanding_tx[$];    // the number of requests that have been missed and await writing
	cache_tx missed_addr;

	uvm_analysis_imp_missed_trans #(cache_tx, cache_write_driver) missed_imp;

	function new(string name="cache_write_driver", uvm_component parent);
		super.new(name, parent);
		cache_rsp_tx = new();
		missed_imp = new("missed_imp", this);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual cache_wr_port#(32))::get(this, "", "wr_vif", wr_port))
			`uvm_fatal("[cache_write_driver]", "Cannot get wr_vif")
		
	endfunction : build_phase


	virtual task main_phase(uvm_phase phase);
		super.main_phase(phase);
		forever begin
			wait(outstanding_tx.size() > 0);
			// to sequentially fulfill address fetching (for now)
			missed_addr = outstanding_tx.pop_front();
			// driver the interface
			seq_item_port.get_next_item(cache_rsp_tx);
			`uvm_info("[cache_write_driver]", "Actually driving the interface", UVM_LOW)
			// randomize the transaction here
			$display("Driving=%0h",cache_rsp_tx.address);
			@(posedge wr_port.clk);
			wr_port.wr_data_valid <= 1'b1;
			wr_port.wr_data <= missed_addr.address;
			@(posedge wr_port.clk);
			wr_port.wr_data_valid <= 1'b0;
			seq_item_port.item_done();
		end
		
	endtask : main_phase

	// push the missed transaction into a queue
	function write_missed_trans(cache_tx tx);
		outstanding_tx.push_back(tx.address);
	endfunction


endclass : cache_write_driver

