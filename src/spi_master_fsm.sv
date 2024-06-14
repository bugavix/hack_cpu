//------------------------------------------------------------------------
// Module Name    : spi_master_fsm
// Creator        : Charbel SAAD
// Creation Date  : 24/05/2024
//
// Description:
// The finite state machine that commands the spi_master_comb module.
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

typedef enum reg[1 : 0] {
	IDLE,
	TRANSFER,
	FINISH,
	REST
} spi_state_t;

module spi_master_fsm (
	input wire[5 : 0] count_i,
	input wire clk, resetb, start_i, rwb_i,
	output logic csb_o, enCount_o, shiftIn_o, halt_o
);

	spi_state_t state_s;
	wire c0_s;

	assign c0_s = (count_i == 6'b0);

	always @(posedge clk, negedge resetb)
	begin
		if(~resetb)					state_s <= IDLE;
		else
		begin
			state_s[0] <= (~state_s[0] & (state_s[1] ^ start_i)) | (~state_s[1] & state_s[0] & ~c0_s);
			state_s[1] <= (~state_s[1] & state_s[0] & c0_s) | (state_s[1] & ~state_s[0] & ~start_i);
		end
	end

	assign halt_o = ~state_s[1] & (start_i | state_s[0]);
	assign csb_o = state_s[1] | ~state_s[0];
	assign enCount_o = ~state_s[1] & state_s[0];
	assign shiftIn_o = ~state_s[1] & state_s[0] & rwb_i;

endmodule : spi_master_fsm
