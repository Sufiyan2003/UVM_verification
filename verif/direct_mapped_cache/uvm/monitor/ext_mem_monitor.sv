/**
 * Author: Muhammad Sufiyan Sadiq
 * Date: 15_04_2026
 * Description: This is present to monitor what random data
 * the external memory sends it, this is to later send 
 * transaction to the scoreboard
 * */


class ext_mem_monitor extends uvm_component;
	`uvm_component_utils(ext_mem_monitor)

	virtual cache_mem_if#(32,32) cache_mem_vif;

	cache_mem_rsp mem_tx;

	uvm_analysis_port #(cache_mem_rsp) mem_rsp_port;

	function new(string name="ext_mem_monitor", uvm_component parent);
		super.new(name, parent);
		mem_rsp_port = new("mem_rsp_port", this);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(virtual cache_mem_if #(32,32))::get(this, "", "mem_vif", cache_mem_vif))
			`uvm_fatal("[EXT_MEM_MONITOR]", "Unable to get memory interface")
	endfunction


	virtual task main_phase(uvm_phase phase);
		super.main_phase(phase);
		forever begin
			mem_tx = cache_mem_rsp::type_id::create("mem_tx");
			@(posedge cache_mem_vif.mem_ready);
			mem_tx.address 		= cache_mem_vif.address;
			mem_tx.mem_data 	= cache_mem_vif.mem_data;
			mem_tx.req 			= cache_mem_vif.req;
			mem_tx.mem_ready 	= cache_mem_vif.mem_ready;
			mem_tx.display_rsp();
			`uvm_info("ext_mem_monitor", "Miss response sent to scoreboard", UVM_LOW)
			mem_rsp_port.write(mem_tx);
		end
	endtask : main_phase


endclass
