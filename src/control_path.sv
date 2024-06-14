//------------------------------------------------------------------------
// Module Name    : control_path
// Creator        : Charbel SAAD
// Creation Date  : 29/05/2024
//
// Description:
// The top module control_path combining the logic and the fsm.
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

module control_path (
	input wire[15 : 0] instruction_i,
	input wire clk, resetb, zn_i, zr_i, halt_i,
	output wire enA_o, enD_o, selA_o, selALU_o, na_o, za_o, nb_o, zb_o, f_o, no_o, loadPC_o, enLatch_o, spiStart_o, rwb_o, selSPIAddress_o, selSPIDest_o,
	output wire[1 : 0] state_o
);

	control_path_comb comb (
		.instruction_i(instruction_i),
		.zn_i(zn_i),
		.zr_i(zr_i),
		.enA_o(enA_o),
		.enD_o(enD_o),
		.selA_o(selA_o),
		.selALU_o(selALU_o),
		.na_o(na_o),
		.za_o(za_o),
		.nb_o(nb_o),
		.zb_o(zb_o),
		.f_o(f_o),
		.no_o(no_o),
		.loadPC_o(loadPC_o)
	);

	control_path_fsm fsm (
		.clk(clk),
		.resetb(resetb),
		.cab_i(instruction_i[15]),
		.readMem_i(instruction_i[12]),
		.latchMem_i(instruction_i[3]),
		.halt_i(halt_i),
		.enLatch_o(enLatch_o),
		.spiStart_o(spiStart_o),
		.rwb_o(rwb_o),
		.selSPIAddress_o(selSPIAddress_o),
		.selSPIDest_o(selSPIDest_o),
		.state_o(state_o)
	);

endmodule : control_path
