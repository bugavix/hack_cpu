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

	assign uo_out = 8'b0;
	assign uio_oe = 8'h4B;
	assign {uio_out[7], uio_out[5 : 4], uio_out[2]} = 4'b0;

	cpu_top cpu (
		.clk(clk),
		.resetb(rst_n),
		.mem_in_i(uio_in[2]),
		.halt_i(ui_in[0]),
		.debug_csb_i(uio_in[4]),
		.debug_sclk_i(uio_in[7]),
		.debug_in_i(uio_in[5]),
		.mem_out_o(uio_out[1]),
		.mem_sclk_o(uio_out[3]),
		.mem_csb_o(uio_out[0]),
		.debug_out_o(uio_out[6])
	);

endmodule : tt_um_hack_cpu
