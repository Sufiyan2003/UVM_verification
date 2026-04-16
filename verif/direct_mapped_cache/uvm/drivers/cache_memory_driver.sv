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
		    @(posedge mem_vif.clk);

		    if (mem_vif.req) begin
		        `uvm_info("[cache_memory_driver]", "cache needs line", UVM_LOW)

		        `ifdef MAIN_MEMORY
		            cycle_wait = $urandom_range(20,50);
		        `else 
		            cycle_wait = $urandom_range(8,20);
		        `endif

		        for (int i = 0; i < cycle_wait; i++) begin
		            @(posedge mem_vif.clk);
		        end

		        cache_miss_rsp.generate_random_data();

		        @(posedge mem_vif.clk)
		        mem_vif.mem_ready <= cache_miss_rsp.mem_ready;
		        mem_vif.mem_data  <= cache_miss_rsp.mem_data;

		        @(posedge mem_vif.clk)
		        mem_vif.mem_ready <= 1'b0;
		        wait(mem_vif.req == 0);
		    end
		end
		
	endtask : main_phase


endclass : cache_memory_driver

