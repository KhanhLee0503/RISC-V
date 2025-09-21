`timescale 1ns/1ns

module memory_test();
parameter N = 9; 
reg i_wren;
reg i_clk;
reg i_reset;
reg [3:0] i_bmask;				//Dung de chon lb, lh hay lw
reg [31:0] i_wdata;			//Data Write
reg [N-1:0] i_addr;			//Dia chi bo nho
wire [31:0] o_rdata;

//Initialize a second memory to test
reg [31:0] sub_memory [0:511];


 memory dut (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_wren(i_wren),
    .i_bmask(i_bmask),
    .i_wdata(i_wdata),
    .i_addr(i_addr),
    .o_rdata(o_rdata)
);

initial begin
    i_clk = 1'b0;
    forever begin
        #5 i_clk = ~i_clk;
    end
end

initial begin
    //Reset DUT
    i_reset = 1'b1;
    i_wren = 1'b0;
    i_addr = 0;
    i_wdata = 0;
    i_bmask = 4'b0000;
    #10 i_reset = 1'b0;
    

    $display("Uploading data from image.hex to sub_memory...");
    $readmemh("random_512x32.hex", sub_memory, 0, 511);

    @(posedge i_clk);

    $display("Start writing data from sub_memory to memory!!");
        for(integer i=0; i<512; i=i+1) begin
            i_wren = 1'b1;
            i_bmask = 4'b1111;
            i_addr = i;
            i_wdata = sub_memory[i];
            @(posedge i_clk);
        end
        $display("Finished writing data.");


    i_wren = 1'b0;
    @(posedge i_clk);


    $display("Reading data from the main memory!!");
    for(integer i=0; i<512; i=i+1) begin
        i_addr = i;
        #1
        if (o_rdata == sub_memory[i])  $display("PASSED: Address 0x%h - Data Matched", i);
        else $display("Failed: Address 0x%h - Not Expected Data", i);
    end
end
endmodule