
// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//   It is synthesisable for Lattice iCEstick 40HX.  
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// --------------------------------------------------------------------
//           
//                     Lih-Feng Tsaur
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------


//
// Revision History : 0.0

//
// top level for lab2
//
module latticehx1k(
		   output 	sd,
 	     
		   input 	clk_in,
		   input wire 	from_pc,
		   output wire 	to_ir,
		   output wire 	o_serial_data,
		   output 	test1,
		   output 	test2,
		   output 	test3,
		   output [4:0] led,

		   // for software only
		   input 	tb_sim_rst,
		   input [7:0]  tb_rx_data,      // pretend data coming from the uart
		   input        tb_rx_data_rdy,  //

		   output [7:0] ut_tx_data,      // shortcut, data from the fake tx uart
		   output       ut_tx_data_rdy

		);
   

   // we have two test benches.
   // tb_hdw is synthesized and provides a uart interface
   // tb_sft is not synthesized and is used to test the design in a simulation environment

   // interface signals btw tb and dut
   wire i_rst;			// reset signal from testbench to dut
   wire tb_clk; 		// clock signal for dut
   wire input_adder_start;
   wire adder_ctrl;
   wire adder_substrate;
   wire [7:0] r1_wire;
   wire [7:0] r2_wire;
   
   wire [7:0] adder_o_data;
   wire       adder_o_rdy;

   wire       o_debug_test1;
   wire       o_debug_test2;
   wire       o_debug_test3;
   wire       [7:0]debug_led;

   wire [7:0] adder_ctrl_char_wire;

   SE_serial_io serial_io (
		  .clk_in(clk_in),
		  .from_pc(from_pc),
		  .to_ir(to_ir),
		  .i_serial_data(i_serial_data),
		  .o_serial_data(o_serial_data),
		  .test1(test1),
		  .test2(test2),
		  .test3(test3),
		  .led(led),

		  .i_rst(i_rst),
		  .input_clk(tb_clk),
		  .input_adder_start(input_adder_start),
		  .adder_ctrl(adder_ctrl),
		  .adder_substrate(adder_substrate),
		  .r1_wire(r1_wire),
		  .r2_wire(r2_wire),
		  .adder_ctrl_char_wire(adder_ctrl_char_wire),
		  .adder_o_data(adder_o_data),
		  .adder_o_rdy(adder_o_rdy),
		  .o_debug_test1(o_debug_test1),
		  .o_debug_test2(o_debug_test2),
		  .o_debug_test3(o_debug_test3),
		  .debug_led(debug_led),

			   .tb_rx_data(tb_rx_data),
			   .tb_rd_data_rdy(tb_rx_data_rdy),
			   .ut_tx_data(ut_tx_data),
			   .ut_tx_data_rdy(ut_tx_data_rdy),
			   .tb_sim_rst(tb_sim_rst)



		  );

   Lab2_140L Lab_UT(
		    .i_rst   (i_rst)                     , // reset signal
		    .i_clk_in  (tb_clk)               ,
		    .i_data_rdy (input_adder_start)      , //(posedge)
//		    .i_ctrl_signal (adder_ctrl)          , 
		    .i_substract_signal (adder_substrate), 
		    .i_r1    (r1_wire[7:0])                        , // 8bit number 1
		    .i_r2    (r2_wire[7:0])                        , // 8bit number 1
//		    .i_cin   ( )                          , //carry in
//		    .i_ctrl (adder_ctrl_char_wire[7:0])            , //ctrl letter
		    .o_sum   (adder_o_data[3:0])         ,
		    .o_cout  (adder_o_data[4])           ,
		    .o_rdy (adder_o_rdy)                 , //output rdy pulse, 2 i_clk_in cycles
//		    .o_debug_test1 (o_debug_test1)         , //output test point1
//		    .o_debug_test2 (o_debug_test2)         , //output test point2
//		    .o_debug_test3 (o_debug_test3)         , //output test point3
		    .o_debug_led   (debug_led[7:0])        //output LED
);


endmodule // lab2_top

module SE_serial_io(
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
	      output       i_rst, 	   
	      output 	   wire input_clk,
	      output 	   wire input_adder_start,
	      output 	   reg adder_ctrl,
	      output 	   reg adder_substrate,
	      output wire [7:0] r1_wire,
	      output wire [7:0] r2_wire,
	      output wire [7:0] adder_ctrl_char_wire,

	      input [7:0]  adder_o_data,
	      input 	   adder_o_rdy,
	      input 	   wire o_debug_test1,
	      input 	   wire o_debug_test2,
	      input 	   wire o_debug_test3,
	      input wire [7:0]  debug_led,

		  
                    input [7:0] tb_rx_data,
		    input tb_rd_data_rdy,
		    output [7:0] ut_tx_data,
		    output ut_tx_data_rdy,

              // simulation only
              input tb_sim_rst   // reset signal from the test bench to get rid of some x's

	      );
   

   // UART of Lattice iCEstick

   //module uart (
   //         
   //         input wire   clk_in        ,  //etern pin defined in pcf file
   //         input wire   from_pc       ,  //pin 9 UART RxD (from PC to Dev)
   //         output wire  to_ir         ,
   //         output wire  sd            ,
   //         input wire   i_serial_data ,
   //         output wire  o_serial_data ,
   //         
   //         output       test1         ,
   //         output       test2         ,
   //         output       test3         ,
   //         output [7:0] led   
   //         );
   //   wire 		  clk_in; // external clock input
   //   wire                   from_pc;  // pin 9 UART RxD (from PC to Dev)
   
  		  
   
	
   // parameters (constants)
   parameter clk_freq = 27'd12000000;  // in Hz for 12MHz clock

   reg [26:0] 		   rst_count ;
   wire 		   CLKOP ;
   wire 		   CLKOS ;        

   wire [7:0] 		   o_rx_data       ; //output from UART RX
   reg [7:0] 		   uart_rx_data    ; //latch UART rx data for delay pulse
   
   wire 		   o_rx_data_ready ; //output from UART RX
   wire 		   uart_rx_rdy     ; //UART RX is read
   wire 		   uart_rx_data_rdy; //UART data is latched
   
//   wire 		   adder_o_rdy     ;
   wire 		   adder_data_ready; //narrow pulse for uart tx to tx data
   wire 		   adder_rdy       ; //wider pulse for local logic to latch in data
//   wire [7:0] 		   adder_o_data    ;

   wire 		   i_start_tx      ;  //connect to UART TX
   wire [7:0] 		   i_tx_data       ;  //connect to UART TX
   wire 		   tsr_is_empty    ;  //has data tx out   
 
   // internal reset generation
   // no more than 0.044 sec reset high
   wire [7:0] 		   i_rst_test; 
   //assign i_rst_test[7:0] = {uart_rx_data[7]^1'b0, uart_rx_data[6]^1'b1,                    0, uart_rx_data[4]^1'b0,
   //                          uart_rx_data[3]^1'b0, uart_rx_data[2]^1'b0, uart_rx_data[1]^1'b1, uart_rx_data[0]^1'b1};
   // --- use esc char to reset (0x1B)
   wire is_uart_rx_b7_0, is_uart_rx_b7_1;
   wire is_uart_rx_b6_0, is_uart_rx_b6_1;
   wire is_uart_rx_b5_0, is_uart_rx_b5_1;
   wire is_uart_rx_b4_0, is_uart_rx_b4_1;
   wire is_uart_rx_b3_0, is_uart_rx_b3_1;
   wire is_uart_rx_b2_0, is_uart_rx_b2_1;
   wire is_uart_rx_b1_0, is_uart_rx_b1_1;
   wire is_uart_rx_b0_0, is_uart_rx_b0_1;
   assign i_rst_test[7:0] = {is_uart_rx_b7_0, is_uart_rx_b6_0, is_uart_rx_b5_0, is_uart_rx_b4_1,
                             is_uart_rx_b3_1, is_uart_rx_b2_0, is_uart_rx_b1_1, is_uart_rx_b0_1};
   
   always @ (posedge clk_in) begin
      if (rst_count >= (clk_freq/2)) begin
         
         if(&i_rst_test | tb_sim_rst) begin //letter is ESC 
            //generate reset pulse to adder
            rst_count <= 0;
         end
      end else begin                   
         rst_count <= rst_count + 1;
      end
      
   end
   
`ifdef HW
   	assign i_rst = ~rst_count[19] ;
`else
        assign i_rst = tb_sim_rst | ~rst_count[3];
`endif

	  
   
`ifdef HW
   // PLL instantiation
   ice_pll ice_pll_inst(

`else
   fake_pll ice_pll_inst(
`endif       
			.REFERENCECLK ( clk_in        ),  // input 12MHz
			.PLLOUTCORE   ( CLKOP         ),  // output 38MHz
			.PLLOUTGLOBAL ( PLLOUTGLOBAL  ),
			.RESET        ( 1'b1  )
			);
   reg [3:0] clk_count ; 
   reg 	     CLKOS_reg ;
   assign CLKOS = CLKOS_reg;
   
   // generate bit clk ==> look like needs to be 20 cycles or 
   // need to be 50% duty cycle
   // 20.62 = 38M / (115200 x16)  err = 3%
   // 10.31 = 38M / (230400 x16)  err = 3%
   //  5.15 = 38M / (460800 x16)  err = 3%
   always @ (posedge CLKOP) begin
      
      if(i_rst) begin
	 clk_count <= 0;
	 CLKOS_reg <= 0;
      end
      else begin
         if ( clk_count == 9 ) clk_count <= 0 ;
         else clk_count <= clk_count + 1 ;          //0 - 9
         
	 if ( clk_count == 9 ) CLKOS_reg <= ~CLKOS_reg ;    //1.9Mhz
      end
   end


`ifdef HW   
   // UART RX instantiation
   uart_rx_fsm uut1 (                   
					.i_clk                 ( CLKOP           ), //38MHz
					.i_rst                 ( i_rst           ),
					.i_rx_clk              ( CLKOS           ),
					.i_start_rx            ( 1'b1            ),
					.i_loopback_en         ( 1'b0            ),
					.i_parity_even         ( 1'b0            ),
					.i_parity_en           ( 1'b0            ),               
					.i_no_of_data_bits     ( 2'b10           ),  
					.i_stick_parity_en     ( 1'b0            ),
					.i_clear_linestatusreg ( 1'b0            ),               
					.i_clear_rxdataready   ( 1'b0            ),
					.o_rx_data             ( o_rx_data       ), 
					.o_timeout             (                 ),               
					.bit_sample_en         ( bit_sample_en   ), 
					.o_parity_error        (                 ),
					.o_framing_error       (                 ),
					.o_break_interrupt     (                 ),               
					.o_rx_data_ready       ( o_rx_data_ready ),
					.i_int_serial_data     (                 ),
					.i_serial_data         ( from_pc         ) // from_pc UART signal
					);
`else // !`ifdef HW
   tb_fake_uart_rx uut1 (
			 .i_clk (CLKOP),
			 .i_rst(i_rst),
			 .o_rx_data_ready (o_rd_data_ready),
			 .o_rx_data(o_rx_data),
			 .tb_rx_data(tb_rx_data),
			 .tb_rx_data_rdy(tb_rx_data_rdy));
`endif   


   reg [3:0] count ;
   reg [17:0] shift_reg1 ;  //increase by 1 to delay strobe
   reg [19:0] shift_reg2 ;
   wire [15:0] shift_reg1_wire;
   
   always @ (posedge CLKOS) count <= count + 1 ; //1.9MHz/16 = 1187500 3% error from 115200
   
   always @ (posedge CLKOP) begin  //38MHz
      if(i_rst) begin
         shift_reg2[19:0] <= 20'h00000;
      end
      else begin
         shift_reg2[19:0] <= {shift_reg2[18:0], o_rx_data_ready} ; //38Mhz
      end
   end
   
   wire rx_rdy;    // OR of shift_reg2;
   always @ (posedge CLKOS) begin  //1.9MHz
      if(i_rst) begin
         shift_reg1[17:0] <= {2'b00, 16'h0000};
      end
      else begin
         shift_reg1[17:0] <= {shift_reg1[16:0], rx_rdy} ; //1.9MHz
      end     
   end
   
   //implicity defined rx_rdy as 1 bit wire
   assign rx_rdy = |shift_reg2 ; //catching 0...000 (20 bit 0s)
   assign uart_rx_rdy = |shift_reg1 ; //used to latch in uart rx data
   
   //wire uart_rx_rdy4tx = shift_reg1[1]; //used to set up the mux of uart rx or local data
   
   //delay uart_rx_data_rdy strob by 1 1.9MHz clk tick
   assign shift_reg1_wire[15:0] = shift_reg1[16:1];
   assign uart_rx_data_rdy = ((&i_rst_test))? 0:(|shift_reg1_wire); 
   //latch in UART Rx Data
   // this logic is in clk_in domain and 
   // uart_rx_rdy is at CLKOS 1.9MHz from PLL
   // sync the signal first
   reg [1:0] uart_rx_rdy_sync_tap;
   wire      l_uart_rx_rdy_sync_posedge = uart_rx_rdy_sync_tap[0] & ~uart_rx_rdy_sync_tap[1];
   
   always @ (posedge clk_in)
     begin
	if(i_rst) begin
           uart_rx_rdy_sync_tap[1:0] <= 2'b00;
           uart_rx_data[7:0] <= 8'h00;
	end
	else begin
           uart_rx_rdy_sync_tap[1:0] <= {uart_rx_rdy_sync_tap[0], uart_rx_rdy};
	   
           if (l_uart_rx_rdy_sync_posedge) 
             uart_rx_data[7:0] <= {o_rx_data[7:6], o_rx_data[5], o_rx_data[4:0]} ; //flip bit5 to convert to uppter case
           else
             uart_rx_data <= uart_rx_data;
	end
     end
   
   

   reg [7:0] r1, r2; //4-bit buffers
   reg [1:0] adder_input_count; //internal state machine
   reg 	     adder_start;
   reg [7:0] adder_ctrl_char;
   
   wire [7:0] adder_p_test;      // decode '+'
   wire [7:0] adder_n_test;      // decode '-'
   wire [3:0] adder_num_test;    // valid number 0-9:;<=>?
                                 // FIXME - need to add a-f as valid numbers
   wire       adder_p_test_wire; // decode '+'
   wire       adder_n_test_wire; // decode '-'
   wire       adder_valid_num_wire; // decode valid number
   
   assign is_uart_rx_b0_1 = uart_rx_data[0] ^ 1'b0;
   assign is_uart_rx_b1_1 = uart_rx_data[1] ^ 1'b0;
   assign is_uart_rx_b2_1 = uart_rx_data[2] ^ 1'b0;
   assign is_uart_rx_b3_1 = uart_rx_data[3] ^ 1'b0;
   assign is_uart_rx_b4_1 = uart_rx_data[4] ^ 1'b0;
   assign is_uart_rx_b5_1 = uart_rx_data[5] ^ 1'b0;
   assign is_uart_rx_b6_1 = uart_rx_data[6] ^ 1'b0;
   assign is_uart_rx_b7_1 = uart_rx_data[7] ^ 1'b0;
   assign is_uart_rx_b0_0 = uart_rx_data[0] ^ 1'b1;
   assign is_uart_rx_b1_0 = uart_rx_data[1] ^ 1'b1;
   assign is_uart_rx_b2_0 = uart_rx_data[2] ^ 1'b1;
   assign is_uart_rx_b3_0 = uart_rx_data[3] ^ 1'b1;
   assign is_uart_rx_b4_0 = uart_rx_data[4] ^ 1'b1;
   assign is_uart_rx_b5_0 = uart_rx_data[5] ^ 1'b1;
   assign is_uart_rx_b6_0 = uart_rx_data[6] ^ 1'b1;
   assign is_uart_rx_b7_0 = uart_rx_data[7] ^ 1'b1;
   
   assign adder_p_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_0 , is_uart_rx_b5_1, is_uart_rx_b4_0,
                               is_uart_rx_b3_1 , is_uart_rx_b2_0 , is_uart_rx_b1_1, is_uart_rx_b0_1};
   
   assign adder_n_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_0 , is_uart_rx_b5_1, is_uart_rx_b4_0,
                               is_uart_rx_b3_1 , is_uart_rx_b2_1 , is_uart_rx_b1_0, is_uart_rx_b0_1};
   
   assign adder_num_test[3:0] ={is_uart_rx_b7_0, is_uart_rx_b6_0 , is_uart_rx_b5_1, is_uart_rx_b4_1};      
   
   assign  adder_pluse_wire     = (&adder_p_test);
   assign  adder_substrate_wire = (&adder_n_test);
   assign  adder_valid_num_wire = (&adder_num_test);
   
   //------------------------------------------------------------------------
   // use uart_rx_rdy to make sure UART Rx data is latched in
   // logci is running at clk_in domain, uart_rx_data_rdy is running at 
   // CLKOS 1.9MHz from PLL.  resync this signal first
   // smooth out uart rx ready first
   // the logic is changed to use clk_in to verify the edge and a smooth filter to 
   // reduce the noise uart rx rdy signal
   reg [7:0]  l_uart_rx_data_rdy_smoth_tap;
   reg [1:0]  l_uart_rx_data_rdy_tap;
   wire       uart_rx_data_rdy_sync_posedge = l_uart_rx_data_rdy_tap[0] & ~l_uart_rx_data_rdy_tap[1];
   wire       uart_rx_data_rdy_smooth_level = l_uart_rx_data_rdy_smoth_tap[0] & l_uart_rx_data_rdy_smoth_tap [1] & 
              ~l_uart_rx_data_rdy_smoth_tap[6] & ~l_uart_rx_data_rdy_smoth_tap[7];
   
   always @ (posedge clk_in) begin
      if(i_rst) begin
         l_uart_rx_data_rdy_tap[1:0] <= 2'b00;
         adder_input_count <= 2'b00;
         adder_start <= 1'b0;
         adder_ctrl <= 1'b0;
         r1 <= 8'h00;
         r2 <= 8'h00;
         adder_ctrl_char <= 0;
      end
      else begin
         l_uart_rx_data_rdy_smoth_tap[7:0] <= {l_uart_rx_data_rdy_smoth_tap[6:0], uart_rx_data_rdy};
         l_uart_rx_data_rdy_tap[1:0] <= {l_uart_rx_data_rdy_tap[0], uart_rx_data_rdy_smooth_level};
         //l_uart_rx_data_rdy_tap[1:0] <= {l_uart_rx_data_rdy_tap[0], uart_rx_data_rdy};
	 
         if (uart_rx_data_rdy_sync_posedge) begin
            if ( adder_input_count >= 2'b10) begin
               if ( adder_pluse_wire) begin // 3th letter is '+' or '-'
                  adder_substrate <= 0;
                  adder_start <= 1'b1;
               end else 
                 if ( adder_substrate_wire) begin
                    adder_substrate <= 1'b1;
                    adder_start <= 1'b1;
                 end 
                 else begin
                    adder_substrate <= 0;
                 end     
               adder_ctrl <= 0;
               adder_input_count <= 2'b00;
            end else 
              begin
                 if(adder_valid_num_wire) begin
                    if ( adder_input_count == 2'b00)
                      r1[7:0] <= uart_rx_data[7:0];
                    else if ( adder_input_count == 2'b01)
                      r2[7:0] <= uart_rx_data[7:0];                       
                    adder_input_count <= adder_input_count + 1;
                    adder_ctrl <= 0;
                 end 
                 else begin 
                    adder_ctrl_char[7:0] <= uart_rx_data[7:0];
                    adder_ctrl <= 1;
                    adder_input_count <= 2'b00;
                 end
                 adder_start <= 0;
              end
         end
         else begin
            adder_substrate <= adder_substrate;
            adder_input_count <= adder_input_count;
	    
            adder_start <= adder_start;
            r1 <= r1;
            r2 <= r2;
            
            adder_ctrl <= adder_ctrl;
            adder_ctrl_char <= adder_ctrl_char;
         end
      end
   end
   
   //-------------------- Lab2
   assign adder_ctrl_char_wire[7:0] = adder_ctrl_char[7:0];
   assign r1_wire[7:0] = r1[7:0];
   assign r2_wire[7:0] = r2[7:0];
   
   // define input clk
   assign input_clk = clk_in;  //CLKOP or clk_in or CLKOS
   reg [2:0]  adder_start_tap;
   
   // generate start strob, sync to input clk
   always @ (posedge input_clk)begin
      if(i_rst)
        adder_start_tap[2:0] <= 3'b000;
      else 
        adder_start_tap[2:0] <= {adder_start_tap[1:0], adder_start};
   end
   //wire input_adder_start;
   assign input_adder_start = adder_start_tap[0] & ~adder_start_tap[2];
   
   //assign adder_o_data[7:5] 
   //convert adder_o_data 000~1FF to ASCII chars @,A,B,C,...,_
   wire [7:0] o_DUT2UART_data = {3'b010, adder_o_data[4:0]};
   //--------------------------------  -----------------------------------------------------------
   // generate adder data ready pulse.
   // local variables
   reg [19:0] adder_shift_reg1 ;  
   reg [19:0] adder_shift_reg2 ;
   wire       adder_shift_tmp;
   reg 	      adder_data_rdy;
   reg 	      adder_data_rdy_sync;
   reg [5:0]  adder_data_rdy_tap;
   wire       adder_data_rdy_tap_tst = adder_data_rdy_tap[0] & adder_data_rdy_tap[1] & ~adder_data_rdy_tap[5];
   reg [3:0]  uart_tx_bit_delay_tap;
   reg [1:0]  uart_tx_bit_clk_posedge;
   
   always @ (posedge CLKOP)  //38MHz
     begin
	if(i_rst) begin
           uart_tx_bit_clk_posedge <= 2'b00;
           uart_tx_bit_delay_tap <= 4'h0;
           adder_data_rdy_tap[5:0] <= 6'b00;
           adder_data_rdy      <= 1'b0;
           adder_data_rdy_sync <= 1'b0;
           adder_shift_reg2[19:0] <= 20'h00000;
	end
	else begin
           adder_shift_reg2[19:0] <= {adder_shift_reg2[18:0], adder_data_rdy_sync};
           
           //catching the rising edge of adder_o_rdy
           adder_data_rdy_tap[5:0] <= {adder_data_rdy_tap[4:0], adder_o_rdy};  
           
           //catching uart tx block i_clk_in, which is a slow ck @ 1.9MHz/16
           uart_tx_bit_clk_posedge[1:0] <= {uart_tx_bit_clk_posedge[0], count[3]};
           
           // latch in @ posedge of adder_o_rdy 
           // and wait for current uart tx is finished
           // ignore rising edge if preparing for tx one byte as no buffer at tx
           if(adder_data_rdy_tap_tst & !adder_shift_tmp & !adder_data_rdy)  begin
              uart_tx_bit_delay_tap <= 1'h0;
              adder_data_rdy <= 1'b1;
           end         
           else if(adder_shift_tmp)  begin
              adder_data_rdy <= 1'b0;  //clear the status as only one bit is needed in the tap line
           end
           else begin
              adder_data_rdy <= adder_data_rdy;
           end
           
           
           //set adder_data_rdy_sync after tx uart is idle
           if(uart_rx_rdy | !tsr_is_empty) begin //wait for tx release and tx fifo empty 
              uart_tx_bit_delay_tap <= 1'h0;
              adder_data_rdy_sync <= 1'b0;
           end else
             begin
		//wait until the previous tx is done + 2 bit cycles (3 i_clks posedge to uart_tx)
		if(adder_data_rdy) begin  
		   
                   if((uart_tx_bit_clk_posedge[0] & !uart_tx_bit_clk_posedge[1])) 
                     uart_tx_bit_delay_tap[3:0] <= {uart_tx_bit_delay_tap[2:0], 1'b1};
                   
                   if(uart_tx_bit_delay_tap[3])                        
                     adder_data_rdy_sync <= 1'b1;
                   
		end else 
		  begin
                     adder_data_rdy_sync <= 1'b0;
		  end
             end
	end
     end

   assign adder_shift_tmp = |adder_shift_reg2 ; //catching 0...000 (20 bit 0s)

   //always @ (posedge CLKOP) adder_shift_reg2[19:0] <= {adder_shift_reg2[18:0], adder_data_rdy_sync} ; //38Mhz
   always @ (posedge CLKOS) begin  //1.9MHz
      if(i_rst)
        adder_shift_reg1[19:0] <= 20'h00000;
      else
        adder_shift_reg1[19:0] <= {adder_shift_reg1[18:0], adder_shift_tmp} ; //1.9MHz
   end

   //delay adder_rdy strob by 1 1.9MHz clk tick
   wire [19:0] adder_shift_reg1_wire1 = adder_shift_reg1[19:0]; //use wire to control the starting time
   assign adder_rdy = |adder_shift_reg1_wire1; //last for 20 1.9MHz clk

   reg 	       adder_tx_sm;
   reg [3:0]   tx_sm_count;

   //count is on PLL same as adder_rdy
   always @ (posedge count[3]) begin  //118KHz bit clk (16 1.9MHz clk) is enough to sample adder_rdy
      if(i_rst) begin
         adder_tx_sm <= 1'b0;
         //db_test_point <= 1'h0;
      end
      else begin
         if(adder_tx_sm) 
           begin
              if(tsr_is_empty) begin
                 
                 tx_sm_count [3:0] <= {tx_sm_count [2:0], 1'b0};
                 
                 if(tx_sm_count[3] == 1'b1)
                   adder_tx_sm <= 1'b0;
              end
           end 
         else if(adder_rdy) 
           begin
              //db_test_point <= 1'h0;        
              tx_sm_count [3:0] <= 1'h1;
              adder_tx_sm <= 1'b1;
           end
      end
   end
   wire adder_tx_rdy_hold = adder_tx_sm;

   wire [15:0] adder_shift_reg1_wire2 = adder_shift_reg1[17:2]; //use wire to control the starting time
   assign adder_data_ready = |adder_shift_reg1_wire2;

   wire [7:0]  o_uart_data_byte;

   assign o_uart_data_byte [7:0] = (adder_tx_rdy_hold)? o_DUT2UART_data[7:0] : uart_rx_data[7:0];

   //determine the input -- from adder or loopback from UART RX
   assign  i_start_tx = adder_data_ready | uart_rx_data_rdy;
   assign  i_tx_data[7:0] = o_uart_data_byte[7:0];
   //assign    i_tx_data[7:0] = uart_rx_data[7:0];
   //assign  i_start_tx = uart_rx_data_rdy;

`ifdef HW
   // UART TX instantiation
   uart_tx_fsm uut2(                                
						    .i_clk                 ( count[3]      ),   
						    .i_rst                 ( i_rst         ),   
						    .i_tx_data             ( i_tx_data  ),   
						    .i_start_tx            ( i_start_tx    ),   
						    .i_tx_en               ( 1'b1          ),   
						    .i_tx_en_div2          ( 1'b0          ),   
						    .i_break_control       ( 1'b0          ),   
						    .o_tx_en_stop          (  ),                
						    .i_loopback_en         ( 1'b0          ),   
						    .i_stop_bit_15         ( 1'b0          ),   
						    .i_stop_bit_2          ( 1'b0          ),   
						    .i_parity_even         ( 1'b0          ),   
						    .i_parity_en           ( 1'b0          ),   
						    .i_no_of_data_bits     ( 2'b11         ),   
						    .i_stick_parity_en     ( 1'b0          ),   
						    .i_clear_linestatusreg ( 1'b0          ),   
						    .o_tsr_empty           (tsr_is_empty),                
						    .o_int_serial_data     (  ),                
						    .o_serial_data_local   ( o_serial_data )    //pin 8 UART TXD (from Dev to PC)
						    );                                          

`else // !`ifdef HW
    tb_fake_uart_tx uut2 (
			  .i_clk( count[3] ),
			  .i_rst( i_rst ),
			  .i_tx_data( i_tx_data ),
			  .i_start_tx( i_start_tx ),
			  .ut_tx_data( ut_tx_data ),
			  .ut_tx_data_rdy( ut_tx_data_rdy)
			  );

`endif
   /*
    //-------------------------------------------------------------------------------
    // write to IR tx
    reg [4:0] ir_tx_reg ;  
    wire ir_tx ;
    
    assign sd = 0 ;  // 0: enable  
    always @ (posedge CLKOP) ir_tx_reg[4:0] <= {ir_tx_reg[3:0], bit_sample_en} ; 
    assign ir_tx = |ir_tx_reg ;
    assign to_ir = ir_tx & ~from_pc ;
    
    // test points
    assign test1 =  to_ir ;   //data to IR 
    assign test2 =  from_pc ; //RxD
    assign test3 =  i_rst ;   //internal reset (active low for 0.5sec)
    //---------------------------------------------------------------------------------
    */

   // DUT module can control 3 test pins
   assign test1 =  o_debug_test1;   // 
   assign test2 =  o_debug_test2;   //
   assign test3 =  o_debug_test3;   //
   //-----------------------------------------------------------------------------------
   //-----------------------------------------------------------------------------------
   // LED and DEBUG
   //sample and hold reg
   reg [4:0]   debug_test;
   reg [4:0]   debug_test1;
   reg [4:0]   debug_test2;
   reg [4:0]   debug_test3;

   //from wrapper to adder
   wire        db_uart_rx_rdy = uart_rx_rdy;
   wire        db_uart_rx_data_rdy = uart_rx_data_rdy;
   wire        db_adder_input_count0 = adder_input_count[0];
   wire        db_adder_start = adder_start;
   wire        db_input_adder_start = input_adder_start;
   wire        db_adder_valid_num_wire = adder_valid_num_wire;

   //from adder to wrapper
   wire        db_adder_shift_tmp = adder_shift_tmp;
   wire        db_adder_data_rdy = adder_data_rdy;
   wire        db_adder_rdy = adder_rdy;
   wire        db_adder_data_rdy_sync = adder_data_rdy_sync;
   wire        db_adder_tx_rdy_hold = adder_tx_rdy_hold;
   wire        db_adder_tx_sm = adder_tx_sm;

   wire        db_tsr_is_empty = tsr_is_empty;

   /*
    reg [1:0] db_tsr_is_empty_edge;
    wire db_tsr_is_empty_posedge;
    wire db_tsr_is_empty_negedge;

    always @ (posedge CLKOS)
    begin
    if(i_rst)
    db_tsr_is_empty_edge <= 2'b00;
    else
    db_tsr_is_empty_edge[1:0] <= {db_tsr_is_empty_edge[0], db_tsr_is_empty};
end
    assign db_tsr_is_empty_posedge = db_tsr_is_empty_edge[0] & ~db_tsr_is_empty_edge[1];
    assign db_tsr_is_empty_negedge = db_tsr_is_empty_edge[1] & ~db_tsr_is_empty_edge[0];
    */

   wire [3:0]  db_count = count[3:0];
   wire [3:0]  db_tx_sm_count = tx_sm_count[3:0];
   /*
    wire [7:0] db_uart_rx_dat_wire = uart_rx_data [7:0]
    reg [7:0] db_uart_rx_char_0;
    reg [7:0] db_uart_rx_char_1;
    reg [7:0] db_uart_rx_char_2;

    wire [3:0] db_uart_tx_bit_delay_tap = uart_tx_bit_delay_tap[3:0];
    wire [1:0] db_uart_tx_bit_clk_posedge = uart_tx_bit_clk_posedge[1:0];
    */


   /*
    //sampling rate at 38MHz at PLL domain
    //consume more pwr to catch transitions of logic
    always @ (posedge CLKOP) begin  //sample at 38MHz high speek clk
    if(i_rst) begin
    debug_test  <= 5'b00000;
    debug_test1 <= 5'b00000;
    debug_test2 <= 5'b00000;
    debug_test3 <= 5'b00000;
    end else 
    debug_test[4:0] <= {};
    
    // test0
    // output from DUT
    if(db_adder_shift_tmp)              //check this pulse ever goes high 
    debug_test[0] <= 1'b1; 
    debug_test[1] <= db_adder_shift_tmp;//check it goes low at the end
    if(db_adder_rdy)
    debug_test[2] <= 1'b1;         //check DUT module generate a pulse, should be high
    debug_test[3] <= db_adder_rdy; //strobe, check if go low
    debug_test[4] <= db_adder_tx_rdy_hold; //mux for selecting data src to uart tx
    // test1
    // output from DUT
    
    //      if(db_tsr_is_empty_posedge)
    //      debug_test1[0] <= 1'b1;
    //      if(db_tsr_is_empty_negedge)
    //      debug_test1[1] <= 1'b1;
    
    debug_test1[0] <= db_tsr_is_empty; //check if it stay high at the end
    debug_test1[1] <= db_adder_tx_sm;
    debug_test1[2] <= db_count[2] & ~db_count[3];
    
    if(db_tx_sm_count[3] & db_tx_sm_count[2]) //3:0 4'b11xx
    debug_test1[3] <= 1'b1;
    if(db_tx_sm_count[0] & ~db_tx_sm_count[3]) //3:0 4'b0xx1
    debug_test1[4] <= 1'b1;
    
    // test2
    // output from UART RX
    //      debug_test2[0] <= db_test_point[0];
    //      debug_test2[1] <= db_test_point[1];
    //      debug_test2[2] <= db_test_point[2];
    //      debug_test2[3] <= db_test_point[3];
    //      debug_test2[4] <= db_tsr_is_empty & db_adder_tx_sm;


    if(db_uart_rx_rdy)
    debug_test2[0] <= 1'b1;
    if(db_uart_rx_data_rdy)
    debug_test2[1] <= 1'b1;
    if(adder_valid_num_wire)
    debug_test2[2] <= 1'b1;
    if(db_adder_input_count0)
    debug_test2[3] <= 1'b1;
    if(db_adder_start)
    debug_test2[4] <= 1'b1;
    
    //test3
    //output from UART RX
    if(db_input_adder_start)
    debug_test3[0] <= 1'b1;
    //output to UART TX
    debug_test3[1] <= db_count[3] & ~db_count[2];
    debug_test3[2] <= db_count[2] & ~db_count[3];
    if(db_tx_sm_count[1] & ~db_tx_sm_count[3]) //3:0 4'b0x1x
    debug_test3[3] <= 1'b1;
    debug_test3[4] <= |db_tx_sm_count;  //should go to 4'b1111      
end
    */


   //sampling rate at 118KHz at PLL domain
   //used to catch slow transition or output after the operations
   //input to DUT module

   wire [7:0]  db_DUT_in1 = r1_wire[7:0];
   wire [7:0]  db_DUT_in2 = r2_wire[7:0];
   wire [7:0]  db_DUT_in3 = adder_ctrl_char_wire[7:0]; //control char
   wire        db_DUT_in4 = adder_ctrl;
   wire        db_DUT_in5 = adder_substrate;

   wire [7:0]  db_DUT_out1 = adder_o_data[7:0];

   wire        db_adder_ctrl = adder_ctrl;
   wire        db_adder_substrate = adder_substrate;

   always @ (posedge count[3]) begin  //sample at 118KHz low speek clk
      if(i_rst) begin
         debug_test  <= 5'b00000;
         debug_test1 <= 5'b00000;
         debug_test2 <= 5'b00000;
         debug_test3 <= 5'b00000;
      end else 
	begin
	   
           // test0
           // output from DUT
           debug_test[0] <= db_adder_shift_tmp;//check it goes low at the end
           debug_test[1] <= db_adder_rdy; //strobe, check if go low
           debug_test[2] <= db_adder_tx_rdy_hold; //mux for selecting data src to uart tx
	   //      if(db_tsr_is_empty_posedge)
	   //      debug_test[3] <= 1'b1;
	   //      if(db_tsr_is_empty_negedge)
	   //      debug_test[4] <= 1'b1;
           
           debug_test1[0] <= db_tsr_is_empty; //check if it stay high at the end
           debug_test1[1] <= db_adder_tx_sm;
           debug_test1[2] <= db_count[2] & ~db_count[3];
           
           // test2
           // output from UART RX
	   //      debug_test2[0] <= db_test_point[0];
	   //      debug_test2[1] <= db_test_point[1];
	   //      debug_test2[2] <= db_test_point[2];
	   //      debug_test2[3] <= db_test_point[3];
	   //      debug_test2[4] <= db_tsr_is_empty & db_adder_tx_sm;

           
           //test3
           //output from UART RX
           debug_test3[1] <= db_count[3] & ~db_count[2];
           debug_test3[2] <= db_count[2] & ~db_count[3];
           debug_test3[4] <= |db_tx_sm_count;  //should go to 4'b1111
           
	end
   end

   // MUX: select the output to LEDs
   wire [7:0] debug_CR_test;
   assign debug_CR_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_0 , is_uart_rx_b5_0, is_uart_rx_b4_0,
				is_uart_rx_b3_1 , is_uart_rx_b2_1 , is_uart_rx_b1_0, is_uart_rx_b0_1};
   assign debug_is_CR = &debug_CR_test;  

   wire [7:0] debug_DEL_test; // DEL 0x7F  
   assign debug_DEL_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_1 , is_uart_rx_b5_1, is_uart_rx_b4_1,
				 is_uart_rx_b3_1 , is_uart_rx_b2_1 , is_uart_rx_b1_1, is_uart_rx_b0_1};
   assign debug_is_DEL = &debug_DEL_test;  

   wire [7:0] debug_BS_test; // 40 = 0x28 bachspace
   assign debug_BS_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_0 , is_uart_rx_b5_1, is_uart_rx_b4_0,
				is_uart_rx_b3_1 , is_uart_rx_b2_0 , is_uart_rx_b1_0, is_uart_rx_b0_0};
   assign debug_is_BS = &debug_BS_test;  

   wire [7:0] debug_TAB_test; // 41 = 0x29 TAB
   assign debug_TAB_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_0 , is_uart_rx_b5_1, is_uart_rx_b4_0,
				 is_uart_rx_b3_1 , is_uart_rx_b2_0 , is_uart_rx_b1_0, is_uart_rx_b0_1};
   assign debug_is_TAB = &debug_TAB_test;  
   /*
    wire [7:0] debug_91_test; //  91 = 0x5b [
    assign debug_91_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_1 , is_uart_rx_b5_0, is_uart_rx_b4_1,
    is_uart_rx_b3_1 , is_uart_rx_b2_0 , is_uart_rx_b1_1, is_uart_rx_b0_1};
    assign debug_is_91 = &debug_91_test;  

    wire [7:0] debug_93_test; //  93 = 0x5d ]
    assign debug_93_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_1 , is_uart_rx_b5_0, is_uart_rx_b4_1,
    is_uart_rx_b3_1 , is_uart_rx_b2_1 , is_uart_rx_b1_0, is_uart_rx_b0_1};
    assign debug_is_93 = &debug_93_test;  
    */

   wire [7:0] debug_wire;
   assign debug_wire[7:0] = 
                            debug_is_CR?  db_DUT_in1 [7:0]: //{1'b0,1'b0, 1'b0, debug_test[4:0]}:  
                            debug_is_DEL? db_DUT_in2 [7:0]: //{1'b0,1'b0, 1'b0, debug_test1[4:0]}:
                            debug_is_BS?  {1'b0,1'b0, 1'b0, debug_test2[4:0]}: 
                            debug_is_TAB? {1'b0,1'b0, 1'b0, debug_test3[4:0]}: 
			    //                       debug_is_91?  {1'b0,1'b0, 1'b0, debug_test4[4:0]}: // '['
			    //                       debug_is_93?  {1'b0,1'b0, 1'b0, debug_test5[4:0]}: // ']'
                            debug_led[7:0];

   assign led[0] = debug_wire[0];                      
   assign led[1] = debug_wire[1];                      
   assign led[2] = debug_wire[2];                      
   assign led[3] = debug_wire[3];                      
   assign led[4] = debug_wire[4];                      

endmodule
