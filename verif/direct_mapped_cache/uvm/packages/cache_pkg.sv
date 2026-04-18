/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 07_04_2026
--  Description: This is the package used to verify our cache
------------------------------------------------------------------------------*/

package cache_pkg;
	import uvm_pkg::*;
 	`include "uvm_macros.svh"

 	// import struct package
 	import cache_struct_pkg::*;


  	// Include all files in the CORRECT order
  	`include "cache_config.sv"
	`include "cache_tx.sv"

	/** Sequences*/
	`include "cache_req_seq.sv"
	`include "cache_hit_seq.sv"

	/** Drivers */
	`include "cache_driver.sv"
	`include "cache_memory_driver.sv"
	
	/** Monitors */
	`include "cache_monitor.sv"
	`include "ext_mem_monitor.sv"
	`include "cache_out_monitor.sv"
	
	/** Agents */
	`include "cache_agent.sv"
	`include "cache_responder_agent.sv"
	
	/** Scoreboards */
	`include "cache_scoreboard.sv"

	/** Environments */
	`include "cache_env.sv"

	/** Tests */
	`include "cache_base_test.sv"
	`include "cache_hit_test.sv"
endpackage : cache_pkg