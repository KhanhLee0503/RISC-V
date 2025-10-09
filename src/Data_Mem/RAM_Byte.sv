// ============================================================================
//  Converted from Digital auto-generated Verilog to clean SystemVerilog
// ============================================================================
module RAM_Byte(
					input logic i_clk,
					input logic i_reset,
					input logic [10:0] i_addr,
					input logic [31:0] i_wdata,
					input logic [3:0] i_bmask,
					input logic i_wren,
					output logic [31:0] o_rdata
					);
logic In_00;
logic In_01;
logic In_10;
logic In_11;
Decoder_2to4 Low_Address_Decode(
										 .in(i_addr[1:0]),
										 .en(1'b1),
										 .out({In_11, In_10, In_01, In_00})
										 );

logic bmask_byte;
logic bmask_half;
logic bmask_word;

assign bmask_byte = (~i_bmask[3]&~i_bmask[2]&~i_bmask[1]&i_bmask[0]);
assign bmask_half = (~i_bmask[3]&~i_bmask[2]&i_bmask[1]&i_bmask[0]);
assign bmask_word = (i_bmask[3]&i_bmask[2]&i_bmask[1]&i_bmask[0]);

logic [511:0] Hi_Address;
Decoder_9to512 Hi_Address_Decoder(
											.in(i_addr[10:2]),
											.en(1'b1),
											.out(Hi_Address)
											);
											
											
logic  [31:0] output_ram [0:511];
genvar i;
generate
	for (i=0; i<512; i=i+1) begin : Word_RAM
		RAM_Byte_Sub RAM(
				 .Data(i_wdata),
				 .Clock(i_clk),
				 .Reset(i_reset),
				 .Write(i_wren),
				 .Hi_Address(Hi_Address[i]),
				 .In_00(In_00),
				 .In_01(In_01),
				 .In_10(In_10),
				 .In_11(In_11),
				 .Byte(bmask_byte),
				 .Half(bmask_half),
				 .Word(bmask_word),
                 .Data_Out(output_ram[i]) 
						);
	end
endgenerate

Mux_512to1 #(.WIDTH(32)) Output_Mux(
												.in(output_ram),
												.sel(i_addr[10:2]),
												.out(o_rdata)
												); 


endmodule 





// ============================================================================
//  Decoder 2 to 4 with Enable
// ============================================================================
module Decoder_2to4 ( 
							input logic [1:0] in, // 2 bit input 
							input logic en, //  enable signal 
							output logic [3:0] out // 4 bit output
							); 
always_comb begin 
	if (!en) 
		out = 4'b0000; // when disable → All becomes 0 
	else begin 
		case (in) 
				2'b00: out = 4'b0001;
				2'b01: out = 4'b0010; 
				2'b10: out = 4'b0100; 
				2'b11: out = 4'b1000; 
				default: out = 4'b0000; 
		endcase 
	end 
end 
endmodule



// ============================================================================
//  Decoder 4 to 16 with Enable
// ============================================================================

module Decoder_4to16 (
    input  logic [3:0] in,    // 4 bit input
    input  logic       en,    // enable signal
    output logic [15:0] out   // 16 bit output
);

    always_comb begin
        if (!en)
            out = 16'b0;          // when disable → All becomes 0 
        else begin
            case (in)
                4'b0000: out = 16'b0000_0000_0000_0001;
                4'b0001: out = 16'b0000_0000_0000_0010;
                4'b0010: out = 16'b0000_0000_0000_0100;
                4'b0011: out = 16'b0000_0000_0000_1000;
                4'b0100: out = 16'b0000_0000_0001_0000;
                4'b0101: out = 16'b0000_0000_0010_0000;
                4'b0110: out = 16'b0000_0000_0100_0000;
                4'b0111: out = 16'b0000_0000_1000_0000;
                4'b1000: out = 16'b0000_0001_0000_0000;
                4'b1001: out = 16'b0000_0010_0000_0000;
                4'b1010: out = 16'b0000_0100_0000_0000;
                4'b1011: out = 16'b0000_1000_0000_0000;
                4'b1100: out = 16'b0001_0000_0000_0000;
                4'b1101: out = 16'b0010_0000_0000_0000;
                4'b1110: out = 16'b0100_0000_0000_0000;
                4'b1111: out = 16'b1000_0000_0000_0000;
                default: out = 16'b0;
            endcase
        end
    end

endmodule


// ============================================================================
// Decoder 9 to 512 with Enable
// ============================================================================

module Decoder_9to512 (
    input  logic [8:0] in,        // 9 bit input 
    input  logic       en,        // enable signal
    output logic [511:0] out      // 512 bit output
);

    always_comb begin
        if (!en)
            out = '0;             // Disable → All becomes 0
        else
            out = 512'b1 << in;
	end

endmodule


// ============================================================================
//  512-to-1 Multiplexer
// ============================================================================

module Mux_512to1 #(
    parameter WIDTH = 1           // Độ rộng mỗi đầu vào (mặc định 1 bit)
) (
    input  logic [WIDTH-1:0] in [0:511],  // 512 đầu vào, mỗi đầu vào WIDTH bit
    input  logic [8:0]       sel,         // Tín hiệu chọn (0–511)
    output logic [WIDTH-1:0] out          // Đầu ra
);

    always_comb begin
        out = in[sel];  // Chọn đầu vào tương ứng
    end

endmodule

// ============================================================================
//  Clean SystemVerilog conversion of auto-generated "RAM_Byte" module
// ============================================================================

module Mux_2x1_NBits #(
    parameter int Bits = 2
)(
    input  logic             sel,
    input  logic [Bits-1:0]  in_0,
    input  logic [Bits-1:0]  in_1,
    output logic [Bits-1:0]  out
);
    always_comb begin
        case (sel)
            1'b0: out = in_0;
            1'b1: out = in_1;
            default: out = '0;
        endcase
    end
endmodule


// ============================================================================
//  Register with enable (BUS version)
// ============================================================================
module DIG_Register_BUS #(
    parameter int Bits = 1
)(
    input  logic             C,
    input  logic             en,
    input  logic             reset, 
    input  logic [Bits-1:0]  D,
    output logic [Bits-1:0]  Q
);
    logic [Bits-1:0] state = '0;

    assign Q = state;

    always_ff @(posedge C or posedge reset) begin
        if (reset)
            state <= '0;
        else if (en)
            state <= D;
    end
endmodule


// ============================================================================
//  RAM_Byte — converted from Digital to SystemVerilog
// ============================================================================
module RAM_Byte_Sub (
    input  logic [31:0] Data,
    input  logic        Clock,
    input  logic        Write,
    input  logic        Reset,
    input  logic        Hi_Address,
    input  logic        In_00,
    input  logic        In_01,
    input  logic        In_10,
    input  logic        In_11,
    input  logic        Byte,
    input  logic        Half,
    input  logic        Word,
    output logic [31:0] Data_Out
);

    // Intermediate signals
    logic s0, s1, s3, s6, s9, s12, s26, s27, s28, s29, s34, s47, s48;
    logic s49, s50, s51, s52;
    logic [7:0] s2, s4, s5, s7, s8, s10, s11, s13, s14, s15, s16, s17;
    logic [7:0] s18, s19, s20, s21, s22, s23, s24, s25, s30, s31, s32, s33;
    logic [7:0] s35, s36, s37, s38, s39, s40, s41, s42, s43, s44, s45, s46;

    // Control signals
    assign s0  = (Word & In_00);
    assign s1  = (Half & (In_10 | In_00));
    assign s29 = (Hi_Address & ~Write);
    assign s50 = (Byte & In_00);
    assign s49 = (Byte & In_01);
    assign s51 = (Byte & In_10);
    assign s52 = (Byte & In_11);

    // Split input data
    assign s11 = Data[7:0];
    assign s16 = Data[15:8];
    assign s19 = Data[23:16];
    assign s14 = Data[31:24];

    // ---------------- MUXes for write data paths ----------------
    Mux_2x1_NBits #(.Bits(8)) Mux_2x1_NBits_i0  (.sel(s0),  .in_0(8'b0), .in_1(s14), .out(s15));
    Mux_2x1_NBits #(.Bits(8)) Mux_2x1_NBits_i1  (.sel(s1),  .in_0(8'b0), .in_1(s16), .out(s17));
    Mux_2x1_NBits #(.Bits(8)) Mux_2x1_NBits_i2  (.sel(Byte),.in_0(8'b0), .in_1(s11), .out(s18));
    Mux_2x1_NBits #(.Bits(8)) Mux_2x1_NBits_i3  (.sel(s0),  .in_0(8'b0), .in_1(s19), .out(s20));
    Mux_2x1_NBits #(.Bits(8)) Mux_2x1_NBits_i4  (.sel(s1),  .in_0(8'b0), .in_1(s11), .out(s21));
    Mux_2x1_NBits #(.Bits(8)) Mux_2x1_NBits_i5  (.sel(Byte),.in_0(8'b0), .in_1(s11), .out(s22));
    Mux_2x1_NBits #(.Bits(8)) Mux_2x1_NBits_i6  (.sel(s0),  .in_0(8'b0), .in_1(s16), .out(s23));
    Mux_2x1_NBits #(.Bits(8)) Mux_2x1_NBits_i7  (.sel(s1),  .in_0(8'b0), .in_1(s16), .out(s24));
    Mux_2x1_NBits #(.Bits(8)) Mux_2x1_NBits_i8  (.sel(Byte),.in_0(8'b0), .in_1(s11), .out(s25));

    // Internal enables
    assign s26 = (In_00 & s1);
    assign s27 = (In_00 & s0);
    assign s28 = (s1 & In_10);
    assign s34 = (s0 & In_00);
    assign s47 = (In_00 & s1);
    assign s48 = (In_10 & s1);

    // Combine mux outputs
    assign s2 = (s18 | s17 | s15);
    assign s5 = (s22 | s21 | s20);
    assign s8 = (s25 | s24 | s23);

    // Write enables per byte
    assign s3  = (((Byte & In_11) | s28 | s27) & Hi_Address & Write);
    assign s6  = (((Byte & In_10) | s28 | s27) & Write & Hi_Address);
    assign s9  = (((Byte & In_01) | s26 | s27) & Write & Hi_Address);
    assign s12 = (((Byte & In_00) | s26 | s27) & Write & Hi_Address);

    // Byte registers
    DIG_Register_BUS #(.Bits(8)) REG_B11 (.D(s2),  .C(Clock), .en(s3),  .Q(s4), .reset(Reset));
    DIG_Register_BUS #(.Bits(8)) REG_B10 (.D(s5),  .C(Clock), .en(s6),  .Q(s7), .reset(Reset));
    DIG_Register_BUS #(.Bits(8)) REG_B01 (.D(s8),  .C(Clock), .en(s9),  .Q(s10), .reset(Reset));
    DIG_Register_BUS #(.Bits(8)) REG_B00 (.D(s11), .C(Clock), .en(s12), .Q(s13), .reset(Reset));

    // Read path muxes
    Mux_2x1_NBits #(.Bits(8)) Mux_Out_3 (.sel(s29), .in_0(8'b0), .in_1(s4),  .out(s30));
    Mux_2x1_NBits #(.Bits(8)) Mux_Out_2 (.sel(s29), .in_0(8'b0), .in_1(s7),  .out(s31));
    Mux_2x1_NBits #(.Bits(8)) Mux_Out_1 (.sel(s29), .in_0(8'b0), .in_1(s10), .out(s32));
    Mux_2x1_NBits #(.Bits(8)) Mux_Out_0 (.sel(s29), .in_0(8'b0), .in_1(s13), .out(s33));

    // Additional read mux network
    Mux_2x1_NBits #(.Bits(8)) M_i17 (.sel(s34), .in_0(8'b0), .in_1(s30), .out(s35));
    Mux_2x1_NBits #(.Bits(8)) M_i18 (.sel(s34), .in_0(8'b0), .in_1(s31), .out(s36));
    Mux_2x1_NBits #(.Bits(8)) M_i19 (.sel(s34), .in_0(8'b0), .in_1(s32), .out(s37));
    Mux_2x1_NBits #(.Bits(8)) M_i20 (.sel(s34), .in_0(8'b0), .in_1(s33), .out(s38));
    Mux_2x1_NBits #(.Bits(8)) M_i21 (.sel(s47), .in_0(8'b0), .in_1(s32), .out(s39));
    Mux_2x1_NBits #(.Bits(8)) M_i22 (.sel(s47), .in_0(8'b0), .in_1(s33), .out(s45));
    Mux_2x1_NBits #(.Bits(8)) M_i23 (.sel(s48), .in_0(8'b0), .in_1(s31), .out(s46));
    Mux_2x1_NBits #(.Bits(8)) M_i24 (.sel(s48), .in_0(8'b0), .in_1(s30), .out(s40));
    Mux_2x1_NBits #(.Bits(8)) M_i25 (.sel(s49), .in_0(8'b0), .in_1(s32), .out(s42));
    Mux_2x1_NBits #(.Bits(8)) M_i26 (.sel(s50), .in_0(8'b0), .in_1(s33), .out(s41));
    Mux_2x1_NBits #(.Bits(8)) M_i27 (.sel(s51), .in_0(8'b0), .in_1(s31), .out(s43));
    Mux_2x1_NBits #(.Bits(8)) M_i28 (.sel(s52), .in_0(8'b0), .in_1(s30), .out(s44));

    // Combine outputs
    assign Data_Out[7:0]   = (s41 | s42 | s43 | s44 | s45 | s46 | s38);
    assign Data_Out[15:8]  = (s39 | s40 | s37);
    assign Data_Out[23:16] = s36;
    assign Data_Out[31:24] = s35;

endmodule




