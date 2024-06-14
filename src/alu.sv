//------------------------------------------------------------------------
// Module Name    : alu
// Creator        : Charbel SAAD
// Creation Date  : 10/04/2024
//
// Description:
// It is the implementation of the arithmetic and logic unit. This module
// can only perform two main operations at its core: + and &. But with 5 
// additional control signals, this number increases and becomes 64. 
// Only 18 of them are actually supported.
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

module alu (
	input wire[15 : 0] a_i, b_i,
	input wire na_i, za_i, nb_i, zb_i, f_i, no_i,
	output wire[15 : 0] out_o, 
	output wire zr_o, zn_o
);

	wire[15 : 0] op1z_s, op2z_s, op1n_s, op2n_s, res_s, resn_s;

	assign op1z_s = za_i ? 16'b0 : a_i;
	assign op2z_s = zb_i ? 16'b0 : b_i;
	assign op1n_s = na_i ? ~op1z_s : op1z_s;
	assign op2n_s = nb_i ? ~op2z_s : op2z_s;
	assign res_s = f_i ? op1n_s + op2n_s : op1n_s & op2n_s;
	assign resn_s = no_i ? ~res_s : res_s;

	assign out_o = resn_s;
	assign zr_o = resn_s == 16'b0;
	assign zn_o = resn_s[15];

endmodule : alu
