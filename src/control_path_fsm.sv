//------------------------------------------------------------------------
// Module Name    : control_path_fsm
// Creator        : Charbel SAAD
// Creation Date  : 22/05/2024
//
// Description:
// The finite state machine that drives the CPU. This version is a 8 states
// one that works with a 32 bits wide spi interface io, as well as a spi
// module used for debuging. 
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

typedef enum {
	FETCH_INSTRUCTION,
	LATCH,
	FETCH_MEMORY,
	SAVE_MEMORY
} state_t;

module control_path_fsm (
	input wire clk, resetb, cab_i, readMem_i, latchMem_i, halt_i,
	output logic enLatch_o, spiStart_o, rwb_o, selSPIAddress_o, selSPIDest_o,
	output wire[1 : 0] state_o
);

	state_t state_s;

	always @(posedge clk, negedge resetb)
	begin
		if(~resetb)						state_s <= FETCH_INSTRUCTION;
		else if(~halt_i)
			case(state_s)
				FETCH_INSTRUCTION: 
					if(cab_i && readMem_i)		state_s <= FETCH_MEMORY;
					else if(cab_i && latchMem_i)	state_s <= SAVE_MEMORY;
					else				state_s <= LATCH;

				LATCH:					state_s <= FETCH_INSTRUCTION;
	
				FETCH_MEMORY:
					if(latchMem_i)			state_s <= SAVE_MEMORY;
					else				state_s <= LATCH;

				SAVE_MEMORY:				state_s <= LATCH;
			endcase
	end

	always @(*)
	begin
		case(state_s)
			FETCH_INSTRUCTION:
			begin
				enLatch_o = 1'b0;
				spiStart_o = 1'b1;
				rwb_o = 1'b1;
				selSPIAddress_o = 1'b0;
				selSPIDest_o = 1'b0;
			end

			LATCH:
			begin
				enLatch_o = 1'b1;
				spiStart_o = 1'b0;
				rwb_o = 1'bx; // don't care
				selSPIAddress_o = 1'bx; // don't care
				selSPIDest_o = 1'bx; // don't care
			end

			FETCH_MEMORY:
			begin
				enLatch_o = 1'b0;
				spiStart_o = 1'b1;
				rwb_o = 1'b1;
				selSPIAddress_o = 1'b1;
				selSPIDest_o = 1'b1;
			end

			SAVE_MEMORY:
			begin
				enLatch_o = 1'b0;
				spiStart_o = 1'b1;
				rwb_o = 1'b0;
				selSPIAddress_o = 1'b1;
				selSPIDest_o = 1'bx; // don't care
			end
		endcase
	end

	assign state_o = state_s;

endmodule : control_path_fsm
