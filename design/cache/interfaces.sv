// read port
interface cache_rd_port #(ADDR_WIDTH=32, LINE_WIDTH=32) (input clk, input rst_n);
	logic [ADDR_WIDTH-1:0] address       ;
	logic                  rd_addr       ;

endinterface

// write port
interface cache_wr_port #(LINE_WIDTH=32) (input clk, input rst_n);
	logic [LINE_WIDTH-1:0]  wr_data;
	logic                  wr_data_valid;
	logic                  hit           ;
	logic                  miss          ;
	logic [7:0]            o_data        ;
	logic                  rd_data_valid ;

	
endinterface : cache_wr_port