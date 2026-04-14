`timescale 1ns/1ps

module dm_cache_tb;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	// include package here
	import cache_pkg::*;

	logic clk;
	logic resetn;
	// include rtl connection file here

	parameter LINE_WIDTH=32;
	parameter ADDR_WIDTH = 32;
	parameter DEPTH =16;

	cache_rd_port #(ADDR_WIDTH,LINE_WIDTH) rd_port(clk, resetn);
	cache_wr_port #(LINE_WIDTH)            wr_port(clk,resetn);

	// instantiate interface
	cache_if #(32,32) cache_vif(clk, resetn);
	cache_of #(32)    cache_vof(clk, resetn);

	// instantiate config
	cache_config cache_cfg;




	// instantiate dut
	cache_top #(ADDR_WIDTH, LINE_WIDTH, DEPTH) direct_mapped_cache
	(
		.clk           (clk),    // Clock
		.rst_n         (resetn),    // Asynchronous reset active low
		.wr_port       (wr_port),
		.rd_port       (rd_port)
	);

	// initialize signal values
	initial begin
		clk = 0;
		resetn = 1'b1;
		uvm_config_db#(virtual cache_wr_port#(LINE_WIDTH))::set(null, "*", "wr_vif", wr_port);
    	uvm_config_db#(virtual cache_rd_port#(ADDR_WIDTH,LINE_WIDTH))::set(null, "*", "rd_vif", rd_port);

    	cache_cfg = cache_config::type_id::create("cache_cfg", null);
    	uvm_config_db#(cache_config)::set(null, "*", "cache_cfg", cache_cfg);	
    	cache_cfg.cache_depth = 16;
	end

	// drive resetn
	initial begin
		resetn = 1'b1;
		#10ns;
		resetn = 1'b0;
		#10ns;
		resetn = 1'b1;
		#9000ns;
	end

	// simulation starts after 20ns
	initial begin
		run_test();
	end

	initial begin
		$display("LINE_WIDTH=%0d",LINE_WIDTH);
		$display("ADDR_WIDTH=%0d",ADDR_WIDTH);
		$display("DEPTH=%0d",DEPTH);
	end



	// generate clk
	always #(5ns) clk = ~clk;

endmodule : dm_cache_tb