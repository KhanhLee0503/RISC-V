module InstrMem(
					input logic [10:0] i_addr,
					output logic [31:0] o_rdata
					);
					
(* ramstyle = "M9K" *) logic [31:0] mem_word [0:511];

initial begin
	$readmemh("C:/SystemVerilog/InstrMem/program.hex", mem_word);
end

always_comb begin
	o_rdata = mem_word[i_addr[10:2]];
end
endmodule
