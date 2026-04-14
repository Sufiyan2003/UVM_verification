/*------------------------------------------------------------------------------
--  Author: Muhammad Sufiyan Sadiq
--  Date: 07_04_2026
--  Description: This sequence item contains address commands
------------------------------------------------------------------------------*/


// this class contains the inputs to the cache
class cache_tx extends uvm_sequence_item;
    `uvm_object_utils(cache_tx)

    rand bit [31:0] address;  // 31:0 is clearer than 32-1:0
    rand bit        rd_en;
    rand bit        wr_en;
    rand bit [31:0] wr_data;

    function new(string name="cache_tx");
        super.new(name);
    endfunction : new

   function void randomize_tr();
        address = $urandom();
   	    rd_en = $urandom();
        wr_en = $urandom();
        wr_data = $urandom();
   endfunction : randomize_tr

endclass : cache_tx


// this is the cache response taken from the cache dut
class cache_rsp extends uvm_sequence_item;
    `uvm_object_utils(cache_rsp)

    bit         hit     ;
    bit         miss    ;
    bit [7:0]   o_data  ;
    bit         o_valid ;

    function new(string name="cache_rsp");
        super.new(name);
    endfunction

endclass


class cache_mem_rsp extends uvm_sequence_item;
    `uvm_object_utils(cache_mem_rsp)
    
    rand bit [31:0]     mem_data    ;
    bit      [31:0]     address     ;
    bit                 req         ;
    bit                 mem_ready   ;

    function new(string name="cache_mem_rsp");
        super.new(name);
    endfunction

    function void generate_random_data();
        mem_ready = 1'b1;
        mem_data = $urandom();
    endfunction : generate_random_data
endclass

