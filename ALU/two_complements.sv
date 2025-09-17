module two_complements(in, out);
parameter N = 32;
input [N-1:0] in;
output [N-1:0] out;
wire [N-1:0] out_bar;

XOR_32bit x1(.a(in), .b(32'hFFFF_FFFF), .s(out_bar));
adder_32bit a1(.A(out_bar), .B(32'h0000_0001), .sel(0), .OUT(out), .CarryOut(0));

endmodule



////////////////
// XOR 32 bit //
////////////////
module XOR_32bit(a,b,s);
			parameter n= 32;
			input [n-1:0] a,b;
			output [n-1:0] s;
			
			genvar i;
			generate
				for(i=0;i<n;i=i+1) begin : XOR_32bit
				assign s[i]=a[i]^b[i];
				end
			endgenerate
			endmodule



////////////////
// AND 32 bit //
////////////////
module AND_32bit(a,b,s);
			parameter n= 32;
			input [n-1:0] a,b;
			output [n-1:0] s;
			
			genvar i;
			generate
				for(i=0;i<n;i=i+1) begin : AND_32bit
				assign s[i]=a[i]&b[i];
				end
			endgenerate
			endmodule			

		

////////////////
// OR 32 bit //
////////////////
module OR_32bit(a,b,s);
			parameter n= 32;
			input [n-1:0] a,b;
			output [n-1:0] s;
			
			genvar i;
			generate
				for(i=0;i<n;i=i+1) begin : OR_32bit
				assign s[i]=a[i]|b[i];
				end
			endgenerate
			endmodule	

			
			
