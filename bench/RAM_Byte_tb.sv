`timescale 1ns/1ns
module RAM_Byte_test(); 
reg clk, reset;
reg [10:0] addr;
reg [31:0] wdata;
reg [3:0]  bmask;
reg        wren;
wire [31:0] rdata;

// Instantiate DUT
RAM_Byte DUT(
    .i_clk(clk),
    .i_reset(reset),
    .i_addr(addr),
    .i_wdata(wdata),
    .i_bmask(bmask),
    .i_wren(wren),
    .o_rdata(rdata)
);

// Clock generation
always #5 clk = ~clk;

// Test sequence
initial begin
    $display("=== RAM_Byte Test Start ===");
    clk = 0;
    reset = 1;
    wren = 0;
    addr = 0;
    wdata = 0;
    bmask = 4'b0000;

    #10 reset = 0;

    // --- Test 1: Write and read full word ---
    addr  = 11'd400;       // word index = 0x190
    wdata = 32'hDEADBEEF;
    bmask = 4'b1111;     // word access
    wren  = 1;
    #10 wren = 0;
    #10;
    assert(rdata == 32'hDEADBEEF) else $error("Word write/read failed: %h", rdata);

    // --- Test 2: Read Byte 0x193
    addr  = 11'd403;
    bmask = 4'b0001;     // Byte acces
    #10;
    assert(rdata == 32'h000000DE) else $error("Word write/read failed: %h", rdata);


    // --- Test 3: Write only lower byte ---
    addr  = 11'd3;
    wdata = 32'h000000AA;
    bmask = 4'b0001;     // byte access
    wren  = 1;
    #10 wren = 0;
    #10;
    assert(rdata == 32'h000000AA) else $error("Byte write failed: %h", rdata);

    // --- Test 4: Write halfword at offset 00 ---
    addr  = 11'd4;
    wdata = 32'h0000BEEF;
    bmask = 4'b0011;
    wren  = 1;
    #10 wren = 0;
    #10;
    assert(rdata == 32'h0000BEEF) else $error("Halfword write failed: %h", rdata);

    // --- Test 5: Reset clears all memory ---
    reset = 1;
    #10 reset = 0;
    #10;
    addr = 11'd3;
    #1;
    assert(rdata == 32'h00000000) else $error("Reset failed: %h", rdata);

    $display("=== All tests completed successfully ===");
    $finish;
end
endmodule