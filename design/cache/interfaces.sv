// read port
interface cache_inp_if #(ADDR_WIDTH=32, LINE_WIDTH=32) (input clk, input rst_n);
	logic [ADDR_WIDTH-1:0] 			  address       ;
	logic                  			  rd_en         ; 
	logic [LINE_WIDTH-1:0] 			  wr_data       ;
	logic 				   			  wr_en 		;  
	// add wr_en here 
endinterface

// write port
interface cache_out_if #(LINE_WIDTH=32) (input clk, input rst_n);
	logic              				  hit           ;
	logic                  			  miss          ;
	logic [LINE_WIDTH-1:0]            o_data        ;
	logic                  			  o_valid		;
endinterface : cache_out_if

// memory interface
interface cache_mem_if#(ADDR_WIDTH=32,LINE_WIDTH=32) (input clk, input rst_n);
	logic [ADDR_WIDTH-1:0] address					;
	logic 				   req 						;	// this is to request a line for that address
	logic 				   mem_ready				; 	// memory has line on the bus
	logic [LINE_WIDTH-1:0] mem_data					;

endinterface