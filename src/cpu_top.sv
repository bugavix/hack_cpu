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
	wire spiStart_s, rwb_s, spiHalt_s, selA_s, enA_s, selALU_s, enD_s, loadPC_s, na_s, za_s, nb_s, zb_s, f_s, no_s, zr_s, zn_s, enLatch_s, selSPIAddress_s, selSPIDest_s;

	data_path dp (
		.inM_i(inM_s),
		.instruction_i(instruction_s),
		.clk(clk),
		.resetb(resetb),
		.selA_i(selA_s),
		.enA_i(enA_s & enLatch_s),
		.selALU_i(selALU_s),
		.enD_i(enD_s & enLatch_s),
		.enPC_i(enLatch_s),
		.loadPC_i(loadPC_s),
		.na_i(na_s),
		.za_i(za_s),
		.nb_i(nb_s),
		.zb_i(zb_s),
		.no_i(no_s),
		.f_i(f_s),
		.halt_i(extHalt_i),
		.outM_o(data_s),
		.addressM_o(addressM_s),
		.pc_o(pc_s),
		.regD_o(regD_s),
		.zr_o(zr_s),
		.zn_o(zn_s)
	);

	control_path cp (
		.instruction_i(instruction_s),
		.clk(clk),
		.resetb(resetb),
		.zn_i(zn_s),
		.zr_i(zr_s),
		.halt_i(spiHalt_s | extHalt_i),
		.selA_o(selA_s),
		.enA_o(enA_s),
		.selALU_o(selALU_s),
		.enD_o(enD_s),
		.loadPC_o(loadPC_s),
		.na_o(na_s),
		.za_o(za_s),
		.nb_o(nb_s),
		.zb_o(zb_s),
		.no_o(no_s),
		.f_o(f_s),
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
