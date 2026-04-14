/*------------------------------------------------------------------------------
--  Author: Muhamamd Sufiyan Sadiq 
--  Date: 07_04_2026
--  Description: This is to send reads to the cache
------------------------------------------------------------------------------*/

class cache_req_seq extends uvm_sequence;
	`uvm_object_utils(cache_req_seq)
	
	cache_tx new_cache_tx;
	int num_rd_cmds=100;
	cache_config cache_cfg;

	function new(string name="cache_req_seq");
		super.new(name);
		new_cache_tx = new();
		if(!uvm_config_db#(cache_config)::get(null, "", "cache_cfg", cache_cfg))
			`uvm_fatal("[REQ_SEQ]", "Failed to get the cache config")
	endfunction : new



	virtual task body();

		for(int i=0; i < cache_cfg.num_rd_cmds; i++) begin
			start_item(new_cache_tx);
			`uvm_info("[REQ_SEQ]", "Driving the interface", UVM_LOW)
			new_cache_tx.randomize_tr();
			finish_item(new_cache_tx);

		end
	endtask : body


endclass : cache_req_seq

