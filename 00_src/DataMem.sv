module DataMem(
    input  logic        i_clk,
    input  logic [10:0] i_addr,     // byte address
    input  logic [31:0] i_wdata,
    input  logic [3:0]  i_bmask,    // 4’b1111=word, 0011=half, 0001=byte
    input  logic        i_wren,
    output logic [31:0] o_rdata
);

    logic [31:0] temp_word;
    logic [31:0] next_word;
    integer low_bits;
    integer high_bits;
    // 512 words x 32 bits = 2 KB memory
    reg [31:0] mem_word [0:511];

    initial begin
        $readmemh("/home/yellow/ktmt_l01_l02_6/workspace/singlecyle_test/02_test/dump/reset.hex", mem_word);
    end

    // Word index & byte offset
    logic [8:0] word_addr;
    logic [1:0] byte_offset;
    assign word_addr   = i_addr[10:2];
    assign byte_offset = i_addr[1:0];

    // ------------------------------------------------------------------------
    // WRITE (synchronous)
    // ------------------------------------------------------------------------
    always_ff @(posedge i_clk) begin
        if (i_wren) begin
            temp_word <= mem_word[word_addr];
            next_word <= mem_word[word_addr + 1];

            // ============ STORE WORD (SW) ============
            if (i_bmask == 4'b1111) begin
                // Nếu bị lệch, cần chia dữ liệu thành 2 phần ghi vào 2 word
                if (byte_offset == 0)
                    mem_word[word_addr] <= i_wdata;
                else begin
                    // Ví dụ: addr = 0x...01 → lệch 1 byte
                    low_bits  = 8 * byte_offset;
                    high_bits = 32 - low_bits;
                    mem_word[word_addr]       <= (temp_word & ~(32'hFFFFFFFF << low_bits))
                                               | (i_wdata << low_bits);
                    mem_word[word_addr + 1]   <= (next_word & ~(32'hFFFFFFFF >> high_bits))
                                               | (i_wdata >> high_bits);
                end
            end

            // ============ STORE HALF (SH) ============
            else if (i_bmask == 4'b0011) begin
                // Nếu nằm trong 1 word
                if (byte_offset <= 2)
                    mem_word[word_addr][(byte_offset*8)+:16] <= i_wdata[15:0];
                else begin
                    // Xuyên qua 2 word (ví dụ addr = ...3)
                    mem_word[word_addr][31:24] <= i_wdata[7:0];
                    mem_word[word_addr + 1][7:0] <= i_wdata[15:8];
                end
            end

            // ============ STORE BYTE (SB) ============
            else if (i_bmask == 4'b0001) begin
                mem_word[word_addr][(byte_offset*8)+:8] <= i_wdata[7:0];
            end
        end
    end

    // ------------------------------------------------------------------------
    // READ (combinational, hỗ trợ misaligned)
    // ------------------------------------------------------------------------
    always_comb begin
        logic [63:0] combined;
        combined = {mem_word[word_addr + 1], mem_word[word_addr]};
        o_rdata = 32'b0;

        if (!i_wren) begin
            case (i_bmask)
                // ========= LOAD WORD (LW) =========
                4'b1111: o_rdata = combined >> (byte_offset * 8);

                // ========= LOAD HALF (LH) =========
                4'b0011: o_rdata = (combined >> (byte_offset * 8)) & 32'h0000FFFF;

                // ========= LOAD BYTE (LB) =========
                4'b0001: o_rdata = (combined >> (byte_offset * 8)) & 32'h000000FF;

                default: o_rdata = mem_word[word_addr];
            endcase
        end
    end

endmodule


/*
module DataMem(
    input logic i_clk,
    input logic [10:0] i_addr,
    input logic [31:0] i_wdata,
    input logic [3:0] i_bmask, // 4 bits mask for 4 bytes
    input logic i_wren,
    output logic [31:0] o_rdata
);

// 512 words x 32 bits = 2 KB of memory
reg [31:0] mem_word [0:511];

initial begin
	$readmemh("/home/yellow/ktmt_l01_l02_6/workspace/singlecyle_test/02_test/dump/reset.hex", mem_word);
end

logic [8:0] word_addr;
assign word_addr = i_addr[10:2];

logic [1:0] byte_offset;
assign byte_offset = i_addr[1:0];
// --- Write Logic (Synchronous) ---
always_ff @(posedge i_clk) begin
 if (i_wren) begin
			//-------------Write Word------------------------
        if (i_bmask == 4'b1111) begin
            mem_word[word_addr] <= i_wdata;
        end
        
		  //--------------Write Half Word-------------------
        else if (i_bmask == 4'b0011) begin
            if (i_addr[0] == 1'b0) begin
                if (i_addr[1] == 1'b0) 
                    mem_word[word_addr][15:0] <= i_wdata[15:0];	// Write two low bytes
                else 									
                    mem_word[word_addr][31:16] <= i_wdata[15:0];	// Write two high bytes
            end
        end
        
		  //--------------Write Byte------------------------
        else begin
            // Byte 0 (bits [7:0])
            if (i_bmask == 4'b0001) begin
                if (i_addr[1:0] == 2'b00) 
                    mem_word[word_addr][7:0] <= i_wdata[7:0];
        
            
            // Byte 1 (bits [15:8])
                else if (i_addr[1:0] == 2'b01) 
                    mem_word[word_addr][15:8] <= i_wdata[7:0];
            
            
            // Byte 2 (bits [23:16])
                else if (i_addr[1:0] == 2'b10) 
                    mem_word[word_addr][23:16] <= i_wdata[7:0];
        
            
            // Byte 3 (bits [31:24])
                else if (i_addr[1:0] == 2'b11) 
                    mem_word[word_addr][31:24] <= i_wdata[7:0];   
            end
        end
    end
end

// --- Read Logic (Combinational) ---
always_comb begin
    if(!i_wren) begin
        if (i_bmask == 4'b1111)
            o_rdata = mem_word[word_addr];
        
        if ((i_bmask == 4'b0011)&&((byte_offset == 2'b00)||(byte_offset == 2'b10)))
            o_rdata = mem_word[word_addr] >> (byte_offset*8);
        
        else if (i_bmask == 4'b0001)
            o_rdata = mem_word[word_addr] >> (byte_offset*8);
        else 
            o_rdata = mem_word[word_addr];
        
    end
    else begin
        o_rdata = 32'b0;
    end
end
endmodule
*/