//
// software testbench for simulation
//
module tb_sft(
	      output reg   tb_sim_rst,
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

   task sendByte(input [7:0] byt);
     begin
		@(posedge clk12m);


		tb_rx_data_rdy = 1;
		tb_rx_data = byt;
		@(posedge clk12m);
		tb_rx_data_rdy = 0;
     end
   endtask


   initial begin
      tb_sim_rst <= 0;
      clk12m <= 0;
      tb_rx_data = 8'b0;
      tb_rx_data_rdy = 1'b0;
      #336;
      tb_sim_rst <= 1;
      #336;
      #336;
      #336;
      #336;
      tb_sim_rst <= 0;
   end

   always @(*) begin
      #41;
      clk12m <= ~clk12m;
   end

   always @(leds) begin
      displayLattice(leds);
   end

   initial begin
      #336;
      #336;
      #336;
      #336;
      #336;
	@(posedge clk12m);
	tb_rx_data = 8'b0;
	tb_rx_data_rdy = 1'b0;
	sendByte(8'd3);
	sendByte(8'd4);
	sendByte("+");

	sendByte(8'd5);
	sendByte(8'd2);
	sendByte("-");
        $finish;
      
   end

endmodule // tb_sft
