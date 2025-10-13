module DataMem(
    input logic i_clk,
    input logic i_reset,
    input logic [10:0] i_addr,
    input logic [31:0] i_wdata,
    input logic [3:0] i_bmask, // 4 bits mask for 4 bytes
    input logic i_wren,
    output logic [31:0] o_rdata
);

// 512 words x 32 bits = 2 KB of memory
reg [31:0] mem_word [0:511];

logic [8:0] word_addr;
assign word_addr = i_addr[10:2];

// --- Write Logic (Synchronous) ---
always_ff @(posedge i_clk or posedge i_reset) begin
    if (i_reset) begin
        // Correct Full Memory Reset
        for(integer i=0; i<512; i=i+1) begin
            mem_word[i] <= 32'b0;
        end
    end
    
    else if (i_wren) begin
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
        o_rdata = mem_word[word_addr];
    end
    else begin
        o_rdata = 32'b0;
    end
end
endmodule