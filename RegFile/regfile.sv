module regfile(input i_clk,
					input i_reset,
					input [4:0] i_rs1_addr,
					input [4:0] i_rs2_addr,
					output [31:0] o_rs1_data,
					output [31:0] o_rs2_data,
					input [4:0] i_rd_addr,
					input [31:0] i_rd_data,
					input i_rd_wren);
genvar j;
wire [31:0] reg_load;
wire [31:0] reg_load_en;	
wire [31:0] reg_out[31:0];
decoder5to32 decoder1(.in(i_rd_addr), .out(reg_load));


assign reg_load_en[31:1] = reg_load[31:1] & {31{i_rd_wren}};
assign reg_load_en[0] = reg_load[0] & 1'b0;

generate 
for(j=0; j<32; j=j+1) begin: register
	reg_32bit registers(.clock(i_clk), .data_in(i_rd_data), .clear(i_reset), .load(reg_load_en[j]), .out(reg_out[j]));
end
endgenerate

mux32to1 source1(.in(reg_out), .sel(i_rs1_addr), .out(o_rs1_data));
mux32to1 source2(.in(reg_out), .sel(i_rs2_addr), .out(o_rs2_data));

endmodule

//-------------------------------Sub_Modules---------------------------------//

/////////////////
//DECODER 5->32//
/////////////////
module decoder5to32(in, out);
input [4:0] in;
output reg [31:0] out;

always_comb begin
	out = 32'b0;
	out[in] = 1'b1;
end
endmodule


/////////////
//MUX-32bit//
/////////////
module mux32to1(in, sel, out);
input [31:0] in[31:0];
input [4:0] sel;
output reg [31:0]out;

always_comb begin
	out = in[sel];
end
endmodule


////////////////////
//REGISTER - 32bit//
////////////////////
module reg_32bit(data_in, load, clear, clock, out);
input [31:0] data_in;
input load;
input clear;
input clock;
output reg [31:0] out;

always_ff@(posedge clock) begin
	if(clear) out <= 32'b0;
	else if (load) out <= data_in;
	else out <= out;
end

endmodule
