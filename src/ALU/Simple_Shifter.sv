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
