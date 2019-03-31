module top_sft;

   wire       clk12M;		// 12 mhz clock
   wire [4:0] leds;
   wire [7:0] tb_rx_data;
   wire       tb_rx_data_rdy;
   wire [7:0] ut_tx_data;
   wire       ut_tx_data_rdy;
       
   latticehx1k latticehx1k(
			   .i_rst(),
			   .sd(),
			   .clk_in(clk12M),
			   .from_pc(),
			   .to_ir(),
			   .o_serial_data(),
			   .test1(),
			   .test2(),
			   .test3(),
			   .led(leds),

			   .tb_rx_data(tb_rx_data),
			   .tb_rx_data_rdy(tb_rx_data_rdy),
			   .ut_tx_data(ut_tx_data),
			   .ut_tx_data_rdy(ut_tx_data_rdy)
			   );
   

   tb_sft tb_sft (
		  .clk12m(clk12m),
		  .ut_tx_data(ut_tx_data),
		  .ut_tx_data_rdy(ut_tx_data_rdy),
		  .tb_rx_data(tb_rx_data),
		  .tb_rx_data_rdy(tb_rx_data_rdy),
		  .leds(leds)
		  );

 	     

endmodule // top_sft
