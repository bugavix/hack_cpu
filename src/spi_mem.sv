//------------------------------------------------------------------------
// Module Name    : spi_mem
// Creator        : Charbel SAAD
// Creation Date  : 28/05/2024
//
// Description:
// The SPI module responsible of communicating between the CPU and the SPI
// RAM. 
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

typedef enum reg[2 : 0] {
	IDLE,
	TRANSFER_READ,
	TRANSFER_WRITE,
	FINISH,
	REST
} spi_state_t;

module spi_mem (
	input wire[15 : 0] address_i, data_i,
	input wire clk, resetb, start_i, rwb_i, si_i, selDest_i,
	output wire[15 : 0] inM_o, instruction_o,
	output wire so_o, halt_o, sclk_o,
	output reg csb_o
);
	
	wire[39 : 0] out_s;
	reg[5 : 0] count_s;
	spi_state_t state_s, next_state_s;
	reg shiftIn_s, enCount_s, halt_s;
	
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

	always_comb
	begin
		case(state_s)
			IDLE:
				if(start_i & rwb_i)
					next_state_s = TRANSFER_READ;
				else if(start_i)
					next_state_s = TRANSFER_WRITE;
				else
					next_state_s = IDLE;

			TRANSFER_READ:
				if(count_s == 6'b0)
					next_state_s = FINISH;
				else
					next_state_s = TRANSFER_READ;

			TRANSFER_WRITE:
				if(count_s == 6'b0)
					next_state_s = FINISH;
				else
					next_state_s = TRANSFER_WRITE;

			FINISH:
				if(start_i)
					next_state_s = IDLE;
				else
					next_state_s = REST;

			REST:
				next_state_s = IDLE;

			default:
				next_state_s = IDLE;
		endcase
	end

	always_comb
	begin
		case(state_s)
			IDLE:
			begin
				halt_s = 1'b0;
				csb_o = 1'b1;
				enCount_s = 1'b0;
				shiftIn_s = 1'b0;
			end

			TRANSFER_READ:
			begin
				halt_s = 1'b1;
				csb_o = 1'b0;
				enCount_s = 1'b1;
				shiftIn_s = 1'b1;
			end

			TRANSFER_WRITE:
			begin
				halt_s = 1'b1;
				csb_o = 1'b0;
				enCount_s = 1'b1;
				shiftIn_s = 1'b0;
			end

			FINISH:
			begin
				halt_s = 1'b0;
				csb_o = 1'b1;
				enCount_s = 1'b0;
				shiftIn_s = 1'b0;
			end

			REST:
			begin
				halt_s = 1'b0;
				csb_o = 1'b1;
				enCount_s = 1'b0;
				shiftIn_s = 1'b0;
			end

			default:
			begin
				halt_s = 1'b0;
				csb_o = 1'b1;
				enCount_s = 1'b0;
				shiftIn_s = 1'b0;
			end
		endcase
	end

	assign out_s = {7'b1, rwb_i, address_i, data_i[7 : 0], data_i[15 : 8]};
	assign so_o = out_s[count_s];
	assign sclk_o = (enCount_s) ? clk : 1'b1;
	assign halt_o = halt_s | ((state_s == IDLE) & start_i);

endmodule : spi_mem
