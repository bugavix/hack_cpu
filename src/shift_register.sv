//------------------------------------------------------------------------
// Module Name    : shift_register
// Creator        : Charbel SAAD
// Creation Date  : 08/05/2024
//
// Description:
// This is a 16-bit shift register.
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

module shift_register (
	input wire in_i, en_i, clk, resetb,
	output wire[15 : 0] out_o
);
	reg[15 : 0] shift_s;

	always @(posedge clk, negedge resetb)
	begin
		if(~resetb)	shift_s <= 16'b0;
		else if(en_i)	shift_s <= {shift_s[14 : 0], in_i};
	end

	assign out_o = shift_s;

endmodule : shift_register
