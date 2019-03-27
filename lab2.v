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

//-------------------- Lab2 ----------------------
module Lab2_140L (
 input wire i_rst           , // reset signal (active high)
 input wire i_clk_in          , //for internal state machine
 input wire i_data_rdy        , //r1, r2, OP are ready  
 input wire i_ctrl_signal     , 
 input wire i_substrate_signal,
 input wire [7:0] i_r1           , // 8bit number 1
 input wire [7:0] i_r2           , // 8bit number 1
 input wire i_cin           , // carry in
 input wire [7:0] i_ctrl         , // input ctrl char
 output wire [3:0] o_sum    ,
 output wire o_cout         ,
 output wire o_rdy          , //pulse
 output wire o_debug_test1  ,
 output wire o_debug_test2  ,
 output wire o_debug_test3  ,
 output wire [7:0] o_debug_led   
);

//------------ Add your adder here ----------
//reset your logic

reg [7:0] x, y;
reg       l_cin;
wire [7:0] result;
reg  [7:0] result_reg;
reg  rst_test;
reg [1:0] i_data_rdy_tap;

wire i_data_rdy_local_posedge;
assign i_data_rdy_local_posedge = i_data_rdy_tap[0] & ~i_data_rdy_tap[1]; 

// combine strobs generated within 2 cycles of i_clk_in
always @(posedge i_clk_in) begin
    if(i_rst) begin
	    i_data_rdy_tap[1:0] <= 2'b00;
        x <= 2'h00;
	    y <= 2'h00;
	    l_cin <= 1'b0;
		rst_test <= 1;
	end
	else begin
		i_data_rdy_tap[1:0] <= {i_data_rdy_tap[0], i_data_rdy};

        if(i_data_rdy_local_posedge) begin		
	        rst_test <= 0;
            x[7:0] <= i_r1[7:0];
	        if (i_substrate_signal) begin
		        y[7:0] <= {~i_r2[7], ~i_r2[6], ~i_r2[4], ~i_r2[4], ~i_r2[3], ~i_r2[2], ~i_r2[1], ~i_r2[0]};
		        l_cin <= 1'b1;
	        end
	        else begin
	            y[7:0] <= i_r2[7:0];
		        l_cin <= 1'b0;
			end
		end
		else begin
            x <= x;
	        y <= y;
	        l_cin <= l_cin;
		    rst_test <= rst_test;
		end
	end
end

fourbit_adder adder_UT(.sum (result[3:0]), 
			           .carry (result[4]), 
			           .r1 (x[3:0]), 
					   .r2 (y[3:0]), 
					   .ci (l_cin)
					   );


//------------------------------------------

//---------------------------------------------------------------------------------------
//  output data to UART
//    generate adder data ready sync pulse
//---------------------------------------------------------------------------------------
wire        adder_data_ready_wire;
reg  [15:0] adder_data_ready_reg;  //output 
wire        o_adder_data_ready;


assign adder_data_ready_wire = i_data_rdy_local_posedge;
//Cleared on data status clear request from Master controller reg [1:0]  adder_rdy_state;
//generate a pulse of 2x i_clk_in, adder_data_ready_wire is a pulse of 2 i_clk_in
assign o_adder_data_ready = adder_data_ready_reg[13] & ~adder_data_ready_reg[15];   
assign o_rdy = o_adder_data_ready;

always @(posedge i_clk_in or posedge i_rst) begin		
    if(i_rst) begin
        adder_data_ready_reg <= 4'h0000;
	end	
	else begin
		adder_data_ready_reg[15:0] <= {adder_data_ready_reg[14:0], adder_data_ready_wire}; 
		
        if(adder_data_ready_reg[11]) begin
            if(i_substrate_signal)
                result_reg[7:0] <= {1'b0, 1'b0, 1'b0, 0, result[3:0]}; //latch in result	
	        else
                result_reg[7:0] <= {1'b0, 1'b0, 1'b0, result[4:0]}; //latch in result
	    end
	    else
	        result_reg <= result_reg;
	end
end

assign o_sum[3:0] = result_reg[3:0];
assign o_cout = result_reg[4];


//---------------------------------------------------------------------------------------------
// DEBUG/DISPLAY CONTROL
//---------------------------------------------------------------------------------------------
assign is_uart_rx_b0_1 = i_ctrl[0] ^ 1'b0;
assign is_uart_rx_b1_1 = i_ctrl[1] ^ 1'b0;
assign is_uart_rx_b2_1 = i_ctrl[2] ^ 1'b0;
assign is_uart_rx_b3_1 = i_ctrl[3] ^ 1'b0;
assign is_uart_rx_b4_1 = i_ctrl[4] ^ 1'b0;
assign is_uart_rx_b5_1 = i_ctrl[5] ^ 1'b0;
assign is_uart_rx_b6_1 = i_ctrl[6] ^ 1'b0;
assign is_uart_rx_b7_1 = i_ctrl[7] ^ 1'b0;
assign is_uart_rx_b0_0 = i_ctrl[0] ^ 1'b1;
assign is_uart_rx_b1_0 = i_ctrl[1] ^ 1'b1;
assign is_uart_rx_b2_0 = i_ctrl[2] ^ 1'b1;
assign is_uart_rx_b3_0 = i_ctrl[3] ^ 1'b1;
assign is_uart_rx_b4_0 = i_ctrl[4] ^ 1'b1;
assign is_uart_rx_b5_0 = i_ctrl[5] ^ 1'b1;
assign is_uart_rx_b6_0 = i_ctrl[6] ^ 1'b1;
assign is_uart_rx_b7_0 = i_ctrl[7] ^ 1'b1;


wire [7:0] debug_CR_test; //CR 0x0D
assign debug_CR_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_0 , is_uart_rx_b5_0, is_uart_rx_b4_0,
                             is_uart_rx_b3_1 , is_uart_rx_b2_1 , is_uart_rx_b1_0, is_uart_rx_b0_1};

wire [7:0] debug_z_test; //z 0x7A
assign debug_z_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_1 , is_uart_rx_b5_1, is_uart_rx_b4_1,
                              is_uart_rx_b3_1 , is_uart_rx_b2_0, is_uart_rx_b1_1, is_uart_rx_b0_0};

wire [7:0] debug_LB_test; //{ 0x7B
assign debug_LB_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_1 , is_uart_rx_b5_1, is_uart_rx_b4_1,
                              is_uart_rx_b3_1 , is_uart_rx_b2_0, is_uart_rx_b1_1, is_uart_rx_b0_1};
							  
wire [7:0] debug_OR_test; //| 0x7C
assign debug_OR_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_1 , is_uart_rx_b5_1, is_uart_rx_b4_1,
                              is_uart_rx_b3_1 , is_uart_rx_b2_1, is_uart_rx_b1_0, is_uart_rx_b0_0};							  
wire [7:0] debug_RB_test; //} 0x7D
assign debug_RB_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_1 , is_uart_rx_b5_1, is_uart_rx_b4_1,
                              is_uart_rx_b3_1 , is_uart_rx_b2_1, is_uart_rx_b1_0, is_uart_rx_b0_1};
wire [7:0] debug_NOT_test; //~ 0x7E
assign debug_NOT_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_1 , is_uart_rx_b5_1, is_uart_rx_b4_1,
                              is_uart_rx_b3_1 , is_uart_rx_b2_1, is_uart_rx_b1_1, is_uart_rx_b0_0};
wire [7:0] debug_DEL_test; // DEL 0x7F
assign debug_DEL_test[7:0] = {is_uart_rx_b7_0 , is_uart_rx_b6_1 , is_uart_rx_b5_1, is_uart_rx_b4_1,
                              is_uart_rx_b3_1 , is_uart_rx_b2_1 , is_uart_rx_b1_1, is_uart_rx_b0_1};
  
assign debug_is_CR = &debug_CR_test;  
assign debug_is_z = &debug_z_test;  
assign debug_is_LB = &debug_LB_test;  
assign debug_is_OR = &debug_OR_test;  
assign debug_is_RB = &debug_RB_test;  
assign debug_is_NOT = &debug_NOT_test;  
assign debug_is_DEL = &debug_DEL_test;  
reg [7:0] debug_reg;

assign debug_adder_data_rdy_delay_line = |adder_data_ready_reg; //delay line 
assign debug_adder_rdy_self_clear = i_data_rdy_local_posedge; //self clear latch
assign debug_x = |x;
assign debug_y = |y;
assign debug_cin = l_cin;


always @ (posedge i_clk_in)
begin

    if(i_rst) begin
	    debug_reg[7:0] <= {1'b0,1'b0,1'b0,
		                  rst_test, 
						  debug_adder_data_rdy_delay_line, 
		                  debug_adder_rdy_self_clear, 
						  debug_y, 
						  debug_x};
	end else
    if(rst_test) begin
	    debug_reg[7:0] <= {1'b0,1'b0,1'b0, 
						   debug_adder_rdy_self_clear, 
						   debug_adder_rdy_self_clear, 
						   debug_cin,
						   debug_y, 
						   debug_x};
	end else

    if (i_ctrl_signal) begin
        if(debug_is_DEL) begin  //some debug reset 
	        debug_reg[7:0] <= {2'h00};
	    end else 
		begin
		    if(debug_is_CR) begin
	            debug_reg[7:0] <= {1'b0,1'b0,1'b0, result[4:0]}; //local results		   
	        end else
		    if(debug_is_z) begin
	            debug_reg[7:0] <= {1'b0,1'b0,1'b0, l_cin, rst_test, result[7:5]}; //local results		   
	        end else
		    if(debug_is_OR) begin
	            debug_reg[7:0] <= {i_r1[7:0]}; //local results		   
	        end else
		    if(debug_is_NOT) begin
	            debug_reg[7:0] <= {i_r2[7:0]}; //local results		   
	        end  else 
		    if(debug_is_LB) begin
	            debug_reg[7:0] <= {x[7:0]}; //{
            end else 		
		    if(debug_is_RB) begin
	            debug_reg[7:0] <= {y[7:0]}; //}
            end 
		end
	end 
	
	else begin
	    debug_reg[7:0] <= {1'b0,1'b0,1'b0, result_reg[4:0]};  //results drive to interface
	end
end
  
assign o_debug_led[7:0] = debug_reg[7:0];

endmodule
