`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Create and assign the cpu signals:

  wire resetb, mem_in_i, halt_i, debug_csb_i, debug_sclk_i, debug_in_i, mem_out_o, mem_sclk_o, mem_csb_o, debug_out_o;

  assign rst_n = resetb;
  assign ui_in[0] = mem_in_i;
  assign ui_in[1] = halt_i;
  assign ui_in[2] = debug_csb_i;
  assign ui_in[3] = debug_sclk_i;
  assign ui_in[4] = debug_in_i;
  assign ui_in[7 : 5] = 3'b0;
  assign mem_out_o = uo_out[0];
  assign mem_sclk_o = uo_out[1];
  assign mem_csb_o = uo_out[2];
  assign debug_out_o = uo_out[3];

  // Replace tt_um_example with your module name:
  tt_um_hack_cpu hack_cpu (

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(1'b1),
      .VGND(1'b0),
`endif

      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

endmodule
