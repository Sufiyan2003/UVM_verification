/*------------------------------------------------------------------------------
--  Author: Muhamamd Sufiyan Sadiq 
--  Date: 07_04_2026
--  Description: This is to send write transactions
------------------------------------------------------------------------------*/


class cache_write_seq extends uvm_sequence_item #(cache_tx);
	`uvm_object_utils(cache_write_seq)
	cache_tx new_cache_tx;

	function new(string name="cache_write_seq");
		super.new(name);
		new_cache_tx = new();
	endfunction : new

	virtual task body();
		for(int i=0; i < num_wr_cmds; i++) begin
			new_cache_tx.randomize_tr();
			`uvm_do(new_cache_tx);
		end
	endtask : body


endclass : cache_write_seq

