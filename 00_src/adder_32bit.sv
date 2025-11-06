module CLA_4bit( input [3:0] P,G,
						input ci,
						output P0,G0,
						output [3:0] c);
	assign c[3]=G[2]|(P[2]&G[1])|(P[2]&P[1]&G[0])|(P[2]&P[1]&P[0]&ci);
	assign G0=(P[3]&P[2]&P[1]&G[0])|(P[3]&P[2]&G[1])|(P[3]&G[2])|G[3];					
	//assign cout= G[3]|(P[3]&G[2])|(P[3]&P[2]&G[1])|(P[3]&P[2]&P[1]&G[0])|(P[3]&P[2]&P[1]&P[0]&ci);,output cout
	assign c[2]=G[1]|(P[1]&G[0])|(P[1]&P[0]&ci);
	assign P0=P[0]&P[1]&P[2]&P[3];
	assign c[1]=G[0]|(P[0]&ci);
	assign c[0]= ci;

	endmodule
	
	module CLA_16bit( input [15:0] P,G,
							input ci,
							output P0,G0,
						output [15:0] c	
	
	);
	logic [3:0] WP,WG; 
	CLA_4bit u1(.P(P[3:0]), .G(G[3:0]), .ci(ci), .G0(WG[0]), .P0(WP[0]), .c(c[3:0]));
	CLA_4bit u2(.P(P[7:4]), .G(G[7:4]), .ci(c[4]), .G0(WG[1]), .P0(WP[1] ), .c(c[7:4]));
	CLA_4bit u3(.P(P[11:8]), .G(G[11:8]), .ci(c[8]), .G0(WG[2]), .P0(WP[2]), .c(c[11:8]));
	CLA_4bit u4(.P(P[15:12]), .G(G[15:12]), .ci(c[12]), .G0(WG[3]), .P0(WP[3]), .c(c[15:12]));
	CLA_4bit u5(.P(WP), .G(WG), .ci(ci), .G0(G0), .P0(P0), .c({c[12],c[8],c[4],ci}));
	endmodule 
	module CLA_2bit(input [1:0] P,G,
						input ci,
						output P0,G0,
						output [1:0] c
	);
	assign P0=P[1]&P[0];
	assign G0=G[1]|(P[1]&G[0]);
	assign c[1]= G[0]|(P[0]&ci);
	assign c[0]=ci;
	endmodule 
	
	
module CLA_32bit_3stage(
								input [31:0] G,P,
								output P0,G0,
								input ci,
								output [32:0] c		
);	
		assign c[0]=ci;
		logic [1:0] G016,P016;
		CLA_2bit u1(.P0(P0), .G0(G0), .ci(ci), .c({c[16],ci}), .G(G016), .P(P016))  ;
		CLA_16bit u2(.P0(P016[0]), .G0(G016[0]), .c(c[15:0]), .ci(ci), .P(P[15:0]), .G(G[15:0]));
		CLA_16bit u3(.P0(P016[1]), .G0(G016[1]), .c(c[31:16]), .ci(c[16]), .P(P[31:16]), .G(G[31:16]));
		assign c[32]=G0|(P0&ci);
		endmodule 
		
		


	module SPG_32bit( input [31:0] a,b,
							input [32:0] c,
							output [31:0] s,
							output [31:0] G,P,
							input sel
							
							);
							logic [31:0] wb;
							genvar i ;
							generate 
							for (i=0;i<32;i++) begin : SPG_block
							assign wb[i]=b[i]^sel;
						assign	G[i]= a[i]&wb[i];
						assign 	P[i]= a[i]^wb[i];
						assign 	s[i]= P[i]^c[i];
						end 
						endgenerate 
						endmodule 
										
						
 module adder_32bit(input [31:0]A,B,
								input sel,
								output [31:0] OUT,
								output CarryOut
							
								);	
				logic [31:0] WP,WG;
				logic [32:0] WC;
		SPG_32bit u1(.a(A), .b(B), .G(WG), .P(WP), .s(OUT), .c(WC), .sel(sel));
		CLA_32bit_3stage u2(.P(WP), .G(WG), .c(WC), .ci(sel)); 
		assign CarryOut = WC[32]; 
		endmodule 
						
							




