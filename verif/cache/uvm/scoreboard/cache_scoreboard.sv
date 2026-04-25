/**
 * Name: Muhammad Sufiyan Sadiq
 * Date: 16_04_2026
 * Description: This is to see if the dut is correctly
 * managing the transactions and operation correctly
 * 
 * */


`uvm_analysis_imp_decl(_cache_in)
`uvm_analysis_imp_decl(_cache_out)
`uvm_analysis_imp_decl(_mem_fill)

class cache_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(cache_scoreboard)

	// analysis implementation port
	uvm_analysis_imp_cache_in  #(cache_tx, cache_scoreboard) 		cache_in_port;
	uvm_analysis_imp_cache_out #(cache_rsp, cache_scoreboard) 		cache_out_port;
	uvm_analysis_imp_mem_fill  #(cache_mem_rsp, cache_scoreboard) 	mem_fill_port;

	// queues to store the transaction
	cache_tx 	  cache_input_q [$];
	cache_rsp 	  cache_output_q[$];
	cache_mem_rsp cache_fill_q  [$];

	cache_line 		temp_line		;
	cache_rsp 		tx_out			;
	cache_mem_rsp 	ext_mem_resp	;
	cache_tx 		tx_in			;

	// associative array to model an actual cache
	cache_line model_cache[int];

	function new(string name="cache_scoreboard", uvm_component parent);
		super.new(name,parent);
		cache_in_port	= new("cache_in_port" , this);
		cache_out_port 	= new("cache_out_port", this);
		mem_fill_port 	= new("mem_fill_port" , this);
		tx_out			= new();
		ext_mem_resp	= new();
		tx_in			= new();
	endfunction : new


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction


	virtual task main_phase(uvm_phase phase);
		super.main_phase(phase);
	
		
		forever begin
			// wait for the stimulus to arrive
			wait(cache_input_q.size() > 0);
			tx_in = cache_input_q.pop_front();
			if(tx_in.wr_en) begin
				// update the cache reference model on a write
				// TODO: must check for miss here as well
				if(check_hit(tx_in.address)) begin
					temp_line.tag = tx_in.address[31:4];
					temp_line.data = tx_in.wr_data;
					temp_line.valid = 1'b1;
					temp_line.dirty = 1'b0; // later change it to 1 if external 
					model_cache[tx_in.address[3:0]] = temp_line;
				end
				else begin
					// wait for mem interfaces
					wait(cache_fill_q.size() > 0);
					ext_mem_resp = cache_fill_q.pop_front();
					temp_line.tag = ext_mem_resp.address[31:4];
					temp_line.data = ext_mem_resp.mem_data;
					temp_line.dirty = 1'b0;
					temp_line.valid = 1'b1;
					// update the reference model here
					model_cache[tx_in.address[3:0]] = temp_line;
				end

			end
			else begin
				// check if its a hit or a miss
				if(check_hit(tx_in.address)) begin
					// if it hit dequeu the output queue on the next clock edge, it should have the data
					wait(cache_output_q.size() > 0);
					tx_out = cache_output_q.pop_front();
					if(tx_out.o_data != fetch_line(tx_in.address)) begin
						`uvm_error("cache_scoreboard", "Wrong data stored in the line")
						`uvm_info("cache_scoreboard", "==========EXPECTED DATA==========",UVM_LOW)
						`uvm_info("cache_scoreboard",$sformatf("Data: %0h",fetch_line(tx_in.address)) ,UVM_LOW)
						`uvm_info("cache_scoreboard", "=================================",UVM_LOW)
						`uvm_info("cache_scoreboard", "===========ACTUAL DATA===========",UVM_LOW)
						`uvm_info("cache_scoreboard",$sformatf("Data: %0h",tx_out.o_data) ,UVM_LOW)
						`uvm_info("cache_scoreboard", "=================================",UVM_LOW)
					end
					else begin
						`uvm_info("cache_scoreboard","Data has matched!",UVM_LOW)
					end
				end
				else begin
					// if it didnt hit then we are going to have to wait for mem interface
					wait(cache_fill_q.size() >0);
					ext_mem_resp = cache_fill_q.pop_front();							
					wait(cache_output_q.size() >0 );
					tx_out = cache_output_q.pop_front();

					// write it into the model as well
					temp_line.tag = ext_mem_resp.address[31:4];
					temp_line.data = ext_mem_resp.mem_data;
					temp_line.dirty = 1'b0; // hardcoded for now
					temp_line.valid =  1'b1;
					model_cache[ext_mem_resp.address[3:0]] = temp_line; 
					if(tx_out.o_data != ext_mem_resp.mem_data) begin
						`uvm_error("cache_scoreboard", "Data not forwarded correctly by cache")
						`uvm_info("cache_scoreboard", "==========EXPECTED DATA==========",UVM_LOW)
						`uvm_info("cache_scoreboard",$sformatf("Data: %0h",ext_mem_resp.mem_data) ,UVM_LOW)
						`uvm_info("cache_scoreboard", "=================================",UVM_LOW)
						`uvm_info("cache_scoreboard", "===========ACTUAL DATA===========",UVM_LOW)
						`uvm_info("cache_scoreboard",$sformatf("Data: %0h",tx_out.o_data) ,UVM_LOW)
						`uvm_info("cache_scoreboard", "=================================",UVM_LOW)
					end
					else begin
						`uvm_info("cache_scoreboard","Data from external memory matches the output!",UVM_LOW)
					end


				end
			end
		end
	endtask : main_phase


	// check if the given address is present in our reference model
	function bit check_hit(bit [31:0] address);
		bit [27:0] temp_tag;
		cache_line fetched_line;

		temp_tag = address[31:4];
		fetched_line = model_cache[address[3:0]];
		if(fetched_line.tag == address[31:4])
			return 1;
		else
			return 0;
	endfunction

	// function to grab the data stored in a particular line
	function bit [31:0] fetch_line(bit [31:0] address);
		cache_line output_line;
		output_line = model_cache[address[3:0]];
		return output_line.data;
	endfunction : fetch_line


	// functions to push transactions into the scoreboard queues
	function write_cache_in(cache_tx tx_in);
		cache_input_q.push_back(tx_in);
	endfunction

	function write_cache_out(cache_rsp tx_out);
		cache_output_q.push_back(tx_out);
	endfunction

	function write_mem_fill(cache_mem_rsp mem_rsp);
		cache_fill_q.push_back(mem_rsp);
	endfunction
endclass : cache_scoreboard

