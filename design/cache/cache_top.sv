/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  This is an attempt to create a cache top module , the following module is
--  a direct mapped cache
--  Date: 06_04_2026
------------------------------------------------------------------------------*/


module cache_top 
#(
	parameter ADDR_WIDTH=32,
	parameter LINE_WIDTH=32,
	parameter DEPTH=16
)(
	
	input                                   clk           ,    	// Clock
	input                                   rst_n         ,    	// Asynchronous reset active low
	cache_inp_if                            inp_port      ,
	cache_out_if                            out_port	  ,
	cache_mem_if							mem_port			// This is to fill the cache in case of a miss
);

	localparam NO_BLOCK_BITS = $clog2(LINE_WIDTH/8)							;
	localparam NO_LINE_BITS  = $clog2(DEPTH)								;
	localparam NO_TAG_BITS   = ADDR_WIDTH - NO_LINE_BITS - NO_BLOCK_BITS	;

	// declare valids , tags, data, byte offset
	logic                         valid_array[DEPTH]						;
	logic                         dirty_array[DEPTH]						;
	logic [NO_TAG_BITS - 1 : 0]   tag_array[DEPTH]							;
	logic [LINE_WIDTH-1:0]        mem_array[DEPTH]							;


	logic [NO_BLOCK_BITS-1:0]                          	block_offset		;
	logic [NO_LINE_BITS+NO_BLOCK_BITS-1:NO_BLOCK_BITS] 	line_number			;
	logic [ADDR_WIDTH-1 : NO_LINE_BITS+NO_BLOCK_BITS]  	tag_value			;

	logic [NO_BLOCK_BITS-1:0]                          	new_block_offset		;
	logic [NO_LINE_BITS+NO_BLOCK_BITS-1:NO_BLOCK_BITS] 	new_line_number			;
	logic [ADDR_WIDTH-1 : NO_LINE_BITS+NO_BLOCK_BITS]  	new_tag_value			;



	logic 											   	hit_1				;
	logic 											   	miss_1				;
	logic 											   	clear_miss			;
	logic 												cache_hit			;

	logic                  miss_pending		;
	logic [ADDR_WIDTH-1:0] miss_addr		;

	// decode the information from the i_address
	assign block_offset             = inp_port.address[NO_BLOCK_BITS-1:0];
	assign line_number              = inp_port.address[NO_LINE_BITS+NO_BLOCK_BITS-1:NO_BLOCK_BITS];
	assign tag_value                = inp_port.address[ADDR_WIDTH-1 : NO_LINE_BITS+NO_BLOCK_BITS];
	assign cache_hit                = valid_array[line_number] && (tag_array[line_number] == tag_value);

	assign new_block_offset     = mem_port.address[NO_BLOCK_BITS-1:0];
	assign new_line_number      = mem_port.address[NO_LINE_BITS+NO_BLOCK_BITS-1:NO_BLOCK_BITS];
	assign new_tag_value        = mem_port.address[ADDR_WIDTH-1:NO_LINE_BITS+NO_BLOCK_BITS];

	// block to determine hit or miss and on hit just put data on the bus
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			out_port.o_valid 	  <= 'h0;
		end
		else begin
			if(cache_hit && inp_port.rd_en && miss_pending) begin
				out_port.o_valid <= 1;
				out_port.o_data <= mem_array[line_number];
			end
			else if(miss_pending && mem_port.mem_ready) begin
				out_port.o_valid <= 1'b1;
				out_port.o_data <= mem_port.mem_data;
			end
			else begin
				out_port.o_data <= 0;
			end
		end
	end

	// block  to manage write
	always_ff @(posedge clk or negedge rst_n) begin : proc_write
		if(~rst_n) begin
			for(int i =0 ;i < DEPTH; i++) begin
				valid_array[i] <= 'h0;
				tag_array[i]   <= 'h0;
				mem_array[i]   <= 'h0;
			end
		end else begin
			if(inp_port.wr_en && !out_port.miss) begin
				tag_array[line_number]   <= tag_value;
				valid_array[line_number] <= 1'b1;
				mem_array[line_number]   <= inp_port.wr_data;
			end
			else if(mem_port.req && mem_port.mem_ready) begin
				tag_array[new_line_number] <= new_tag_value;
				valid_array[new_line_number] <= 1'b1;
				mem_array[new_line_number] <= mem_port.mem_data;

			end
		end
	end


	// to manage requesting from external memory
	always_ff @(posedge clk or negedge rst_n) begin : proc_manage_fill
		if(~rst_n) begin
			miss_pending <= 1'b0;
			mem_port.req <= 1'b0;
		end else begin
			if(inp_port.rd_en && !cache_hit && !miss_pending) begin
				miss_pending <= 1'b1;
				miss_addr <= inp_port.address;
				mem_port.req <= 1'b1;
				mem_port.address <= inp_port.address;
			end
			else if(miss_pending && mem_port.mem_ready) begin
				miss_pending <= 1'b0;
				mem_port.req <= 1'b0;
			end
		end
	end

	// to identify the dirty bit
	// logic is broken, simply overwrites if line is hit again
	// not checking if dirty is set and evicts the line completely
	always_ff @(posedge clk or negedge rst_n) begin : proc_dirty
		if(~rst_n) begin
			for (int i = 0; i < DEPTH; i++) begin
				dirty_array[i] <= 'h0;
			end
		end else begin
			if (out_port.o_valid && cache_hit) begin
				dirty_array[line_number] <= 1'b1;
			end
		end
	end



	assign out_port.hit  = hit_1;
	assign out_port.miss = miss_pending;


endmodule : cache_top



