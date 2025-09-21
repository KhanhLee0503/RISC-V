module memory(i_clk, i_reset, i_addr, i_wdata, i_bmask, i_wren, o_rdata);
parameter N = 9; 				//9bit => 512 word * 4byte => 2kB
input i_clk, i_reset, i_wren;	
input [3:0] i_bmask;				//Dung de chon lb, lh hay lw
input [31:0] i_wdata;			//Data Write
input [N-1:0] i_addr;			//Dia chi bo nho
output reg [31:0] o_rdata;		//Ngo ra Read

//Bao gom 512 o nho, moi o nho la 32bit
reg [31:0] mem_word[0:511];

always_ff@(posedge i_clk) begin
	//Reset toan bo thanh ghi
	if(i_reset)	begin
		for(integer i=0; i<512; i=i+1) begin
			mem_word[i] = 32'b0;
		end
	end
	
	//Write Data to mem_word
	else if (i_wren) begin
		if(i_bmask[0]) mem_word[i_addr][7:0] <= i_wdata[7:0];
		if(i_bmask[1]) mem_word[i_addr][15:8] <= i_wdata[15:8];
		if(i_bmask[2])	mem_word[i_addr][23:16] <= i_wdata[23:16];
		if(i_bmask[3])	mem_word[i_addr][31:24] <= i_wdata[31:24];
	end
end
 
//Data Output
always_comb begin
	if(!i_wren) o_rdata = mem_word[i_addr];
	else o_rdata = 32'bX;
end
 
endmodule
