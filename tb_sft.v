//
// software testbench for simulation
//
module tb_sft(
	      output reg   clk12m,
	      input [7:0]  ut_tx_data,
	      input 	   ut_tx_data_rdy,

	      output reg [7:0] tb_rx_data,
	      output reg   tb_rx_data_rdy,

	      input [4:0]  leds
	      );
   

   //
   // print the "LEDS" to the screen
   //
   task displayLattice(input [4:0] leds);
      begin
	 #1;
	 $display("    [%c]", leds[2] ? "*":".");
	 $display(" [%c][%c][%c] ", leds[1] ? "*":".", leds[4] ? "*" : ".", leds[3] ? "*" : ".");
	 $display("    [%c]", leds[0] ? "*":".");
//	 $display($time,,, ": %d  %d  %c  -> %d %d", a, b, op ? "-" : "+", leds[4], leds[3:0]);
	 $display;
      end	 
   endtask

   initial begin
      clk12m <= 0;
   end
   always @(*) begin
      #41;
      clk12m <= ~clk12m;
   end

   task sendByte(input clk, input [7:0] byt, output [7:0] obyt, output ordy);
      
     begin
	@(posedge clk);
	obyt = byt;
	ordy = 1;
	@(posedge clk);
	obyt = 8'b0;
	ordy = 0;
	$write("%d", byt);
     end
   endtask

   always @(leds) begin
      displayLattice(leds);
   end
   
   initial begin

      sendByte(clk12m, 8'd4, tb_rx_data, tb_rx_data_rdy);
      sendByte(clk12m, 8'd3, tb_rx_data, tb_rx_data_rdy);
      sendByte(clk12m, "+", tb_rx_data, tb_rx_data_rdy);
      
      sendByte(clk12m, 8'd4, tb_rx_data, tb_rx_data_rdy);
      sendByte(clk12m, 8'd4, tb_rx_data, tb_rx_data_rdy);
      sendByte(clk12m, "+", tb_rx_data, tb_rx_data_rdy);
      
      sendByte(clk12m, 8'd4, tb_rx_data, tb_rx_data_rdy);
      sendByte(clk12m, 8'd5, tb_rx_data, tb_rx_data_rdy);
      sendByte(clk12m, "+", tb_rx_data, tb_rx_data_rdy);
      $finish;
      
   end

endmodule // tb_sft
