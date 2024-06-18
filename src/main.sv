//------------------------------------------------------------------------
// Module Name    : main
// Creator        : Charbel SAAD
// Creation Date  : 12/04/2024
//
// Description:
// This is where the data flows to get processed.
// Control signals functionning:
// selA		: mux select for register A input (0: ALU, 1: instruction)
// enA		: register A input enabled
// selALU	: mux select for ALU second operand (0: regA, 1: memory)
// enD		: register D input enabled
// enPC		: when high: increment PC if loadPC is low else load a
// 		  value.
// loadPC	: load PC from register A
// na		: bit inverse ALU operand 1
// za		: zero ALU operand 1
// nb		: bit inverse ALU operand 2
// zb		: zero ALU operand 2
// f		: function select fro ALU (0: &, 1: +)
// no		: bit inverse ALU result
//
// Flag signals functionning:
// zr		: ALU result is null (outM == 0)
// zn		: ALU result is negative (outM[15] == 1)
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

module main (
	input wire[15 : 0] inM_i, instruction_i,
	input wire resetb, clk,
	input wire enLatch_i, halt_i,
	output wire[15 : 0] outM_o, addressM_o, pc_o, regD_o
);
	
	wire[15 : 0] muxA_s, muxALU_s, alu_s;
	reg[15 : 0] regD_s, regA_s, regPC_s;
	wire selA_s, enA_s, selALU_s, enD_s, loadPC_s, na_s, za_s, nb_s, zb_s, f_s, no_s, zr_s, zn_s;

	alu alu_instance (
		.a_i(regD_s),
		.b_i(muxALU_s),
		.na_i(na_s),
		.za_i(za_s),
		.nb_i(nb_s),
		.zb_i(zb_s),
		.f_i(f_s),
		.no_i(no_s),
		.out_o(alu_s),
		.zr_o(zr_s),
		.zn_o(zn_s)
	);

	controller controller_instance (
		.instruction_i(instruction_i),
		.zn_i(zn_s),
		.zr_i(zr_s),
		.enA_o(enA_s),
		.enD_o(enD_s),
		.selA_o(selA_s),
		.selALU_o(selALU_s),
		.na_o(na_s),
		.za_o(za_s),
		.nb_o(nb_s),
		.zb_o(zb_s),
		.f_o(f_s),
		.no_o(no_s),
		.loadPC_o(loadPC_s)
	);

	always @(posedge clk, negedge resetb)
	begin
		if(~resetb)			regD_s <= 16'b0;
		else if (enD_s & enLatch_i)	regD_s <= alu_s;
	end

	always @(posedge clk, negedge resetb)
	begin
		if(~resetb)			regA_s <= 16'b0;
		else if(enA_s & enLatch_i)	regA_s <= muxA_s;
	end

	always @(posedge clk, negedge resetb)
	begin
		if(~resetb)		regPC_s <= 16'b0;
		else if(enLatch_i & ~halt_i)
			if(loadPC_s)	regPC_s <= regA_s;
			else		regPC_s <= regPC_s + 16'b10;	
	end

	assign muxA_s = selA_s ? instruction_i : alu_s;
	assign muxALU_s = selALU_s ? inM_i : regA_s;
	assign outM_o = alu_s;
	assign addressM_o = regA_s;
	assign pc_o = regPC_s;
	assign regD_o = regD_s;

endmodule : main
