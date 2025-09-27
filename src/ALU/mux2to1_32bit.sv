////////////////////
//MUX 2 to 1 32bit//
////////////////////
module mux2to1_32bit(
							input logic [31:0]In1,
							input logic [31:0]In2,
							input logic sel,
							output logic [31:0] out
							);			
genvar i;
generate
	for(i=0; i<32; i=i+1) begin: mux2to1_gen
		mux2to1 mux2to1(
							 .In1(In1[i]),
							 .In2(In2[i]),
							 .sel(sel),
							 .out(out[i]));
	end
endgenerate
endmodule

//----------------------------Sub_Modules-----------------------------//
//////////////
// MUX 4 to 1
//////////////
module mux4to1(
    input  logic In1,
    input  logic In2,
    input  logic In3,
    input  logic In4,
    input  logic [1:0] sel,
    output logic out
);
    wire stage1_1, stage1_2;

    mux2to1 m1(.In1(In1), .In2(In2), .sel(sel[0]), .out(stage1_1));
    mux2to1 m2(.In1(In3), .In2(In4), .sel(sel[0]), .out(stage1_2));
    mux2to1 m3(.In1(stage1_1), .In2(stage1_2), .sel(sel[1]), .out(out));
endmodule


//////////////
// MUX 2 to 1
//////////////
module mux2to1(
    input  logic In1,
    input  logic In2,
    input  logic sel,
    output logic out
);
    assign out = sel ? In2 : In1;
endmodule

////////////////////
//MUX 4 to 1 32bit//
////////////////////
module mux4to1_32bit(
					input logic [31:0]In1,
					input logic [31:0]In2,
					input logic [31:0]In3,
					input logic [31:0]In4, 
					input logic [1:0] sel,
					output logic [31:0]out
					);
wire [31:0]stage1_1;
wire [31:0]stage1_2;

//stage_0
mux2to1_32bit mux1(.In1(In1), .In2(In2), .sel(sel[0]), .out(stage1_1));
mux2to1_32bit mux2(.In1(In3), .In2(In4), .sel(sel[0]), .out(stage1_2));

//stage_1
mux2to1_32bit mux3(.In1(stage1_1), .In2(stage1_2), .sel(sel[1]), .out(out));
endmodule

////////////////////
//MUX 8 to 1 32bit//
////////////////////
module mux8to1_32bit(
					input logic [31:0]In1,
					input logic [31:0]In2,
					input logic [31:0]In3,
					input logic [31:0]In4,
					input logic [31:0]In5,
					input logic [31:0]In6,
					input logic [31:0]In7,
					input logic [31:0]In8,
					input logic [2:0] sel,
					output logic [31:0]out
					);
wire [31:0]stage1_1;
wire [31:0]stage1_2;
wire [31:0]stage2_1;
wire [31:0]stage2_2;
wire [31:0]stage2_3;
wire [31:0]stage2_4;

//stage_0
mux2to1_32bit mux4(.In1(In1), .In2(In2), .sel(sel[0]), .out(stage2_1));
mux2to1_32bit mux5(.In1(In3), .In2(In4), .sel(sel[0]), .out(stage2_2));
mux2to1_32bit mux6(.In1(In5), .In2(In6), .sel(sel[0]), .out(stage2_3));
mux2to1_32bit mux7(.In1(In7), .In2(In8), .sel(sel[0]), .out(stage2_4));

//stage_1
mux2to1_32bit mux1(.In1(stage2_1), .In2(stage2_2), .sel(sel[1]), .out(stage1_1));
mux2to1_32bit mux2(.In1(stage2_3), .In2(stage2_4), .sel(sel[1]), .out(stage1_2));

//stage_2
mux2to1_32bit mux3(.In1(stage1_1), .In2(stage1_2), .sel(sel[2]), .out(out));
endmodule

