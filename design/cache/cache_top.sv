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
	input                  clk           ,    // Clock
	input                  rst_n         ,    // Asynchronous reset active low
	input [ADDR_WIDTH-1:0] i_address     ,    // input address

	input                  i_fetch_addr  ,    // check if address is present 
	input [LINE_WIDTH-1:0] i_wr_data     ,    // this is to write data 
	input                  i_put_data    ,    // to write into the cache
	output logic [7:0]     o_data        ,    // byte data out (on hit)

	output logic           o_data_valid  ,    // data on the output bus is from the cache
	output logic           o_hit         ,    // address present in cache
	output logic           o_miss             // address not present in cache (fetch from somewhere)
);

	parameter NO_BLOCK_BITS = $clog2(LINE_WIDTH/8);
	parameter NO_LINE_BITS = $clog2(DEPTH);
	parameter NO_TAG_BITS = ADDR_WIDTH - NO_LINE_BITS - NO_BLOCK_BITS;

	// declare valids , tags, data, byte offset
	logic                         valid_array[DEPTH];
	logic                         dirty_array[DEPTH];
	logic [NO_TAG_BITS - 1 : 0]   tag_array[DEPTH];
	logic [LINE_WIDTH-1:0]        mem_array[DEPTH];


	logic [NO_BLOCK_BITS-1:0]                          block_offset;
	logic [NO_LINE_BITS+NO_BLOCK_BITS-1:NO_BLOCK_BITS] line_number;
	logic [ADDR_WIDTH-NO_LINE_BITS-NO_BLOCK_BITS-1 : NO_LINE_BITS+NO_BLOCK_BITS] tag_value;
	logic hit_1;
	logic miss_1;
	logic cache_hit;

	// decode the information from the i_address
	assign block_offset             = i_address[NO_BLOCK_BITS-1:0];
	assign line_number              = i_address[NO_LINE_BITS+NO_BLOCK_BITS-1:NO_BLOCK_BITS];
	assign tag_value                = i_address[ADDR_WIDTH-1 : NO_LINE_BITS+NO_BLOCK_BITS];
	assign cache_hit                = valid_array[line_number] && (tag_array[line_number] == tag_value);



	// block to determine hit or miss and on hit just put data on the bus
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			hit_1        <= 'h0;
			miss_1       <= 'h0;
			o_data       <= 'h0;
			o_data_valid <= 'h0;
		end else if(i_fetch_addr) begin
			if(cache_hit) begin
				hit_1        <= 1'b1;
				miss_1       <= 1'b0;

				// extract the 8bit data using the offset
				o_data       <= mem_array[line_number][block_offset*8 +: 8];
				o_data_valid <= 1'b1;
			end
			else begin
				hit_1        <= 1'b0;
				miss_1       <= 1'b1;
				o_data_valid <= 1'b0;
			end			
		end else begin
			hit_1        <= 0;
			miss_1       <= 0;
			o_data_valid <= 1'b0;
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
			if(i_put_data) begin
				tag_array[line_number]   <= tag_value;
				valid_array[line_number] <= 1'b1;
				mem_array[line_number]   <= i_wr_data;
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
			if (i_put_data && cache_hit) begin
				dirty_array[line_number] <= 1'b1;
			end
		end
	end



	assign o_hit  = hit_1;
	assign o_miss = miss_1;

endmodule : cache_top



