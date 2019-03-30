//
// software testbench for simulation
//
module tb_sft(
	      	      // pin interface 
	      input 	   clk_in, // external input clock
	      input wire   from_pc, // pin 9 UART RxD (form PC to Dev)
	      output wire  to_ir,
	      input wire   i_serial_data,
	      output wire  o_serial_data,
	      output 	   test1,
	      output 	   test2,
 	      output 	   test3,
	      output [4:0] led,

	      // DUT Interface
	      output 	   tb_i_rst, 
	      output 	   tb_input_clk,
	      output 	   tb_input_adder_start,
	      output reg   tb_adder_ctrl,
	      output reg   tb_adder_subtract,
	      output [7:0] tb_r1,
	      output [7:0] tb_r2,
	      output [7:0] tb_adder_ctrl_char_wire,

	      input [4:0]  adder_o_data,
	      input 	   adder_o_rdy,
	      input 	   o_debug_test1,
	      input 	   o_debug_test2,
	      input 	   o_debug_test3,
	      input [7:0]  debug_led
	      );

   //
   // print the "LEDS" to the screen
   //
   task displayLattice(input [4:0] leds, input [3:0] a, input [3:0] b, input op);

      begin
	 #1;
	 $display("    [%c]", leds[2] ? "*":".");
	 $display(" [%c][%c][%c] ", leds[1] ? "*":".", leds[4] ? "*" : ".", leds[3] ? "*" : ".");
	 $display("    [%c]", leds[0] ? "*":".");
	 $display($time,,, ": %d  %d  %c  -> %d %d", a, b, op ? "-" : "+", leds[4], leds[3:0]);
	 $display;
      end	 
   endtask

   task pushOp(
	       input [7:0] 	operand,
	       output reg [3:0] r1,
	       output reg [3:0] r2,
	       output reg 	tb_adder_subtract,
	       output reg       tb_input_adder_start,
	       input 		clr);

      begin: pushOp
	 reg [1:0] numOperands;	 
	 if (clr) begin
	    numOperands = 2'b0;
	    tb_adder_subtract = 0;
	    tb_input_adder_start = 0;
	 end
	 else begin
	    if (numOperands == 2'b0) begin
	       r1 = operand[3:0];
	       numOperands = numOperands + 1;
	    end
	    else if (numOperands == 2'b1) begin
	       r2 = operand[3:0];
	       numOperands = numOperands + 1;
	    end
	    else if (numOperands == 2'b10) begin
	       tb_input_adder_start <= 1'b1;
	       tb_adder_subtract <= (operand == "+") ? 1'b0 : 1'b1;
	       numOperands = 2'b0;
	    end
	 end
      end
   endtask 
   

   always @(adder_o_data) begin
      displayLattice(adder_o_data, tb_r1, tb_r2, tb_adder_subtract);
   end
   
   initial begin
//      $monitor($time,,, "%d  %d  %c  -> %d %d", a, b, op, c4, sum);
      pushOp(8'b0, tb_r1, tb_r2, tb_adder_subtract, tb_input_adder_start, 1'b1);
      #42;
      
      pushOp(8'd4, tb_r1, tb_r2, tb_adder_subtract, tb_input_adder_start, 1'b0);
      #42;
      
      pushOp(8'd5, tb_r1, tb_r2, tb_adder_subtract, tb_input_adder_start, 1'b0);
      #42;

      pushOp("+", tb_r1, tb_r2, tb_adder_subtract, tb_input_adder_start, 1'b0);
      #42;
      $finish;
      
   end

   initial begin
      input_clk <= 1'b0;
   end
   
   always @* begin
      #42;
      input_clk <= ~input_clk;
   end
endmodule // tb_sft
