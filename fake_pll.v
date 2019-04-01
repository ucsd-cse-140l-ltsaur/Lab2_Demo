//
// fake pll module for running in the simulator
//
module fake_pll(
		input REFERENCECLK,
		output reg PLLOUTCORE,   // 38 MHz
		output PLLOUTGLOBAL,
		input RESET
		);

   initial
     PLLOUTCORE <= 0;

   always @(*) begin
      #13;
      PLLOUTCORE <= ~PLLOUTCORE;
   end
endmodule // fake_pll

