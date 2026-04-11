/*------------------------------------------------------------------------------
--  Author: Muhamamd Sufiyan Sadiq 
--  Date: 07_04_2026
--  Description: This is to send reads to the cache
------------------------------------------------------------------------------*/
import uvm_pkg::*;
`include "uvm_macros.svh"


class cache_req_seq extends uvm_sequence;
	`uvm_object_utils(cache_req_seq)
	
	cache_tx new_cache_tx;

	function new(string name="cache_req_seq");
		super.new(name);
		new_cache_tx = new();
	endfunction : new

	virtual task body();
		for(int i=0; i < 100; i++) begin
			new_cache_tx.randomize_tr();
			`uvm_do(new_cache_tx);
		end
	endtask : body


endclass : cache_req_seq

