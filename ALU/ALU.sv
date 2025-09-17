///////////////////
//ALU Full Module//
///////////////////
/*
This ALU can operates 10 differents instructions as below

Input: i_op_a - 32bit
Input: i_op_b - 32bit
Output: o_alu_data - 32bit
Input: i_alu_op - 4bit
*/

module ALU(i_op_a, i_op_b, i_alu_op, o_alu_data);
parameter N = 32;
input [N-1:0] i_op_a;    		//First operand for ALU operations - 32bit
input [N-1:0] i_op_b;    		//Second operand for ALU operations - 32bit
input [3:0] i_alu_op;    		//The opcode of the operation - 4bit
output [N-1:0] o_alu_data;	//Result of the ALU operation - 32bit

	ALU_sub ALU(.A(i_op_a), .B(i_op_b), .C(i_alu_op), .R(o_alu_data));

endmodule


module ALU_sub(A, B, C, R);
parameter N = 32;
input [N-1:0] A;    		//First operand for ALU operations - 32bit
input [N-1:0] B;    		//Second operand for ALU operations - 32bit
input [3:0] C;    		//The opcode of the operation - 4bit
output [N-1:0] R;	//Result of the ALU operation - 32bit

//Operation Opcodes
parameter ADD  = 4'b0000;
parameter SUB  = 4'b0001;
parameter SLT  = 4'b0010;
parameter SLTU = 4'b0011;
parameter XOR  = 4'b0100;
parameter OR   = 4'b0101;
parameter AND  = 4'b0110;
parameter SLL  = 4'b0111;
parameter SRL  = 4'b1000;
parameter SRA  = 4'b1001;

wire [N-1:0] carry_o;
wire [N-1:0] Adder;
wire [N-1:0] Subtractor;
wire [N-1:0] SetLessThan;
wire [N-1:0] SetLessThan_Unsigned;
wire [N-1:0] XOR_gates;
wire [N-1:0] OR_gates;
wire [N-1:0] AND_gates;
wire [N-1:0] ShiftLeft_logic;
wire [N-1:0] ShiftRight_logic;
wire [N-1:0] ShiftRight_arithmetic;

adder_32bit adder(.A(A), .B(B), .sel(1'b0), .OUT(Adder), .CarryOut(carry_o));

adder_32bit subtractor(.A(A), .B(B), .sel(1'b1), .OUT(Subtractor), .CarryOut(carry_o));

XOR_32bit XOR_alu(.a(A), .b(B), .s(XOR_gates));

OR_32bit OR_alu(.a(A), .b(B), .s(OR_gates));

AND_32bit AND_alu(.a(A), .b(B), .s(AND_gates));

comparator_lt set_lt_signed(.A(A), .B(B), .sel_signed(1'b0), .AltB_o(SetLessThan));

comparator_lt set_lt_unsigned(.A(A), .B(B), .sel_signed(1'b1), .AltB_o(SetLessThan_Unsigned));

Shift_Logic ShiftLeft(.a(A), .b(B), .sel_sr(1'b0), .r(ShiftLeft_logic));

Shift_Logic ShiftRight(.a(A), .b(B), .sel_sr(1'b1), .r(ShiftRight_logic));

ShiftRight_Arithmetic ShiftRightArithmetic(.a(A), .b(B), .y(ShiftRight_arithmetic));

mux_16_to_1 ALU_mux(
    .in0(Adder), // Đầu vào 0 (32 bit)
    .in1(Subtractor),
	 .in2(SetLessThan),
    .in3(SetLessThan_Unsigned),
    .in4(XOR_gates),
    .in5(OR_gates),
    .in6(AND_gates),
    .in7(ShiftLeft_logic),
    .in8(ShiftRight_logic),
    .in9(ShiftRight_arithmetic),   
    .in10(1'b0),
    .in11(1'b0),
    .in12(1'b0),
    .in13(1'b0),
    .in14(1'b0),
    .in15(1'b0), // Đầu vào 15 (32 bit)
    .sel(C),             // 4 bit chọn
    .output_data(R)    // 1 đầu ra 32 bit
);
endmodule




///////////////
//MUX 16 to 1//
///////////////
module mux_16_to_1 (
    input logic [31:0] in0, // Đầu vào 0 (32 bit)
    input logic [31:0] in1,
    input logic [31:0] in2,
    input logic [31:0] in3,
    input logic [31:0] in4,
    input logic [31:0] in5,
    input logic [31:0] in6,
    input logic [31:0] in7,
    input logic [31:0] in8,
    input logic [31:0] in9,
    input logic [31:0] in10,
    input logic [31:0] in11,
    input logic [31:0] in12,
    input logic [31:0] in13,
    input logic [31:0] in14,
    input logic [31:0] in15, // Đầu vào 15 (32 bit)
    input logic [3:0] sel,             // 4 bit chọn
    output logic [31:0] output_data    // 1 đầu ra 32 bit
);
    always_comb begin
        case (sel)
            4'd0:  output_data = in0;
            4'd1:  output_data = in1;
            4'd2:  output_data = in2;
            4'd3:  output_data = in3;
            4'd4:  output_data = in4;
            4'd5:  output_data = in5;
            4'd6:  output_data = in6;
            4'd7:  output_data = in7;
            4'd8:  output_data = in8;
            4'd9:  output_data = in9;
            4'd10: output_data = in10;
            4'd11: output_data = in11;
            4'd12: output_data = in12;
            4'd13: output_data = in13;
            4'd14: output_data = in14;
            4'd15: output_data = in15;
            default: output_data = 32'b0;
        endcase
    end

endmodule