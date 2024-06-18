//------------------------------------------------------------------------
// Module Name    : cpu_top
// Creator        : Charbel SAAD
// Creation Date  : 31/05/2024
//
// Description:
// The top module that combines everything.
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

module cpu_top (
	input wire clk, resetb, si_i, extHalt_i, csb_i, sclk_i, mi_i,
	output wire so_o, sclk_o, csb_o, mo_o
);

	wire[15 : 0] address_s, data_s, inM_s, instruction_s, addressM_s, pc_s, regD_s;
	wire[1 : 0] state_s;
	wire spiStart_s, rwb_s, spiHalt_s, enLatch_s, selSPIAddress_s, selSPIDest_s;

	main m (
		.inM_i(inM_s),
		.instruction_i(instruction_s),
		.clk(clk),
		.resetb(resetb),
		.enLatch_i(enLatch_s),
		.halt_i(extHalt_i),
		.outM_o(data_s),
		.addressM_o(addressM_s),
		.pc_o(pc_s),
		.regD_o(regD_s)
	);

	cpu_fsm cf (
		.clk(clk),
		.resetb(resetb),
		.cab_i(instruction_s[15]),
		.readMem_i(instruction_s[12]),
		.latchMem_i(instruction_s[3]),
		.halt_i(spiHalt_s | extHalt_i),
		.enLatch_o(enLatch_s),
		.spiStart_o(spiStart_s),
		.rwb_o(rwb_s),
		.selSPIAddress_o(selSPIAddress_s),
		.selSPIDest_o(selSPIDest_s),
		.state_o(state_s)
	);

	spi_master sm (
		.address_i(address_s),
		.data_i(data_s),
		.clk(clk),
		.resetb(resetb),
		.start_i(spiStart_s),
		.rwb_i(rwb_s),
		.si_i(si_i),
		.selDest_i(selSPIDest_s),
		.inM_o(inM_s),
		.instruction_o(instruction_s),
		.so_o(so_o),
		.halt_o(spiHalt_s),
		.sclk_o(sclk_o),
		.csb_o(csb_o)
	);

	spi_slave ss (
		.regD_i(regD_s),
		.regA_i(addressM_s),
		.pc_i(pc_s),
		.state_i(state_s),
		.si_i(mi_i),
		.resetb(resetb),
		.sclk_i(sclk_i),
		.csb_i(csb_i),
		.so_o(mo_o)
	);

	assign address_s = (selSPIAddress_s) ? addressM_s : pc_s;

endmodule : cpu_top
