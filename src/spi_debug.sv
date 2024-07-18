//------------------------------------------------------------------------
// Module Name    : spi_debug
// Creator        : Charbel SAAD
// Creation Date  : 06/06/2024
//
// Description:
// The spi_module that connects with the debugger. The serial clock and the
// chip select are both inputs and driven by the debugging chip. The debugging
// device doesn't output to the cpu but only read the serial output.
// The spi_debug module only works with spi mode 3.
// 
// Address:
// 0 : regD
// 1 : regA
// 2 : pc
// 3 : state
//
//------------------------------------------------------------------------

`timescale 1ns/1ps

module spi_debug (
	input wire[15 : 0] regD_i, regA_i, pc_i,
	input wire[3 : 0] state_i,
	input wire resetb, sclk_i, csb_i, si_i,
	output wire so_o
);

	logic[15 : 0] out_s;
	reg[4 : 0] counter_s;
	reg[1 : 0] in_s;

	// input shift register
	always_ff @(posedge sclk_i, negedge resetb)
	begin
		if(~resetb)	in_s <= 2'b0;
		else if(~csb_i & counter_s[4])
		begin
			in_s[0] <= si_i;
			in_s[1] <= in_s[0];
		end
	end
	
	always_ff @(negedge sclk_i, negedge resetb)
	begin
		if(~resetb)	counter_s <= 5'b0;
		else if(~csb_i)
			if(counter_s == 5'b0)
				counter_s <= 5'd17;
			else
				counter_s <= counter_s - 5'b1;
	end

	always_comb
	begin
		case(in_s)
			2'b00:	out_s = regD_i;
			2'b01: 	out_s = regA_i;
			2'b10:	out_s = pc_i;
			2'b11:	out_s = {12'b0, state_i};
		endcase
	end

	assign so_o = out_s[counter_s[3 : 0]];
	
endmodule : spi_debug
