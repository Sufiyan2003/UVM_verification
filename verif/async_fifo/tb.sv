`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;


// ---------------- FIFO INTERFACE ----------------
interface fifo_intf#(parameter DSIZE=8);
  logic [DSIZE-1:0] rdata;      // Output data - data to be read
  logic wfull;                  // Write full signal
  logic rempty;                 // Read empty signal
  logic [DSIZE-1:0] wdata;      // Input data - data to be written
  logic winc, wclk, wrst_n;     // Write increment, write clock, write reset
  logic rinc, rclk, rrst_n;     // Read increment, read clock, read reset
endinterface : fifo_intf

interface fifo_read_intf#(parameter DSIZE=8);
  logic rinc,rclk,rrst_n;
  logic rempty;
  logic [DSIZE-1:0] rdata;
endinterface : fifo_read_intf

interface fifo_write_intf #(parameter DSIZE=8);
  logic winc, wclk, wrst_n;
  logic [DSIZE-1:0] wdata;
  logic wfull;
endinterface : fifo_write_intf




// ---------------- TRANSACTION ----------------
class my_txn extends uvm_sequence_item;
  bit [31:0] data;
  rand bit [31:0] wr_data;
  rand bit wr_inc;
  rand bit rd_inc;
  bit is_write;
  bit full;
  bit empty;
  bit fifo_full_test;

  `uvm_object_utils(my_txn)

  function new(string name = "my_txn");
    super.new(name);
    $value$plusargs("fifo_full_test=%b",fifo_full_test);
  endfunction


  function void randomize_tr();
    if(is_write) begin
      wr_data = $urandom();
      wr_inc = $urandom();
      $display("Randomizing write transaction");
      `uvm_info("[WRITE_SEQ]", $sformatf("wr_data: %0h, wr_inc=%0b",wr_data, wr_inc), UVM_LOW)
    end
    else begin
      rd_inc = (fifo_full_test) ? 0 : $urandom_range(0,1);
      $display("Randomizing read transaction");
      `uvm_info("[READ_SEQ]", $sformatf(" rd_inc=%0b", rd_inc), UVM_LOW)
    end
  endfunction

  function void display_transaction(bit is_write);
    if(is_write) begin
      $display("[WRITE TRANSACTION]");
      $display("wr_data: %0h",wr_data);
      $display("wr_inc: %0h",wr_inc);
      $display("full: %0h",full);
      $display("empty: %0h",empty);
    end
    else begin
      $display("[READ TRANSACTION]");
      $display("data: %0h",data);
      $display("rd_inc: %0h",rd_inc);
      $display("full: %0h",full);
      $display("empty: %0h",empty);
    end

  endfunction
endclass


class wr_fifo_txn extends uvm_sequence_item;
  bit [31:0] wr_data;
  bit wr_inc;


  `uvm_object_utils(wr_fifo_txn)

  function new(string name = "wr_fifo_txn");
    super.new(name);
  endfunction

  function void randomize_tx();
    wr_inc = $urandom_range(0,1);
    wr_data = $random();
  endfunction
endclass

class rd_fifo_txn extends uvm_sequence_item;
  bit rd_inc;
  

  `uvm_object_utils(rd_fifo_txn)

  function new(string name = "rd_fifo_txn");
    super.new(name);
  endfunction

  function void randomize_tx();
    rd_inc = $urandom_range(0,1);
  endfunction
endclass


// ---------------- SEQUENCE ----------------
class my_seq extends uvm_sequence #(my_txn);
  `uvm_object_utils(my_seq)
  bit is_write;
  int num_transactions;
  function new(string name = "my_seq");
    super.new(name);
    $value$plusargs("num_transactions=%d",num_transactions);
  endfunction

  task body();
    my_txn tx;
    for(int i =0; i < num_transactions; i++) begin
      tx = my_txn::type_id::create("tx");
      tx.is_write = is_write;
      // tx.randomize();
      tx.randomize_tr();
      tx.data = $urandom_range(0,255);
      `uvm_info("SEQ", $sformatf("Generated data = %0d", tx.data), UVM_HIGH)
      start_item(tx);
      finish_item(tx);
    end
  endtask
endclass

// ---------------- DRIVER ----------------
class my_driver extends uvm_driver #(my_txn);
  `uvm_component_utils(my_driver)

  virtual fifo_write_intf #(32) wr_vif;
  virtual fifo_read_intf  #(32) rd_vif;
  bit fifo_full_test;
  bit is_write;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $value$plusargs("fifo_full_test=%b",fifo_full_test);
    if(!uvm_config_db#(virtual fifo_write_intf#(32))::get(this, "", "wr_vif", wr_vif))
      `uvm_fatal("[DRIVER]", "Unable to get the fifo write interface!")

    if(!uvm_config_db#(virtual fifo_read_intf#(32))::get(this, "", "rd_vif", rd_vif))
      `uvm_fatal("[DRIVER]", "Unable to get the fifo read interface!")
  endfunction

  task run_phase(uvm_phase phase);
    my_txn tx;
    forever begin
      seq_item_port.get_next_item(tx);
      if(is_write && wr_vif.wrst_n) begin
        @(posedge wr_vif.wclk);
        wr_vif.wdata = tx.wr_data;
        wr_vif.winc = 1;
        @(posedge wr_vif.wclk);
        wr_vif.winc = 0;
      end
      else if(!is_write && rd_vif.rrst_n) begin
        @(posedge rd_vif.rclk);
        rd_vif.rinc = (fifo_full_test) ? 0 : tx.rd_inc;
        @(posedge rd_vif.rclk);
        rd_vif.rinc = 0;
      end
      `uvm_info("DRV", $sformatf("Driving data = %0d", tx.data), UVM_HIGH)
      seq_item_port.item_done();
    end
  endtask
endclass

// ---------------- MONITOR ----------------
class my_monitor extends uvm_component;
  `uvm_component_utils(my_monitor)

  virtual fifo_write_intf #(32) wr_vif;
  virtual fifo_read_intf  #(32) rd_vif;
  bit is_write;
  my_txn tx;

  // declare analysis ports
  uvm_analysis_port #(my_txn) write_analysis_port;
  uvm_analysis_port #(my_txn) read_analysis_port;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tx = my_txn::type_id::create("tx", this);
    write_analysis_port = new("write_analysis_port", this);
    read_analysis_port  = new("read_analysis_port", this);

    // fetching the interfaces
    if(!uvm_config_db#(virtual fifo_write_intf#(32))::get(this, "", "wr_vif", wr_vif))
      `uvm_fatal("[MONITOR]", "Unable to get the fifo write interface!")

    if(!uvm_config_db#(virtual fifo_read_intf#(32))::get(this, "", "rd_vif", rd_vif))
      `uvm_fatal("[MONITOR]", "Unable to get the fifo read interface!")
  endfunction


  task run_phase(uvm_phase phase);
    my_txn txn_local;

    forever begin
      if(is_write) begin
        @(posedge wr_vif.wclk);
        if(wr_vif.winc && !wr_vif.wfull) begin
          txn_local = my_txn::type_id::create("txn_local", this);
          txn_local.wr_data = wr_vif.wdata;
          txn_local.wr_inc = wr_vif.winc;
          txn_local.rd_inc = 0;
          txn_local.is_write = 1;
          txn_local.full = wr_vif.wfull;    
          write_analysis_port.write(txn_local);
          `uvm_info("MON", "Write transaction sent to scoreboard", UVM_HIGH)  
          @(posedge wr_vif.wclk);
        end
        
      end
      else begin
        @(posedge rd_vif.rclk);
        if(rd_vif.rinc && !rd_vif.rempty) begin
          txn_local = my_txn::type_id::create("txn_local", this);
          txn_local.data = rd_vif.rdata + 1;
          txn_local.rd_inc = rd_vif.rinc;
          txn_local.wr_inc = 0;
          txn_local.empty = rd_vif.rempty;
          txn_local.is_write = 0;    
          read_analysis_port.write(txn_local);
          `uvm_info("MON", "Read transaction sent to scoreboard", UVM_HIGH)  
          @(posedge rd_vif.rclk);
        end
        
      end
    end
  endtask
endclass

// ---------------- AGENT ----------------
class my_agent extends uvm_component;
  `uvm_component_utils(my_agent)

  my_driver drv;
  my_monitor mon;
  uvm_sequencer #(my_txn) seqr;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv  = my_driver::type_id::create("drv", this);
    mon  = my_monitor::type_id::create("mon", this);
    seqr = uvm_sequencer#(my_txn)::type_id::create("seqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass


// ----------------- Scoreboard --------
`uvm_analysis_imp_decl(_wr_trans);
`uvm_analysis_imp_decl(_rd_trans);
class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)

  // Analysis implementation port
  uvm_analysis_imp_wr_trans #(my_txn, my_scoreboard) write_imp;
  uvm_analysis_imp_rd_trans  #(my_txn, my_scoreboard) read_imp;

  int count;
  // make queues
  my_txn write_q[$];
  my_txn read_q[$];

  my_txn write_tr;
  my_txn read_tr;

  function new(string name="my_scoreboard", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    write_imp = new("write_imp", this);
    read_imp = new("read_imp", this);
  endfunction

  task run_phase(uvm_phase phase);
    // phase.raise_objection(this);
      fork
        begin
          forever begin
            wait(read_q.size() > 0);
            read_tr  = read_q.pop_front();
            write_tr = write_q.pop_front();
            if(read_tr.data != write_tr.wr_data) begin
              `uvm_info("[FIFO_SCB]", "READ DATA MISMATCH", UVM_LOW)
              `uvm_error("[FIFO_SCB]", $sformatf("Actual data: %0h, Expected data:%0h", read_tr.data, write_tr.wr_data))
            end
            // read_tr.display_transaction(0);  
          end
          // $display("scoreboard got a read tr=%0d", count);  
        end
        // begin
        //   forever begin
        //     wait(write_q.size() > 0);
        //     write_tr = write_q.pop_front();
        //     $display("write");  
        //   end
        // end
      join
    // phase.drop_objection(this);
  endtask

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    if(read_q.size() != 0) begin
      `uvm_error("[SCOREBOARD]", "read q size is not 0");
    end
  endfunction



  function write_wr_trans(my_txn tx);
    write_q.push_back(tx);
  endfunction

  function write_rd_trans(my_txn tx);
    read_q.push_back(tx);
  endfunction

endclass


// ---------------- ENV ----------------
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_agent agent;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = my_agent::type_id::create("agent", this);
  endfunction
endclass

// ---------------- TEST ----------------
class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  my_env env[2];
  my_scoreboard scb;

  function new(string name, uvm_component parent);
    super.new(name, parent);

  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scb = my_scoreboard::type_id::create("scb", this);
    for (int i = 0; i < 2; i++) begin
      /* code */
      env[i] = my_env::type_id::create($sformatf("env[%0d]",i), this);
    end
    // connection of agents to scoreboard
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    env[1].agent.mon.write_analysis_port.connect(scb.write_imp);
    env[0].agent.mon.read_analysis_port.connect(scb.read_imp);
  endfunction
  
  task run_phase(uvm_phase phase);
    my_seq seq[2];
    phase.raise_objection(this);
    // wait till after the reset.
    #1000ns;
    for (int i = 0; i < 2; i++) begin
      automatic int j = i;

      seq[j] = my_seq::type_id::create($sformatf("seq[%0d]", j));

      env[j].agent.drv.is_write = j;
      env[j].agent.mon.is_write = j;
      seq[j].is_write = j;

      fork
        // start the sequence only when this fifo_full_test is 0
        seq[j].start(env[j].agent.seqr);
      join_none
    end

    wait fork;  // wait for both sequences to finish

    #50;
    phase.drop_objection(this);
  endtask

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();  // 🔥 prints hierarchy
  endfunction
endclass

// ---------------- TOP ----------------
module tb;
    parameter DSIZE=32;
    parameter ASIZE=32;


    logic [DSIZE-1:0] rdata;       // Output data - data to be read
    logic wfull;                  // Write full signal
    logic rempty;                  // Read empty signal
    logic [DSIZE-1:0] wdata;        // Input data - data to be written
    logic winc, wclk, wrst_n;       // Write increment, write clock, write reset
    logic rinc, rclk, rrst_n;        // Read increment, read clock, read reset
    logic written;
    fifo_intf #(DSIZE) fifo_if();

    fifo_read_intf #(DSIZE) fifo_rd_if();
    fifo_write_intf#(DSIZE) fifo_wr_if();



  // Instantiate the Fifo module
  asynchronous_fifo #(ASIZE,DSIZE) dut
  (
    // read interface
    .data_out (fifo_rd_if.rdata),
    .empty(fifo_rd_if.rempty),
    .r_en  (fifo_rd_if.rinc),
    .rclk  (fifo_rd_if.rclk),
    .rrst_n(fifo_rd_if.rrst_n),
    // write interface
    .full (fifo_wr_if.wfull),
    .data_in (fifo_wr_if.wdata),
    .w_en  (fifo_wr_if.winc),
    .wclk  (fifo_wr_if.wclk),
    .wrst_n(fifo_wr_if.wrst_n)
  );


  initial begin
    uvm_config_db#(virtual fifo_write_intf#(DSIZE))::set(null, "*", "wr_vif", fifo_wr_if);
    uvm_config_db#(virtual fifo_read_intf#(DSIZE))::set(null, "*", "rd_vif", fifo_rd_if);
    run_test();
  end


  // initialize resets and clocks
  initial begin
    fifo_wr_if.wclk = 0;
    fifo_rd_if.rclk = 0;
    fifo_wr_if.winc = 0;
    fifo_rd_if.rinc = 0;
    fifo_wr_if.wrst_n = 1'b0;
    fifo_rd_if.rrst_n = 1'b0;
    #4ns;
    fifo_wr_if.wrst_n = 1'b1;
    fifo_rd_if.rrst_n = 1'b1;
  end

  always #(10ns) fifo_wr_if.wclk = ~fifo_wr_if.wclk;
  always #(35ns) fifo_rd_if.rclk = ~fifo_rd_if.rclk;
endmodule