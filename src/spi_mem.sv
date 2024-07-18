//------------------------------------------------------------------------
// Module Name    : spi_mem
// Creator        : Charbel SAAD
// Creation Date  : 28/05/2024
//
// Description:
// The spi_mem module combining the logic module (spi_mem_comb) and the
// fsm module (spi_mem_fsm)
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

typedef enum reg[1 : 0] {
	IDLE,
	TRANSFER,
	FINISH,
	REST
} spi_state_t;

module spi_mem (
	input wire[15 : 0] address_i, data_i,
	input wire clk, resetb, start_i, rwb_i, si_i, selDest_i,
	output wire[15 : 0] inM_o, instruction_o,
	output wire so_o, halt_o, sclk_o, csb_o
);
	
	wire[39 : 0] out_s;
	reg[5 : 0] count_s;
	spi_state_t state_s, next_state_s;
	wire shiftIn_s, enCount_s, c0_s;
	
	shift_register srM (
		.in_i(si_i),
		.en_i(shiftIn_s & selDest_i),
		.clk(clk),
		.resetb(resetb),
		.out_o({inM_o[7 : 0], inM_o[15 : 8]})
	);

	shift_register srI (
		.in_i(si_i),
		.en_i(shiftIn_s & ~selDest_i),
		.clk(clk),
		.resetb(resetb),
		.out_o({instruction_o[7 : 0], instruction_o[15 : 8]})
	);

	always_ff @(negedge clk, negedge resetb)
	begin
		if(~resetb)			count_s <= 6'b0;
		else if(enCount_s)
			if(count_s == 6'b0)	count_s <= 6'd39;
			else			count_s <= count_s - 6'b1;
	end

	always_ff @(posedge clk, negedge resetb)
	begin
		if(~resetb)	state_s <= IDLE;
		else		state_s <= next_state_s;
	end

	assign next_state_s[0] = (~state_s[0] & (state_s[1] ^ start_i)) | (~state_s[1] & state_s[0] & ~c0_s);
	assign next_state_s[1] = (~state_s[1] & state_s[0] & c0_s) | (state_s[1] & ~state_s[0] & ~start_i);
	assign out_s = {7'b1, rwb_i, address_i, data_i[7 : 0], data_i[15 : 8]};
	assign so_o = out_s[count_s];
	assign sclk_o = (enCount_s) ? clk : 1'b1;
	assign c0_s = (count_s == 6'b0);
	assign halt_o = ~state_s[1] & (start_i | state_s[0]);
	assign csb_o = state_s[1] | ~state_s[0];
	assign enCount_s = ~state_s[1] & state_s[0];
	assign shiftIn_s = ~state_s[1] & state_s[0] & rwb_i;

endmodule : spi_mem
