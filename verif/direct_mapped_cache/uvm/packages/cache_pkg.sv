/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 07_04_2026
--  Description: This is the package used to verify our cache
------------------------------------------------------------------------------*/

package cache_pkg;
	import uvm_pkg::*;
 	`include "uvm_macros.svh"
  // Include all files in the CORRECT order
  	`include "cache_config.sv"
	`include "cache_tx.sv"

	/** Sequences*/
	`include "cache_req_seq.sv"
	`include "cache_hit_seq.sv"

	`include "cache_driver.sv"
	// `include "cache_write_driver.sv" // need to change this driver this is just bad 
	
	`include "cache_monitor.sv"
	`include "cache_agent.sv"
	`include "cache_env.sv"
	// scoreboard

	/**TESTS */
	`include "cache_base_test.sv"
	`include "cache_hit_test.sv"
endpackage : cache_pkg