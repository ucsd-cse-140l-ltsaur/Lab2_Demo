//
// fake pll module for running in the simulator
//
module fake_pll(
		input REFERENCECLK,
		output PLLOUTCORE,
		output PLLOUTGLOBAL,
		input RESET
		);

   reg 		      PLLOUTCORE;  // 38 MHz
   initial
     PLLOUTCORE <= 0;

   always @(*) begin
      #13;
      PLLOUTCORE <= ~PLLOUTCORE;
   end
endmodule // fake_pll

