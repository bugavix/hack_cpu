//------------------------------------------------------------------------
// Module Name    : fsm
// Creator        : Charbel SAAD
// Creation Date  : 10/07/2024
//
// Description:
// This module manages all the control signals.
// For more details on each signal description, check src/cpu_top.sv
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

typedef enum reg[1 : 0] {
	FETCH_INSTRUCTION,
	LATCH,
	FETCH_MEMORY,
	SAVE_MEMORY
} fsm_state_t;

module fsm (
	input wire[15 : 0] instruction_i,	
	input wire clk, resetb, halt_i, zr_i, zn_i,
	output reg spiStart_o, rwb_o, selSPIAddress_o, selSPIDest_o, enA_o, enD_o, enPC_o, loadPC_o,
	output wire selA_o, selALU_o, na_o, za_o, nb_o, zb_o, f_o, no_o,
	output wire[1 : 0] state_o
);

	fsm_state_t state_s;
	fsm_state_t next_state_s;

	always_ff @(posedge clk, negedge resetb)
	begin
		if(~resetb)		state_s <= FETCH_INSTRUCTION;
		else if(~halt_i)	state_s <= next_state_s;
	end

	always_comb
	begin
		case(state_s)
			FETCH_INSTRUCTION:
				if(instruction_i[15] & instruction_i[12])
					next_state_s = FETCH_MEMORY;
				else if(instruction_i[15] & instruction_i[3])
					next_state_s = SAVE_MEMORY;
				else
					next_state_s = LATCH;

			LATCH:
				next_state_s = FETCH_INSTRUCTION;

			FETCH_MEMORY:
				if(instruction_i[3])
					next_state_s = SAVE_MEMORY;
				else
					next_state_s = LATCH;

			SAVE_MEMORY:
				next_state_s = LATCH;
		endcase
	end

	always_comb
	begin
		case(state_s)
			FETCH_INSTRUCTION:
			begin
				spiStart_o = 1'b1;
				rwb_o = 1'b1;
				selSPIAddress_o = 1'b0;
				selSPIDest_o = 1'b0;
				enA_o = 1'b0;
				enD_o = 1'b0;
				loadPC_o = 1'b0;
				enPC_o = 1'b0;
			end

			LATCH:
			begin
				spiStart_o = 1'b0;
				rwb_o = 1'b0; // don't care
				selSPIAddress_o = 1'b0; // don't care
				selSPIDest_o = 1'b0; // don't care
				if(halt_i)
					enPC_o = 1'b0;
				else
					enPC_o = 1'b1;
				if(~instruction_i[15] | instruction_i[5])
					enA_o = 1'b1;
				else
					enA_o = 1'b0;
				if(instruction_i[15] & instruction_i[4])
					enD_o = 1'b1;
				else
					enD_o = 1'b0;
				if(instruction_i[15] & ((zn_i & instruction_i[2]) | (zr_i & instruction_i[1]) | (instruction_i[0] & ~zn_i & ~zr_i)))
					loadPC_o = 1'b1;
				else
					loadPC_o = 1'b0;
			end

			FETCH_MEMORY:
			begin
				spiStart_o = 1'b1;
				rwb_o = 1'b1;
				selSPIAddress_o = 1'b1;
				selSPIDest_o = 1'b1;
				enA_o = 1'b0;
				enD_o = 1'b0;
				loadPC_o = 1'b0;
				enPC_o = 1'b0;
			end

			SAVE_MEMORY:
			begin
				spiStart_o = 1'b1;
				rwb_o = 1'b0;
				selSPIAddress_o = 1'b1;
				selSPIDest_o = 1'b0; // don't care
				enA_o = 1'b0;
				enD_o = 1'b0;
				loadPC_o = 1'b0;
				enPC_o = 1'b0;
			end
		endcase
	end

	assign selA_o = ~instruction_i[15];
	assign selALU_o = instruction_i[12];
	assign za_o = instruction_i[11];
	assign na_o = instruction_i[10];
	assign zb_o = instruction_i[9];
	assign nb_o = instruction_i[8];
	assign f_o = instruction_i[7];
	assign no_o = instruction_i[6];
	assign state_o = state_s;

endmodule : fsm
