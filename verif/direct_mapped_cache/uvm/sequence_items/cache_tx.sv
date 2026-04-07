/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 07_04_2026
--  Description: This  sequence item contains address commands
------------------------------------------------------------------------------*/


// this class contains the inputs to the cache
class cache_tx extends uvm_sequence_item;
	`uvm_object_utils(cache_tx)

	rand bit [32-1:0] address;
	rand bit wr_cmd;
	rand bit rd_cmd;
	rand bit [32-1:0] data;

	function new(string name="cache_tx");
		super.new(name);
	endfunction : new


	// randomize_tr
	function void randomize_tr();
		address = $urandom();
		wr_cmd  = $urandom();
		rd_cmd  = $urandom();
		data    = $urandom();
	endfunction

endclass : cache_tx


// this is the cache response taken from the cache dut
class cache_rsp #(DATA_WIDTH=32) extends uvm_sequence_item;
	`uvm_object_utils(cache_rsp)

	bit hit;
	bit miss;
	bit data_valid;
	bit [DATA_WIDTH-1:0] data_out;

	function new(string name="cache_rsp");
		super.new(name);
	endfunction

endclass


