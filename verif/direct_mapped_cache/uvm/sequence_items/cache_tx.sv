/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 07_04_2026
--  Description: This sequence item contains address commands
------------------------------------------------------------------------------*/


// this class contains the inputs to the cache
class cache_tx extends uvm_sequence_item;
    `uvm_object_utils(cache_tx)

    rand bit [31:0] address;  // 31:0 is clearer than 32-1:0
    rand bit rd_cmd;

    function new(string name="cache_tx");
        super.new(name);
    endfunction : new

   function void randomize_tr();
   	address = $urandom();
   	rd_cmd = $urandom();
   endfunction : randomize_tr

endclass : cache_tx


// this is the cache response taken from the cache dut
class cache_rsp extends uvm_sequence_item;
    `uvm_object_utils(cache_rsp)
    
    rand bit [31:0] wr_data;     // Made rand if you want to randomize
    bit wr_data_valid;
    bit hit;
    bit miss;
    bit [7:0] o_data;
    bit rd_data_valid;

    function new(string name="cache_rsp");
        super.new(name);
    endfunction

endclass