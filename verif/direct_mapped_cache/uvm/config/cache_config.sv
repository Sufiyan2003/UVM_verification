/*------------------------------------------------------------------------------
--  Author: Muhamamd Sufiyan Sadiq 
--  Date: 12_04_2026
--  Description: This contains the cache config
------------------------------------------------------------------------------*/


class cache_config extends uvm_component;
	`uvm_component_utils(cache_config)

	uvm_cmdline_processor clp;
	int num_rd_cmds;
	bit hit_test;
	string tmp;

	function new(string name="cache_config", uvm_component parent);
		super.new(name,parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		clp = uvm_cmdline_processor::get_inst();

		// get the run time arguments
		if(clp.get_arg_value("+num_rd_cmds=", tmp)) num_rd_cmds = tmp.atoi();
		if(clp.get_arg_value("+hit_test=", tmp)) hit_test = tmp.atobin();


	endfunction : build_phase



endclass
