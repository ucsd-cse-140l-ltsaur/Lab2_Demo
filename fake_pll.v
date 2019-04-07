//
// fake pll module for running in the simulator
//
module fake_pll(
		input REFERENCECLK,
		output reg PLLOUTCORE,
		output PLLOUTGLOBAL,
		input RESETB,
		input BYPASS
		);

   initial
     PLLOUTCORE <= 1;
   
   always @(*) begin
      #10;
      PLLOUTCORE <= ~PLLOUTCORE;
   end
endmodule // fake_pll

