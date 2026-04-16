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
	virtual cache_inp_if #(32,32) inp_port;

	function new(string name="cache_driver", uvm_component parent);
		super.new(name, parent);
		cache_inp_tx = new();
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual cache_inp_if#(32,32))::get(this, "", "inp_vif", inp_port))
			`uvm_fatal("[CACHE_DRIVER]", "Cannot get cache input port")
		
	endfunction : build_phase


	virtual task main_phase(uvm_phase phase);
		super.main_phase(phase);
		forever begin
			// drive the interface

			// wait till o_stall is deasserted
			do begin
				@(posedge inp_port.clk);
			end while(inp_port.o_stall);

			// when cache comes out of stall write again to the cache
			seq_item_port.get_next_item(cache_inp_tx);
			`uvm_info("[CACHE_DRIVER]", "Actually driving the interface", UVM_LOW)
			// randomize the transaction here
			seq_item_port.item_done();
			$display("Driving=%0h",cache_inp_tx.address);
			@(posedge inp_port.clk);
			inp_port.address <= cache_inp_tx.address;
			inp_port.rd_en <= cache_inp_tx.rd_en;
			inp_port.wr_data <= cache_inp_tx.wr_data;
			inp_port.wr_en   <= cache_inp_tx.wr_en;
			// @(posedge inp_port.clk);
		end
		
	endtask : main_phase

endclass : cache_driver

