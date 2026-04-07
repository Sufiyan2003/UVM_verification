`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

// include package here
import cache_pkg::*;





module dm_cache_tb();
	logic clk;
	logic resetn;
	// include rtl connection file here



	// instantiate interface
	cache_if #(32,32) cache_vif(clk, resetn);
	cache_of #(32)    cache_vof(clk, resetn);

	// instantiate dut
	cache_top direct_mapped_cache
	(
	.clk           (clk),    // Clock
	.rst_n         (resetn),    // Asynchronous reset active low
	.i_address     (cache_vif.address),    // input address

	.i_fetch_addr  (cache_vif.read_addr),    // check if address is present 
	.i_wr_data     (cache_vif.write_data),    // this is to write data 
	.i_put_data    (cache_vif.write_addr),    // to write into the cache
	.o_data        (cache_vof.o_data),    // byte data out (on hit)

	.o_data_valid  (cache_vof.valid_data),    // data on the output bus is from the cache
	.o_hit         (cache_vof.hit),    // address present in cache
	.o_miss        (cache_vof.miss)     // address not present in cache (fetch from some


	);

	// initialize signal values
	initial begin
		clk = 0;
		resetn = 1'b1;
	end

	// drive resetn
	initial begin
		#10ns;
		resetn = 1'b0;
		#10ns;
		resetn = 1'b1;
	end

	// generate clk
	always #(5ns) clk = ~clk;

endmodule : dm_cache_tb