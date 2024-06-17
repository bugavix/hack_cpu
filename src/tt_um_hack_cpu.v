/*
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_hack_cpu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

	assign uo_out[7 : 4] = 4'b0;
	assign uio_oe = 8'hFF;
	assign uio_out = 8'b0;

	cpu_top cpu (
		.clk(clk),
		.resetb(rst_n),
		.si_i(ui_in[0]),
		.extHalt_i(ui_in[1]),
		.csb_i(ui_in[2]),
		.sclk_i(ui_in[3]),
		.mi_i(ui_in[4]),
		.so_o(uo_out[0]),
		.sclk_o(uo_out[1]),
		.csb_o(uo_out[2]),
		.mo_o(uo_out[3])
	);

endmodule
