module Shift_Logic(
						input logic [31:0] In,		//Ngõ vào data cần shift		
						input logic [4:0] ShAm,		//Số bit cần shift
						input logic sel,				//Sel = 0 thì left shift, ngược lại right shift
						output logic [31:0] result	//Kết quả
						);
wire [31:0] left_result;
wire [31:0] right_result;
ShiftLeft_Logic shiftleft(.In(In), .ShAm(ShAm), .OUT(left_result));
ShiftRight_Logic shiftright(.In(In), .ShAm(ShAm), .OUT(right_result));
mux2to1_32bit mux2to1(.sel(sel), .In1(left_result), .In2(right_result) , .out(result));
endmodule


//-----------------------Sub_Modules-----------------------------//
/////////////////////
//Shift Left Logic///
/////////////////////
module ShiftLeft_Logic(
							input [31:0] In,
							input [4:0] ShAm,
							output logic [31:0] OUT
							 );
							 
wire [31:0] out_stage1;
wire [31:0] out_stage2;
wire [31:0] out_stage3;
wire [31:0] out_stage4;

ShiftLeft_16bit stage1(.In(In), .enable(ShAm[4]), .Out(out_stage1));
ShiftLeft_8bit stage2(.In(out_stage1), .enable(ShAm[3]), .Out(out_stage2));
ShiftLeft_4bit stage3(.In(out_stage2), .enable(ShAm[2]), .Out(out_stage3));
ShiftLeft_2bit stage4(.In(out_stage3), .enable(ShAm[1]), .Out(out_stage4));
Simple_Shifter stage5(.In(out_stage4), .ShL(ShAm[0]), .ShR(1'b0), .inR(1'b0), .inL(1'b0), .Out(OUT));

endmodule


/////////////////////
//Shift Right Logic//
/////////////////////
module ShiftRight_Logic(
							input [31:0] In,
							input [4:0] ShAm,
							output logic [31:0] OUT
							 );
							 
wire [31:0] out_stage1;
wire [31:0] out_stage2;
wire [31:0] out_stage3;
wire [31:0] out_stage4;

ShiftRight_16bit stage1(.In(In), .enable(ShAm[4]), .Out(out_stage1));
ShiftRight_8bit stage2(.In(out_stage1), .enable(ShAm[3]), .Out(out_stage2));
ShiftRight_4bit stage3(.In(out_stage2), .enable(ShAm[2]), .Out(out_stage3));
ShiftRight_2bit stage4(.In(out_stage3), .enable(ShAm[1]), .Out(out_stage4));
Simple_Shifter stage5(.In(out_stage4), .ShL(1'b0), .ShR(ShAm[0]), .inR(1'b0), .inL(1'b0), .Out(OUT));

endmodule

//------------------------------Shift_Right----------------------------//
/////////////////////
//Shift Right 16bit//
/////////////////////
module ShiftRight_16bit(
    input  logic [31:0] In,
    input  logic        enable,   // Cho phép dịch
    output logic [31:0] Out
);

    wire [31:0] stage [0:16];  // lưu kết quả từng stage
    assign stage[0] = In;      // input gốc

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : shift_stage
            Simple_Shifter sh (
                .In (stage[i]),
                .ShL(1'b0),
                .ShR(enable),   // nếu enable=1 thì dịch
                .inR(1'b0),     // logic shift: nạp 0 vào MSB
                .inL(1'b0),
                .Out(stage[i+1])
            );
        end
    endgenerate

    assign Out = stage[16];   // kết quả cuối

endmodule

/////////////////////
//Shift Right 8bit//
/////////////////////
module ShiftRight_8bit(
    input  logic [31:0] In,
    input  logic        enable,   // Cho phép dịch
    output logic [31:0] Out
);

    wire [31:0] stage [0:8];  // stage[0] là In, stage[8] là Out
    assign stage[0] = In;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : shift_stage
            Simple_Shifter sh (
                .In  (stage[i]),
                .ShL (1'b0),
                .ShR (enable),   // nếu enable=1 thì dịch, nếu 0 thì giữ nguyên
                .inR (1'b0),     // logic shift: nạp 0 vào MSB
                .inL (1'b0),
                .Out (stage[i+1])
            );
        end
    endgenerate

    assign Out = stage[8];  // kết quả cuối cùng

endmodule


////////////////////
//Shift Right 4bit//
////////////////////
module ShiftRight_4bit(
    input  logic [31:0] In,
    input  logic        enable,   // Cho phép dịch
    output logic [31:0] Out
);

    wire [31:0] stage1_out, stage2_out, stage3_out;

    // Lần 1: dịch 1 bit
    Simple_Shifter sh1 (
        .In (In),
        .ShL(1'b0),
        .ShR(enable),
        .inR(1'b0),     // logic shift: nạp 0 vào MSB
        .inL(1'b0),
        .Out(stage1_out)
    );

    // Lần 2: dịch thêm 1 bit
    Simple_Shifter sh2 (
        .In (stage1_out),
        .ShL(1'b0),
        .ShR(enable),
        .inR(1'b0),
        .inL(1'b0),
        .Out(stage2_out)
    );

    // Lần 3: dịch thêm 1 bit
    Simple_Shifter sh3 (
        .In (stage2_out),
        .ShL(1'b0),
        .ShR(enable),
        .inR(1'b0),
        .inL(1'b0),
        .Out(stage3_out)
    );

    // Lần 4: dịch thêm 1 bit
    Simple_Shifter sh4 (
        .In (stage3_out),
        .ShL(1'b0),
        .ShR(enable),
        .inR(1'b0),
        .inL(1'b0),
        .Out(Out)
    );

endmodule

////////////////////
//Shift Right 2bit//
////////////////////
module ShiftRight_2bit(
    input  logic [31:0] In,
    input  logic        enable,   // Cho phép dịch
    output logic [31:0] Out
);

    wire [31:0] stage1_out;

    // Lần 1: dịch 1 bit
    Simple_Shifter sh1 (
        .In (In),
        .ShL(1'b0),
        .ShR(enable),   // nếu enable=1 thì dịch, nếu 0 thì giữ nguyên
        .inR(1'b0),     // logic shift (nạp 0 vào MSB)
        .inL(1'b0),
        .Out(stage1_out)
    );

    // Lần 2: dịch thêm 1 bit nữa
    Simple_Shifter sh2 (
        .In (stage1_out),
        .ShL(1'b0),
        .ShR(enable),
        .inR(1'b0),
        .inL(1'b0),
        .Out(Out)
    );

endmodule

//---------------------Shift_Left------------------//
/////////////////////
//Shift Right 16bit//
////////////////////
module ShiftLeft_16bit(
    input  logic [31:0] In,
    input  logic        enable,
    output logic [31:0] Out
);

    wire [31:0] stage [0:16];  
    assign stage[0] = In;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : shift_stage
            Simple_Shifter sh (
                .In  (stage[i]),
                .ShL (enable),
                .ShR (1'b0),
                .inR (1'b0),
                .inL (1'b0),
                .Out (stage[i+1])
            );
        end
    endgenerate

    assign Out = stage[16];

endmodule



////////////////////
//Shift Left 8bit///
////////////////////
module ShiftLeft_8bit(
    input  logic [31:0] In,
    input  logic        enable,   // Cho phép dịch
    output logic [31:0] Out
);

    wire [31:0] stage [0:8];  // stage[0] là In, stage[8] là Out
    assign stage[0] = In;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : shift_stage
            Simple_Shifter sh (
                .In  (stage[i]),
                .ShL (enable),   // nếu enable=1 thì dịch, nếu 0 thì giữ nguyên
                .ShR (1'b0),
                .inR (1'b0),
                .inL (1'b0),     // logic shift: nạp 0 vào LSB
                .Out (stage[i+1])
            );
        end
    endgenerate

    assign Out = stage[8];  // kết quả cuối cùng

endmodule



////////////////////
//Shift Left 4bit///
////////////////////
module ShiftLeft_4bit(
    input  logic [31:0] In,
    input  logic        enable,
    output logic [31:0] Out
);

    wire [31:0] stage [0:4];  
    assign stage[0] = In;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : shift_stage
            Simple_Shifter sh (
                .In  (stage[i]),
                .ShL (enable),
                .ShR (1'b0),
                .inR (1'b0),
                .inL (1'b0),
                .Out (stage[i+1])
            );
        end
    endgenerate

    assign Out = stage[4];

endmodule



////////////////////
//Shift Left 2bit///
////////////////////
module ShiftLeft_2bit(
    input  logic [31:0] In,
    input  logic        enable,   // Cho phép dịch
    output logic [31:0] Out
);

    wire [31:0] stage [0:2];  
    assign stage[0] = In;

    genvar i;
    generate
        for (i = 0; i < 2; i = i + 1) begin : shift_stage
            Simple_Shifter sh (
                .In  (stage[i]),
                .ShL (enable),
                .ShR (1'b0),
                .inR (1'b0),
                .inL (1'b0),    // logic shift: nạp 0 vào LSB
                .Out (stage[i+1])
            );
        end
    endgenerate

    assign Out = stage[2];

endmodule

