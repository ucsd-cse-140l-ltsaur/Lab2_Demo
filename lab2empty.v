module Lab2_140L (
 input wire i_rst           , // reset signal (active high)
 input wire i_clk_in          , //for internal state machine
 input wire i_data_rdy        , //r1, r2, OP are ready  
// input wire i_ctrl_signal     , 
 input wire i_substract_signal,
 input wire [7:0] i_r1           , // 8bit number 1
 input wire [7:0] i_r2           , // 8bit number 1
// input wire i_cin           , // carry in
// input wire [7:0] i_ctrl         , // input ctrl char
 output wire [3:0] o_sum    ,
 output wire o_cout         ,
 output wire o_rdy          , //pulse

// output wire o_debug_test1  ,
// output wire o_debug_test2  ,
// output wire o_debug_test3  ,
 output wire [7:0] o_debug_led   
);

wire[3:0]  x = i_r1[3:0];
wire[3:0]  y = i_r2[3:0] ^ {4{i_substract_signal}};

// Please write the logic for negation of second input here.

// Adder circuit

fourbit_adder adderInst (
.sum(o_sum)           , // Output of the adder
.carry(o_cout)         , // Carry output of adder
.r1(x)            , // first input
.r2(y)            , // second input
.ci(i_substract_signal)              // carry input
);

// Delay logic

sigDelay sigDelayInst(
	              .sigOut(o_rdy),
		      .sigIn(i_data_rdy),
		      .clk(i_clk_in),
		      .rst(i_rst));

endmodule // Lab2_140L

module sigDelay(
		  output      sigOut,
		  input       sigIn,
		  input       clk,
		  input       rst);

   parameter delayVal = 3;
   reg [15:0] 		      delayReg;


   always @(posedge clk) begin
      if (rst)
	delayReg <= 16'b0;
      else begin
	 delayReg <= {delayReg[14:0], sigIn};
      end
   end

   assign sigOut = delayReg[delayVal];
endmodule // sigDelay

