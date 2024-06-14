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
	genvar i;

	always @(posedge clk, negedge resetb)
	begin
		if(~resetb)	shift_s[0] <= 1'b0;
		else if(en_i)	shift_s[0] <= in_i;
	end

	generate
		for(i = 1; i < 16; i += 1)
			always @(posedge clk, negedge resetb)
			begin
				if(~resetb)	shift_s[i] <= 1'b0;
				else if(en_i)	shift_s[i] <= shift_s[i - 1];
			end
	endgenerate

	assign out_o = shift_s;

endmodule : shift_register
