//A
//------------------------------------------------------------------------
// Module Name    : fsm
// Creator        : Charbel SAAD
// Creation Date  : 10/07/2024
//
// Description:
// This module takes the place of the old cpu_fsm and conrtroller module.
// It manages the all the control signals by its own.
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

typedef enum reg[3 : 0] {
	FETCH_INSTRUCTION,
	NO_LATCH,
	LATCH_D,
	LATCH_A,
	LATCH_AD,
	LATCH_PC,
	LATCH_PCD,
	LATCH_PCA,
	LATCH_PCAD,
	FETCH_MEMORY,
	SAVE_MEMORY
} fsm_state_t;

module fsm (
	input wire[15 : 0] instruction_i,	
	input wire clk, resetb, halt_i, zr_i, zn_i,
	output reg spiStart_o, rwb_o, selSPIAddress_o, selSPIDest_o, enA_o, enD_o, enPC_o, loadPC_o,
	output wire selA_o, selALU_o, na_o, za_o, nb_o, zb_o, f_o, no_o,
	output wire[3 : 0] state_o
);

	fsm_state_t state_s;
	fsm_state_t next_state_s;
	wire loadPC_s, enA_s, enD_s;

	assign loadPC_s = instruction_i[15] & ((zn_i & instruction_i[2]) | (zr_i & instruction_i[1]) | (instruction_i[0] & ~zn_i & ~zr_i));
	assign enA_s = ~instruction_i[15] | instruction_i[5];
	assign enD_s = instruction_i[15] & instruction_i[4];
	// TODO: find a more optimized way of doing this.

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
				else case({loadPC_s, enA_s, enD_s})
					3'b000: next_state_s = NO_LATCH;
					3'b001: next_state_s = LATCH_D;
					3'b010: next_state_s = LATCH_A;
					3'b011: next_state_s = LATCH_AD;
					3'b100: next_state_s = LATCH_PC;
					3'b101: next_state_s = LATCH_PCD;
					3'b110: next_state_s = LATCH_PCA;
					3'b111: next_state_s = LATCH_PCAD;
				endcase

			NO_LATCH:
				next_state_s = FETCH_INSTRUCTION;

			LATCH_D:
				next_state_s = FETCH_INSTRUCTION;

			LATCH_A:
				next_state_s = FETCH_INSTRUCTION;

			LATCH_AD:
				next_state_s = FETCH_INSTRUCTION;

			LATCH_PC:
				next_state_s = FETCH_INSTRUCTION;

			LATCH_PCD:
				next_state_s = FETCH_INSTRUCTION;

			LATCH_PCA:
				next_state_s = FETCH_INSTRUCTION;

			LATCH_PCAD:
				next_state_s = FETCH_INSTRUCTION;

			FETCH_MEMORY:
				if(instruction_i[3])
					next_state_s = SAVE_MEMORY;
				else case({loadPC_s, enA_s, enD_s})
					3'b000: next_state_s = NO_LATCH;
					3'b001: next_state_s = LATCH_D;
					3'b010: next_state_s = LATCH_A;
					3'b011: next_state_s = LATCH_AD;
					3'b100: next_state_s = LATCH_PC;
					3'b101: next_state_s = LATCH_PCD;
					3'b110: next_state_s = LATCH_PCA;
					3'b111: next_state_s = LATCH_PCAD;
				endcase

			SAVE_MEMORY:
				case({loadPC_s, enA_s, enD_s})
					3'b000: next_state_s = NO_LATCH;
					3'b001: next_state_s = LATCH_D;
					3'b010: next_state_s = LATCH_A;
					3'b011: next_state_s = LATCH_AD;
					3'b100: next_state_s = LATCH_PC;
					3'b101: next_state_s = LATCH_PCD;
					3'b110: next_state_s = LATCH_PCA;
					3'b111: next_state_s = LATCH_PCAD;
				endcase

			default:
				next_state_s = FETCH_INSTRUCTION;
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

			NO_LATCH:
			begin
				spiStart_o = 1'b0;
				rwb_o = 1'b0; // don't care
				selSPIAddress_o = 1'b0; // don't care
				selSPIDest_o = 1'b0; // don't care
				enA_o = 1'b0;
				enD_o = 1'b0;
				loadPC_o = 1'b0;
				enPC_o = 1'b1;
			end

			LATCH_D:
			begin
				spiStart_o = 1'b0;
				rwb_o = 1'b0; // don't care
				selSPIAddress_o = 1'b0; // don't care
				selSPIDest_o = 1'b0; // don't care
				enA_o = 1'b0;
				enD_o = 1'b1;
				loadPC_o = 1'b0;
				enPC_o = 1'b1;
			end

			LATCH_A:
			begin
				spiStart_o = 1'b0;
				rwb_o = 1'b0; // don't care
				selSPIAddress_o = 1'b0; // don't care
				selSPIDest_o = 1'b0; // don't care
				enA_o = 1'b1;
				enD_o = 1'b0;
				loadPC_o = 1'b0;
				enPC_o = 1'b1;
			end

			LATCH_AD:
			begin
				spiStart_o = 1'b0;
				rwb_o = 1'b0; // don't care
				selSPIAddress_o = 1'b0; // don't care
				selSPIDest_o = 1'b0; // don't care
				enA_o = 1'b1;
				enD_o = 1'b1;
				loadPC_o = 1'b0;
				enPC_o = 1'b1;
			end

			LATCH_PC:
			begin
				spiStart_o = 1'b0;
				rwb_o = 1'b0; // don't care
				selSPIAddress_o = 1'b0; // don't care
				selSPIDest_o = 1'b0; // don't care
				enA_o = 1'b0;
				enD_o = 1'b0;
				loadPC_o = 1'b1;
				enPC_o = 1'b1;
			end

			LATCH_PCD:
			begin
				spiStart_o = 1'b0;
				rwb_o = 1'b0; // don't care
				selSPIAddress_o = 1'b0; // don't care
				selSPIDest_o = 1'b0; // don't care
				enA_o = 1'b0;
				enD_o = 1'b1;
				loadPC_o = 1'b1;
				enPC_o = 1'b1;
			end

			LATCH_PCA:
			begin
				spiStart_o = 1'b0;
				rwb_o = 1'b0; // don't care
				selSPIAddress_o = 1'b0; // don't care
				selSPIDest_o = 1'b0; // don't care
				enA_o = 1'b1;
				enD_o = 1'b0;
				loadPC_o = 1'b1;
				enPC_o = 1'b1;
			end

			LATCH_PCAD:
			begin
				spiStart_o = 1'b0;
				rwb_o = 1'b0; // don't care
				selSPIAddress_o = 1'b0; // don't care
				selSPIDest_o = 1'b0; // don't care
				enA_o = 1'b1;
				enD_o = 1'b1;
				loadPC_o = 1'b1;
				enPC_o = 1'b1;
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

			default:
			begin
				spiStart_o = 1'b0; // don't care
				rwb_o = 1'b0; // don't care
				selSPIAddress_o = 1'b0; // don't care
				selSPIDest_o = 1'b0; // don't care
				enA_o = 1'b0; // don't care
				enD_o = 1'b0; // don't care
				loadPC_o = 1'b0; // don't care
				enPC_o = 1'b0; // don't care
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
