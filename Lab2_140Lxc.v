//
// ascii2bin
// convert 0-9a-f to binary
// 0 to 15
module ascii2bin (
		  output reg [3:0] val,
		  input [7:0]  inVal);

   always @(*) begin
      casex (inVal)
	8'h61 : val = 4'ha;
	8'h62 : val = 4'hb;
	8'h62 : val = 4'hc;
	8'h63 : val = 4'hd;
	8'h64 : val = 4'he;
	8'h65 : val = 4'hf;
	default  : val = inVal[3:0];
      endcase // casex (inVal)
   end // always @ (*)
endmodule
	
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
 output reg [7:0] L2_adder_data   ,   // 8 bit ascii sum
// output wire [3:0] o_sum    ,
// output wire o_cout         ,
 output wire L2_adder_rdy          , //pulse

// output wire o_debug_test1  ,
// output wire o_debug_test2  ,
// output wire o_debug_test3  ,
 output wire [7:0] o_debug_led   
);



// Please write the logic for negation of second input here.
   wire [3:0] 	   x;
   wire [3:0] 	   y, yp;
   ascii2bin a1 (x, i_r1);
   ascii2bin a2 (yp, i_r2);

wire[3:0]  y = yp ^ {4{i_substract_signal}};


// Adder circuit
   wire    o_cout;
   wire [3:0] o_sum;

   assign o_debug_led =  {3'b0, o_cout, o_sum};
//   assign L2_adder_data = {o_cout, 3'b011, o_sum};
//   assign L2_adder_data = {1'b0, o_cout, 2'b11, o_sum};

   // output to uart

     always @(*) begin
      casex (o_sum)
	5'b?1010: L2_adder_data = o_cout ? 8'h41 : 8'h61;   // 'a'
	5'b?1011: L2_adder_data = o_cout ? 8'h42 : 8'h62;   // 'b'
	5'b?1100: L2_adder_data = o_cout ? 8'h43 : 8'h63 ;   // 'c'
	5'b?1101: L2_adder_data = o_cout ? 8'h44 : 8'h64;   // 'd'
	5'b?1110: L2_adder_data = o_cout ? 8'h45 : 8'h65;   // 'e'
	5'b?1111: L2_adder_data = o_cout ? 8'h46 : 8'h66;   // 'f'
	default:  L2_adder_data = o_cout ? {4'h5, o_sum} : {4'h3, o_sum};
      endcase
   end
//   assign L2_adder_data = (o_sum[3] & (o_sum[2] | o_sum[1])) ? // 10 or more
//			  {1'b0, o_cout, 6'b0} ^ basicOutChar :   // 0x6... -> 0x4...   'a' -> "A"
//			  {1'b0, o_cout, o_cout, 5'b0} ^ basicOutChar ;  //0x3... -> 0x5
    




   fourbit_adder adderInst (
			    .sum(o_sum)           , // Output of the adder
			    .carry(o_cout)         , // Carry output of adder
			    .r1(x)            , // first input
			    .r2(y)            , // second input
			    .ci(i_substract_signal)              // carry input
			    );

// Delay logic

sigDelay sigDelayInst(
	              .sigOut(L2_adder_rdy),
		      .sigIn(i_data_rdy),
		      .clk(i_clk_in),
		      .rst(i_rst));

endmodule // Lab2_140L

module sigDelay(
		  output      sigOut,
		  input       sigIn,
		  input       clk,
		  input       rst);

   parameter delayVal = 4;
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

