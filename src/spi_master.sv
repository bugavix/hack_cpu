//------------------------------------------------------------------------
// Module Name    : spi_master
// Creator        : Charbel SAAD
// Creation Date  : 28/05/2024
//
// Description:
// The spi_master module combining the logic module (spi_master_comb) and the
// fsm module (spi_master_fsm)
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

module spi_master (
	input wire[15 : 0] address_i, data_i,
	input wire clk, resetb, start_i, rwb_i, si_i, selDest_i,
	output wire[15 : 0] inM_o, instruction_o,
	output wire so_o, halt_o, sclk_o, csb_o
);
	
	wire[5 : 0] count_s;
	wire shiftIn_s, enCount_s;

	spi_master_comb comb (
		.address_i(address_i),
		.data_i(data_i),
		.clk(clk),
		.resetb(resetb),
		.si_i(si_i),
		.shiftIn_i(shiftIn_s),
		.enCount_i(enCount_s),
		.rwb_i(rwb_i),
		.selDest_i(selDest_i),
		.inM_o(inM_o),
		.instruction_o(instruction_o),
		.count_o(count_s),
		.so_o(so_o),
		.sclk_o(sclk_o)
	);

	spi_master_fsm fsm (
		.count_i(count_s),
		.clk(clk),
		.resetb(resetb),
		.start_i(start_i),
		.rwb_i(rwb_i),
		.halt_o(halt_o),
		.csb_o(csb_o),
		.enCount_o(enCount_s),
		.shiftIn_o(shiftIn_s)
	);

endmodule : spi_master
