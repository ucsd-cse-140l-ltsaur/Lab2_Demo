module fake_buart(
		  input 	   clk,
		  input 	   resetq,
		  input 	   rx,
		  output 	   tx,
		  input 	   rd,
		  input 	   wr,
		  output reg 	   valid,
		  output           busy,
		  input [7:0] 	   tx_data,
		  output reg [7:0] rx_data,

		  // TB interface
		  output reg [7:0] fa_data,
		  output reg 	   fa_valid,
		  input [7:0] 	   to_dev_data,
		  input 	   to_dev_data_valid
		  );

   reg 			       to_dev_data_validD;    // delay one cycle
   
   assign busy = 1'b0;
   
   always @(posedge clk) begin
      if(resetq) begin
	 rx_data <= 8'b0;
	 fa_data <= 8'b0;
	 fa_valid <= 1'b0;
	 to_dev_data_validD <= 1'b0;
	 valid <= 1'b0;
      end
      else begin

	 // from tb to the device
	 to_dev_data_validD <= to_dev_data_valid;
	 rx_data <= to_dev_data;
	 valid   <= to_dev_data_valid & ~to_dev_data_validD;

	 // from dev to the tb
	 fa_data <= tx_data;
	 fa_valid <= wr;
      end // else: !if(resetq)
   end
endmodule
