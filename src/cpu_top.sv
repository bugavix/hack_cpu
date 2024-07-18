//------------------------------------------------------------------------
// Module Name    : cpu_top
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

module cpu_top (
	input wire clk, resetb, mem_in_i, halt_i, debug_csb_i, debug_sclk_i, debug_in_i,
	output wire mem_out_o, mem_sclk_o, mem_csb_o, debug_out_o
);
	
	wire[15 : 0] muxA_s, muxALU_s, inM_s, instruction_s, outM_s, spiAddress_s;
	reg[15 : 0] regD_s, regA_s, pc_s;
	wire[3 : 0] state_s;
	wire selA_s, enA_s, selALU_s, enD_s, enPC_s, loadPC_s, na_s, za_s, nb_s, zb_s, f_s, no_s, zr_s, zn_s, spiHalt_s, spiStart_s, rwb_s, selSPIAddress_s, selSPIDest_s;

	alu alu_instance (
		.a_i(regD_s),
		.b_i(muxALU_s),
		.na_i(na_s),
		.za_i(za_s),
		.nb_i(nb_s),
		.zb_i(zb_s),
		.f_i(f_s),
		.no_i(no_s),
		.out_o(outM_s),
		.zr_o(zr_s),
		.zn_o(zn_s)
	);

	fsm fsm_instance (
		.instruction_i(instruction_s),
		.clk(clk),
		.resetb(resetb),
		.halt_i(spiHalt_s | halt_i),
		.zn_i(zn_s),
		.zr_i(zr_s),
		.spiStart_o(spiStart_s),
		.rwb_o(rwb_s),
		.selSPIAddress_o(selSPIAddress_s),
		.selSPIDest_o(selSPIDest_s),
		.enA_o(enA_s),
		.enD_o(enD_s),
		.enPC_o(enPC_s),
		.loadPC_o(loadPC_s),
		.selA_o(selA_s),
		.selALU_o(selALU_s),
		.na_o(na_s),
		.za_o(za_s),
		.nb_o(nb_s),
		.zb_o(zb_s),
		.f_o(f_s),
		.no_o(no_s),
		.state_o(state_s)
	);

	spi_mem spi_mem_instance (
		.address_i(spiAddress_s),
		.data_i(outM_s),
		.clk(clk),
		.resetb(resetb),
		.start_i(spiStart_s),
		.rwb_i(rwb_s),
		.si_i(mem_in_i),
		.selDest_i(selSPIDest_s),
		.inM_o(inM_s),
		.instruction_o(instruction_s),
		.so_o(mem_out_o),
		.halt_o(spiHalt_s),
		.sclk_o(mem_sclk_o),
		.csb_o(mem_csb_o)
	);

	spi_debug spi_debug_instance (
		.regD_i(regD_s),
		.regA_i(regA_s),
		.pc_i(pc_s),
		.state_i(state_s),
		.si_i(debug_in_i),
		.resetb(resetb),
		.sclk_i(debug_sclk_i),
		.csb_i(debug_csb_i),
		.so_o(debug_out_o)
	);

	always_ff @(posedge clk, negedge resetb)
	begin
		if(~resetb)	regD_s <= 16'b0;
		else if (enD_s)	regD_s <= outM_s;
	end

	always_ff @(posedge clk, negedge resetb)
	begin
		if(~resetb)	regA_s <= 16'b0;
		else if(enA_s)	regA_s <= muxA_s;
	end

	always_ff @(posedge clk, negedge resetb)
	begin
		if(~resetb)		pc_s <= 16'b0;
		else if(enPC_s & ~halt_i)
			if(loadPC_s)	pc_s <= regA_s;
			else		pc_s <= pc_s + 16'b10;	
	end

	assign muxA_s = selA_s ? instruction_s : outM_s;
	assign muxALU_s = selALU_s ? inM_s : regA_s;
	assign spiAddress_s = (selSPIAddress_s) ? regA_s : pc_s;

endmodule : cpu_top
