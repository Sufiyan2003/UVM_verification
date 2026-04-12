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
	`include "cache_req_seq.sv"
	`include "cache_driver.sv"
	`include "cache_monitor.sv"
	`include "cache_agent.sv"
	`include "cache_env.sv"
	`include "cache_base_test.sv"
	// scoreboard
endpackage : cache_pkg