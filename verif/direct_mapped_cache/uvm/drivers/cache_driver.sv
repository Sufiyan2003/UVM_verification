/*------------------------------------------------------------------------------
-- Author: Muhamamd Sufiyan Sadiq 
--  Date: 07_04_2026
--  
--  
------------------------------------------------------------------------------*/


class cache_driver extends uvm_driver #(cache_tx);
	`uvm_component_utils(cache_driver)

	virtual cache_if #(32,32) cache_vif;
	cache_tx cache_inp_tx;


	function new(string name="cache_driver", uvm_component parent);
		super.new(name, parent);
		cache_inp_tx = new();
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
	endfunction : build_phase


	virtual task main_phase(uvm_phase phase);
		super.main_phase(phase);
		forever begin
			// driver the interface
			seq_item_port.get_next_item(cache_inp_tx);
			// randomize the transaction here
			@(posedge cache_vif.clk);
			
			@(posedge cache_vif.clk);
			seq_item_port.item_done();
		end
		
	endtask : main_phase

endclass : cache_driver

