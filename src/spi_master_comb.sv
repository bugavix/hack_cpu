//------------------------------------------------------------------------
// Module Name    : spi_master_comb
// Creator        : Charbel SAAD
// Creation Date  : 02/05/2024
//
// Description:
// SPI interface module. This design implements a register and mux to interface
// between the outputed value and the MOSI signal.
// Here are some indications about the control signals:
// 	+ shiftIn_i: if 1 the in register shift is enabled on the rising edge
// 	  of the clock.
//	+ loadCount_i: if 1 and enCount_i is high it loads the value 
//	  5'F into the counter, on the falling edge of the clock.
//	+ enCount_i: if 1, it enables the dercrement of the counter, or
//	  the loading, on the falling edge of the clock.
//	+ rwb_i: designate what instruction to send to the memory:
//	  1 = READ, 0 = WRITE.
//	+ selDest_i: what register the si_i signal is sampled to.
//	  0 = srI(instruction), 1 = srM(memory)
// 	
//------------------------------------------------------------------------

`timescale 1ns/1ps

module spi_master_comb (
	input wire[15 : 0] address_i, data_i,
	input wire clk, resetb, si_i, shiftIn_i, enCount_i, rwb_i, selDest_i, 
	output wire[15 : 0] inM_o, instruction_o,
	output wire[5 : 0] count_o,
	output wire so_o, sclk_o
);

	reg[5 : 0] count_s;
	wire[39 : 0] out_s;

	shift_register srM (
		.in_i(si_i),
		.en_i(shiftIn_i & selDest_i),
		.clk(clk),
		.resetb(resetb),
		.out_o({inM_o[7 : 0], inM_o[15 : 8]})
	);

	shift_register srI (
		.in_i(si_i),
		.en_i(shiftIn_i & ~selDest_i),
		.clk(clk),
		.resetb(resetb),
		.out_o({instruction_o[7 : 0], instruction_o[15 : 8]})
	);

	always @(negedge clk, negedge resetb)
	begin
		if(~resetb)			count_s <= 6'b0;
		else if(enCount_i)
			if(count_s == 6'b0)	count_s <= 6'd39;
			else			count_s <= count_s - 6'b1;
	end

	assign out_s = {7'b1, rwb_i, address_i, data_i[7 : 0], data_i[15 : 8]};
	assign so_o = out_s[count_s];
	assign count_o = count_s;
	assign sclk_o = (enCount_i) ? clk : 1'b1;

endmodule : spi_master_comb
