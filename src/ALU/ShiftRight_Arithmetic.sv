//////////////////////////
//Shift Right Arithmetic//
//////////////////////////
module ShiftRight_Arithmetic(
							input [31:0] In,
							input [4:0] ShAm,
							output logic [31:0] OUT
							 );
							 
wire [31:0] out_stage1;
wire [31:0] out_stage2;
wire [31:0] out_stage3;
wire [31:0] out_stage4;

ShiftRight_16bit_Arithmetic stage1(.In(In), .enable(ShAm[4]), .Out(out_stage1));
ShiftRight_8bit_Arithmetic stage2(.In(out_stage1), .enable(ShAm[3]), .Out(out_stage2));
ShiftRight_4bit_Arithmetic stage3(.In(out_stage2), .enable(ShAm[2]), .Out(out_stage3));
ShiftRight_2bit_Arithmetic stage4(.In(out_stage3), .enable(ShAm[1]), .Out(out_stage4));
Simple_Shifter stage5(.In(out_stage4), .ShL(1'b0), .ShR(ShAm[0]), .inR(In[31]), .inL(In[31]), .Out(OUT));

endmodule

//------------------------------Shift_Right----------------------------//
/////////////////////
//Shift Right 16bit//
/////////////////////
module ShiftRight_16bit_Arithmetic(
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
                .inR(In[31]),     // arithmetic shift: nạp 1 vào MSB
                .inL(In[31]),
                .Out(stage[i+1])
            );
        end
    endgenerate

    assign Out = stage[16];   // kết quả cuối

endmodule

/////////////////////
//Shift Right 8bit//
/////////////////////
module ShiftRight_8bit_Arithmetic(
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
                .inR (In[31]),     // arithmetic shift: nạp 1 vào MSB
                .inL (In[31]),
                .Out (stage[i+1])
            );
        end
    endgenerate

    assign Out = stage[8];  // kết quả cuối cùng

endmodule


////////////////////
//Shift Right 4bit//
////////////////////
module ShiftRight_4bit_Arithmetic(
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
        .inR(In[31]),     // \arithmetic shift: nạp 1 vào MSB
        .inL(In[31]),
        .Out(stage1_out)
    );

    // Lần 2: dịch thêm 1 bit
    Simple_Shifter sh2 (
        .In (stage1_out),
        .ShL(1'b0),
        .ShR(enable),
        .inR(In[31]),
        .inL(In[31]),
        .Out(stage2_out)
    );

    // Lần 3: dịch thêm 1 bit
    Simple_Shifter sh3 (
        .In (stage2_out),
        .ShL(1'b0),
        .ShR(enable),
        .inR(In[31]),
        .inL(In[31]),
        .Out(stage3_out)
    );

    // Lần 4: dịch thêm 1 bit
    Simple_Shifter sh4 (
        .In (stage3_out),
        .ShL(1'b0),
        .ShR(enable),
        .inR(In[31]),
        .inL(In[31]),
        .Out(Out)
    );

endmodule

////////////////////
//Shift Right 2bit//
////////////////////
module ShiftRight_2bit_Arithmetic(
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
        .inR(In[31]),     // arithmetic shift (nạp 1 vào MSB)
        .inL(In[31]),
        .Out(stage1_out)
    );

    // Lần 2: dịch thêm 1 bit nữa
    Simple_Shifter sh2 (
        .In (stage1_out),
        .ShL(1'b0),
        .ShR(enable),
        .inR(In[31]),
        .inL(In[31]),
        .Out(Out)
    );

endmodule

//////////////////
//Simple Shifter//
//////////////////
module Simple_Shifter(
    input  logic [31:0] In,
    input  logic ShL,       // Shift Left enable
    input  logic ShR,       // Shift Right enable
    input  logic inR,       // Mode Arithmetic or Logic
    input  logic inL,       // fill-in bit when shift left
    output logic [31:0] Out
);

    // Chọn chế độ dịch
    // 00: giữ nguyên
    // 01: shift right
    // 10: shift left
    // 11: clear (0)
    wire [1:0] sel = {ShL, ShR};

    // MSB (bit 31)
    mux4to1 mux_msb(
        .In1(In[31]),   // giữ nguyên
        .In2(inR),      // shift right -> nạp inR
        .In3(In[30]),   // shift left  -> lấy từ bit 30
        .In4(1'b0),     // clear
        .sel(sel),
        .out(Out[31])
    );

    // LSB (bit 0)
    mux4to1 mux_lsb(
        .In1(In[0]),    // giữ nguyên
        .In2(In[1]),    // shift right -> lấy từ bit 1
        .In3(inL),      // shift left  -> nạp inL
        .In4(1'b0),     // clear
        .sel(sel),
        .out(Out[0])
    );

    // Các bit ở giữa
    genvar i;
    generate
        for (i=1; i<31; i=i+1) begin : shifter
            mux4to1 mux_mid(
                .In1(In[i]),      // giữ nguyên
                .In2(In[i+1]),    // shift right -> lấy từ bit i+1
                .In3(In[i-1]),    // shift left  -> lấy từ bit i-1
                .In4(1'b0),       // clear
                .sel(sel),
                .out(Out[i])
            );
        end
    endgenerate

endmodule
