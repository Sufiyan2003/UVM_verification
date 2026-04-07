/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 07_04_2026
--  Description: These are the cache interfaces
------------------------------------------------------------------------------*/

// this is the cache input interface
interface cache_if #(ADDR_WIDTH=32, LINE_WIDTH=32) (input clk, input rst_n);
	logic [ADDR_WIDTH-1:0] address;
	logic                  read_addr;
	logic [LINE_WIDTH-1:0] write_data;
	logic                  write_addr;
endinterface : cache_if


// this is the cache output interface
interface cache_of #(LINE_WIDTH=32) (input clk, input rst_n);
	logic [LINE_WIDTH-1:0] o_data;
	logic                  valid_data;
	logic                  hit;
	logic                  miss;
endinterface
