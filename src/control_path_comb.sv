//------------------------------------------------------------------------
// Module Name    : control_path_comb
// Creator        : Charbel SAAD
// Creation Date  : 15/05/2024
//
// Description:
// The control path that drives most of the data path signals.
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

module control_path_comb (
	input wire[15 : 0] instruction_i,
	input wire zn_i, zr_i,
	output wire enA_o, enD_o, selA_o, selALU_o, na_o, za_o, nb_o, zb_o, f_o, no_o, loadPC_o
);

	wire tmp_s;
	
	assign selA_o = ~instruction_i[15];
	assign selALU_o = instruction_i[12];
	assign za_o = instruction_i[11];
	assign na_o = instruction_i[10];
	assign zb_o = instruction_i[9];
	assign nb_o = instruction_i[8];
	assign f_o = instruction_i[7];
	assign no_o = instruction_i[6];
	assign enA_o = instruction_i[5] | ~instruction_i[15];
	assign enD_o = instruction_i[4] & instruction_i[15];
	assign tmp_s = (instruction_i[2] & instruction_i[1]) | ~(zn_i | zr_i | (instruction_i[2] & instruction_i[1]));
	assign loadPC_o = instruction_i[15] & ((zn_i & instruction_i[2]) | (zr_i & instruction_i[1]) | (instruction_i[0] & tmp_s));

endmodule : control_path_comb
