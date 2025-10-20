module lsu(
				input logic i_clk,
				input logic i_reset,
				input logic [3:0] i_load_type,		// 0001: load byte, 0011: load halfword, 1111: load word
				input logic i_load_signed,			//if 0 is unsigned, 1 is signed
				
				input logic [31:0] i_lsu_addr,
				input logic [31:0] i_st_data,
				input logic i_lsu_wren,				//1 is Writing, 0 is Reading
				input logic [31:0] i_io_sw,
				
				output logic [31:0] o_ld_data,
				output logic [31:0] o_io_ledr,
				output logic [31:0] o_io_ledg,
				output logic [31:0] o_io_lcd,
				
				output logic [31:0] o_io_hex03,
				output logic [31:0] o_io_hex47
			  );

//Wires for selecting Load Type			  
logic word_sel;
logic halfword_sel;
logic byte_sel;

assign word_sel	    = i_load_type[3]&i_load_type[2]&i_load_type[1]&i_load_type[0];
assign halfword_sel = ~i_load_type[3]&~i_load_type[2]&i_load_type[1]&i_load_type[0];
assign byte_sel 	= ~i_load_type[3]&~i_load_type[2]&~i_load_type[1]&i_load_type[0];


//Wires for selecting enable pin
logic data_wren_in;
logic lcd_wren_in;
logic ledr_wren_in;
logic ledg_wren_in;
logic hex03_wren_in;
logic hex47_wren_in;
logic switch_wren_in;
			  
//Wires for data output
logic [31:0] switch_reg_out;
logic [31:0] memory_out;
logic [31:0] memory_out_signed;

logic [31:0] o_io_ledg_sub;
logic [31:0] o_io_ledr_sub;
logic [31:0] o_io_lcd_sub;
logic [31:0] o_io_hex03_sub;
logic [31:0] o_io_hex47_sub;
logic [31:0] memory_out_sub;
logic [31:0] switch_reg_out_sub;

logic [31:0] o_io_ledg_out;
logic [31:0] o_io_ledr_out;
logic [31:0] o_io_lcd_out;
logic [31:0] o_io_hex03_out;
logic [31:0] o_io_hex47_out;
logic [31:0] memory_out_out;
logic [31:0] switch_reg_out_subout;

logic [31:0] data_in;
logic [7:0] data_in_word_B1;
logic [7:0] data_in_half_B1;
logic [7:0] data_in_byte_B0;
logic [7:0] data_in_half_B0;
logic [7:0] data_in_word_B0;

//MUXes for handling Load Byte, Load Word
assign data_in[31:24] = i_st_data[31:24];
assign data_in[23:16] = i_st_data[23:16];

mux2to1_8bit mux_B1_word(
					.In1(8'b0),
					.In2(i_st_data[15:8]),
					.sel(word_sel),
					.out(data_in_word_B1)
					);


mux2to1_8bit mux_B0_word(
					.In1(8'b0),
					.In2(i_st_data[7:0]),
					.sel(word_sel),
					.out(data_in_word_B0)
					);					


mux2to1_8bit mux_B1_half(
					.In1(8'b0),
					.In2(i_st_data[15:8]),
					.sel(halfword_sel),
					.out(data_in_half_B1)
					);					

mux2to1_8bit mux_B0_half(
					.In1(8'b0),
					.In2(i_st_data[7:0]),
					.sel(halfword_sel),
					.out(data_in_half_B0)
					);					

mux2to1_8bit mux_B0_byte(
					.In1(8'b0),
					.In2(i_st_data[7:0]),
					.sel(byte_sel),
					.out(data_in_byte_B0)
					);		

assign data_in[7:0] = data_in_byte_B0|data_in_half_B0|data_in_word_B0;
assign data_in[15:8] = data_in_half_B1|data_in_word_B1;

lsu_decoder lsu_decoder(
						.i_addr(i_lsu_addr),
						.lcd_wren(lcd_wren_in),
						.LEDR_wren(ledr_wren_in),
						.LEDG_wren(ledg_wren_in),
						.data_wren(data_wren_in),
						.switch_wren(switch_wren_in),
						.segment03_wren(hex03_wren_in),
						.segment47_wren(hex47_wren_in)		
						);

register_LSU_32bit LEDR_reg(
						.data_in(data_in),
						.load(ledr_wren_in & i_lsu_wren),
						.clear(i_reset),
						.word(word_sel),
						.half(halfword_sel),
						.clk(i_clk),
						.OUT(o_io_ledr_sub)
						);

mux2to1_32bit muxout_ledr(
						 .In1(o_io_ledr_sub),
						 .In2(32'b0),
						 .sel(i_lsu_wren),
						 .out(o_io_ledr_out)
						 );	
loadtype load_ledr(
				.data_in(o_io_ledr_out),
				.load_type(i_load_type),
				.load_signed(i_load_signed),
				.data_out(o_io_ledr)
				 );


register_LSU_32bit LEDG_reg(
						.data_in(data_in),
						.load(ledg_wren_in & i_lsu_wren),
						.clear(i_reset),
						.word(word_sel),
						.half(halfword_sel),
						.clk(i_clk),
						.OUT(o_io_ledg_sub)
						);
								
mux2to1_32bit muxout_ledg(
						 .In1(o_io_ledg_sub),
						 .In2(32'b0),
						 .sel(i_lsu_wren),
						 .out(o_io_ledg_out)
						);	

loadtype load_ledg(
					.data_in(o_io_ledg_out),
					.load_type(i_load_type),
					.load_signed(i_load_signed),
					.data_out(o_io_ledg)
					);

register_LSU_32bit LCD_reg(
					.data_in(data_in),
					.load(lcd_wren_in & i_lsu_wren),
					.clear(i_reset),
					.word(word_sel),
					.half(halfword_sel),
					.clk(i_clk),
					.OUT(o_io_lcd_sub)
					);

mux2to1_32bit muxout_lcd(
						 .In1(o_io_lcd_sub),
						 .In2(32'b0),
						 .sel(i_lsu_wren),
						 .out(o_io_lcd_out)
						);								

loadtype load_lcd(
					.data_in(o_io_lcd_out),
					.load_type(i_load_type),
					.load_signed(i_load_signed),
					.data_out(o_io_lcd)
					);

register_32bit Switch_reg(
								.data_in(i_io_sw),
								.load(1'b1),
								.clear(i_reset),
								.clk(i_clk),
								.OUT(switch_reg_out_sub)
								);
								
mux2to1_32bit muxout_switch(
						 .In1(switch_reg_out_sub),
						 .In2(32'b0),
						 .sel(i_lsu_wren),
						 .out(switch_reg_out_subout)
						);

loadtype load_switch(
					.data_in(switch_reg_out_subout),
					.load_type(i_load_type),
					.load_signed(i_load_signed),
					.data_out(switch_reg_out)
					);

register_LSU_32bit Hex03_reg(
								.data_in(data_in),
								.load(hex03_wren_in & i_lsu_wren),
								.clear(i_reset),
								.word(word_sel),
								.half(halfword_sel),		
								.clk(i_clk),
								.OUT(o_io_hex03_sub)
								);								

mux2to1_32bit muxout_hex03(
						 .In1(o_io_hex03_sub),
						 .In2(32'b0),
						 .sel(i_lsu_wren),
						 .out(o_io_hex03_out)
						);

loadtype load_hex03(
					.data_in(o_io_hex03_out),
					.load_type(i_load_type),
					.load_signed(i_load_signed),
					.data_out(o_io_hex03)
					);

register_LSU_32bit Hex47_reg(
							.data_in(data_in),
							.load(hex47_wren_in & i_lsu_wren),
							.clear(i_reset),
							.word(word_sel),
							.half(halfword_sel),
							.clk(i_clk),
							.OUT(o_io_hex47_sub)
							);	

mux2to1_32bit muxout_hex47(
						 .In1(o_io_hex47_sub),
						 .In2(32'b0),
						 .sel(i_lsu_wren),
						 .out(o_io_hex47_out)
						);

loadtype load_hex47(
					.data_in(o_io_hex47_out),
					.load_type(i_load_type),
					.load_signed(i_load_signed),
					.data_out(o_io_hex47)
					);

DataMem DataMem(
					 .i_clk(i_clk),
					 .i_addr(i_lsu_addr[10:0]),
					 .i_wdata(i_st_data),
					 .i_bmask(i_load_type), 
					 .i_wren(data_wren_in & i_lsu_wren),
					 .o_rdata(memory_out_sub)
					);	

mux2to1_32bit muxout_datamem(
						 .In1(memory_out_sub),
						 .In2(32'b0),
						 .sel(i_lsu_wren),
						 .out(memory_out)
						);

loadtype loadtype(
					.data_in(memory_out),
					.load_type(i_load_type),
					.load_signed(i_load_signed),
					.data_out(memory_out_signed)
					);
					
					
mux2to1_32bit Sel_SWITCHorDATA(
										.In2(switch_reg_out),
										.In1(memory_out_signed),
										.sel(i_lsu_addr[16]),
										.out(o_ld_data)
										);
								
		
endmodule 


//-----------------------------Sub_Module-------------------------------/

//////////////////
//Decoder 1 to 2//
//////////////////
module decoder_1to2(
						 input logic in,
						 input logic enable,
						 output logic out0,
						 output logic out1
						 );
always_comb begin
	out0 = 1'b0;
	out1 = 1'b0;
	
	if(enable) begin
		case(in)
			1'b0: out0 = 1'b1;
			1'b1: out1 = 1'b1;

		default: begin 
			out0 = 1'b0;
			out1 = 1'b0;
				  end
	endcase
	end
end
endmodule



//////////////////
//Decoder 3 to 8//
//////////////////
module decoder_3to8(
						 input logic [2:0] in,
						 input logic enable,
						 output logic out0,
						 output logic out1,
						 output logic out2,
						 output logic out3,
						 output logic out4,
						 output logic out5,
						 output logic out6,
						 output logic out7
						 );
always_comb begin
	out0 = 1'b0;
	out1 = 1'b0;
	out2 = 1'b0;
	out3 = 1'b0;
	out4 = 1'b0;
	out5 = 1'b0;
	out6 = 1'b0;
	out7 = 1'b0;
	
	
	if(enable) begin
		case(in)
			3'b000: out0 = 1'b1;
			3'b001: out1 = 1'b1;
			3'b010: out2 = 1'b1;
			3'b011: out3 = 1'b1;
			3'b100: out4 = 1'b1;
			3'b101: out5 = 1'b1;
			3'b110: out6 = 1'b1;
			3'b111: out7 = 1'b1;
			

		default: begin 
			out0 = 1'b0;
			out1 = 1'b0;
			out2 = 1'b0;
			out3 = 1'b0;
			out4 = 1'b0;
			out5 = 1'b0;
			out6 = 1'b0;
			out7 = 1'b0;
				  end
	endcase
	end
end
endmodule


//////////////////////////////////
//Decoder for Data and IO of LSU//
//////////////////////////////////
module lsu_decoder(
						input logic [31:0] i_addr,
						output logic lcd_wren,
						output logic LEDR_wren,
						output logic LEDG_wren,
						output logic data_wren,
						output logic switch_wren,
						output logic segment03_wren,
						output logic segment47_wren
						);
						
logic SWITCHorIO;
logic IO_enable;
logic [2:0] dummy;

decoder_1to2 select_DATA(
									 .in(i_addr[28]),
									 .enable(1'b1),
									 .out1(SWITCHorIO),
									 .out0(data_wren)
									 );
									 
decoder_1to2 select_SWITHorIO(
										.in(i_addr[16]),
										.enable(SWITCHorIO),
										.out0(IO_enable),
										.out1(switch_wren)
										);
		

 
decoder_3to8 select_IO(
								.in(i_addr[14:12]),
								.enable(IO_enable),
								.out0(LEDR_wren),
								.out1(LEDG_wren),
								.out2(segment03_wren),
								.out3(segment47_wren),
								.out4(lcd_wren),
								.out5(dummy[0]),
								.out6(dummy[1]),
								.out7(dummy[2])
								);
endmodule

////////////////////
//Load Type Module//
////////////////////
module loadtype(
					input logic [31:0] data_in,
					input logic [3:0] load_type,
					input logic load_signed,
					output logic [31:0] data_out
					);

logic load_byte;
logic load_half;
logic load_word;

logic [23:0] byte_sign_extend;
logic [15:0] half_sign_extend;

logic [31:0] dummy_1;
logic [31:0] dummy_2;
logic [31:0] dummy_3;
logic [31:0] dummy_4;
logic [31:0] dummy_5;

assign load_byte = ~load_type[3]&~load_type[2]&~load_type[1]&load_type[0];	
assign load_half = ~load_type[3]&~load_type[2]&load_type[1]&load_type[0];	
assign load_word = load_type[3]&load_type[2]&load_type[1]&load_type[0];	

mux2to1_24bit byte_signed(
						.In1(24'b0),
						.In2({24{data_in[7]}}),
						.sel(load_signed),		//0 is unsigned, 1 is signed
						.out(byte_sign_extend)
						);		


mux2to1_16bit half_signed(
						.In1(16'b0),
						.In2({16{data_in[15]}}),
						.sel(load_signed),		//0 is unsigned, 1 is signed
						.out(half_sign_extend)
						);	
						
mux8to1_32bit sel_out(
					.In1(dummy_1),
					.In2({byte_sign_extend,data_in[7:0]}),
					.In3({half_sign_extend,data_in[15:0]}),
					.In4(dummy_2),
					.In5(data_in),
					.In6(dummy_3),
					.In7(dummy_4),
					.In8(dummy_5),
					.sel({load_word,load_half,load_byte}),
					.out(data_out)
					);	
endmodule
