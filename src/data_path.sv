//------------------------------------------------------------------------
// Module Name    : data_path
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

module data_path (
	input wire[15 : 0] inM_i, instruction_i,
	input wire resetb, clk,
	input wire selA_i, enA_i, selALU_i, enD_i, enPC_i, loadPC_i, na_i, za_i, nb_i, zb_i, f_i, no_i, halt_i,
	output wire[15 : 0] outM_o, addressM_o, pc_o, regD_o,
	output wire zr_o, zn_o
);
	
	wire[15 : 0] muxA_s, muxALU_s, alu_s;
	reg[15 : 0] regD_s, regA_s, regPC_s;

	alu alu_instance (
		.a_i(regD_s),
		.b_i(muxALU_s),
		.na_i(na_i),
		.za_i(za_i),
		.nb_i(nb_i),
		.zb_i(zb_i),
		.f_i(f_i),
		.no_i(no_i),
		.out_o(alu_s),
		.zr_o(zr_o),
		.zn_o(zn_o)
	);

	always @(posedge clk, negedge resetb)
	begin
		if(~resetb)		regD_s <= 16'b0;
		else if (enD_i)		regD_s <= alu_s;
	end

	always @(posedge clk, negedge resetb)
	begin
		if(~resetb)		regA_s <= 16'b0;
		else if(enA_i)		regA_s <= muxA_s;
	end

	always @(posedge clk, negedge resetb)
	begin
		if(~resetb)		regPC_s <= 16'b0;
		else if(enPC_i & ~halt_i)
			if(loadPC_i)	regPC_s <= regA_s;
			else		regPC_s <= regPC_s + 16'b10;	
	end

	assign muxA_s = selA_i ? instruction_i : alu_s;
	assign muxALU_s = selALU_i ? inM_i : regA_s;
	assign outM_o = alu_s;
	assign addressM_o = regA_s;
	assign pc_o = regPC_s;
	assign regD_o = regD_s;

endmodule : data_path
