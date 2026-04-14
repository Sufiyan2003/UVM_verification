/*------------------------------------------------------------------------------
-- Author: Muhamamd Sufiyan Sadiq 
--  Date: 07_04_2026
--  
--  This driver is basically a memory model which plays the role of a L2 cache
--	or main memory to fill lines with the cache in case of a miss
------------------------------------------------------------------------------*/


class cache_memory_driver extends uvm_driver #(cache_mem_rsp);
	`uvm_component_utils(cache_memory_driver)

	cache_mem_rsp cache_miss_rsp;
	virtual cache_mem_if #(32,32) mem_vif;
	int cycle_wait;


	function new(string name="cache_memory_driver", uvm_component parent);
		super.new(name, parent);
		cache_miss_rsp = new();

	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual cache_mem_if#(32,32))::get(this, "", "mem_vif", mem_vif))
			`uvm_fatal("[cache_memory_driver]", "Cannot get mem_vif")
		
	endfunction : build_phase


	virtual task main_phase(uvm_phase phase);
		super.main_phase(phase);
		forever begin
			// driver the interface
			seq_item_port.get_next_item(cache_miss_rsp);
			// memory model is main memory wait 50 - 100 clock cycles, else its L2 wait 8-20
			`ifdef MAIN_MEMORY
				cycle_wait = $urandom_range(20,50);
			`else 
				// is L2 cache wait is less
				cycle_wait = $urandom_range(8,20);
			`endif
			
			`uvm_info("[cache_memory_driver]", "Memory Model is waiting for a cache miss", UVM_MEDIUM)
			// randomize the randomized fill data here
			for (int i = 0; i < cycle_wait; i++) begin
				@(posedge mem_vif.clk);
			end
			cache_miss_rsp.generate_random_data();
			mem_vif.mem_ready <= cache_miss_rsp.mem_ready;
			mem_vif.mem_data  <= cache_miss_rsp.mem_data;
			seq_item_port.item_done();
		end
		
	endtask : main_phase


endclass : cache_memory_driver

