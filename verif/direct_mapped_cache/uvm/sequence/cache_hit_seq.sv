/*------------------------------------------------------------------------------
--  Author: Muhamamd Sufiyan Sadiq 
--  Date: 07_04_2026
--  Description: This is to populate the cache initially with
------------------------------------------------------------------------------*/

class cache_hit_seq extends uvm_sequence;
	`uvm_object_utils(cache_hit_seq)
	
	cache_tx new_cache_tx;
	cache_config cache_cfg;
	int addr_q[$];

	function new(string name="cache_hit_seq");
		super.new(name);
		new_cache_tx = new();
		if(!uvm_config_db#(cache_config)::get(null, "", "cache_cfg", cache_cfg))
			`uvm_fatal("[REQ_SEQ]", "Failed to get the cache config")
	endfunction : new



	virtual task body();

		`uvm_info("[HIT_SEQ]", "cache hit sequence running", UVM_LOW)
		for(int i=0; i < cache_cfg.num_rd_cmds; i++) begin
			new_cache_tx.randomize_tr();
			start_item(new_cache_tx);
			if(addr_q.size() > 0) begin
				new_cache_tx.address = addr_q[$urandom_range(0,addr_q.size()-1)];
				new_cache_tx.rd_cmd = 1'b1;
				$display("Address is=%0h",new_cache_tx.address);
			end
			else begin
				`uvm_info("[HIT_SEQ]", "Sending transaction to driver", UVM_LOW)
				new_cache_tx.randomize_tr();
				addr_q.push_back(new_cache_tx.address);
				$display("Address is=%0h",new_cache_tx.address);
			end
			finish_item(new_cache_tx);

		end
	endtask : body


endclass : cache_hit_seq