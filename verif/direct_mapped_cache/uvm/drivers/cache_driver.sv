/*------------------------------------------------------------------------------
-- Author: Muhamamd Sufiyan Sadiq 
--  Date: 07_04_2026
--  
--  This agent is used to drive the rd port of the cache, to request a line from
--  a cache
------------------------------------------------------------------------------*/


class cache_driver extends uvm_driver #(cache_tx);
	`uvm_component_utils(cache_driver)

	cache_tx cache_inp_tx;
	virtual cache_rd_port #(32,32) rd_port;

	function new(string name="cache_driver", uvm_component parent);
		super.new(name, parent);
		cache_inp_tx = new();
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual cache_rd_port#(32,32))::get(this, "", "rd_vif", rd_port))
			`uvm_fatal("[CACHE_DRIVER]", "Cannot get rd_vif")
		
	endfunction : build_phase


	virtual task main_phase(uvm_phase phase);
		super.main_phase(phase);
		forever begin
			// driver the interface
			seq_item_port.get_next_item(cache_inp_tx);
			`uvm_info("[CACHE_DRIVER]", "Actually driving the interface", UVM_LOW)
			// randomize the transaction here
			$display("Driving=%0h",cache_inp_tx.address);
			@(posedge rd_port.clk);
			rd_port.address <= cache_inp_tx.address;
			rd_port.rd_addr <= cache_inp_tx.rd_cmd;
			@(posedge rd_port.clk);
			seq_item_port.item_done();
		end
		
	endtask : main_phase

endclass : cache_driver

