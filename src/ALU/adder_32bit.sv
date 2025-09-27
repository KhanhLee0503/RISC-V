module adder_32bit(A, B, sel, OUT, CarryOut);
parameter N = 32;	            //Number of bits is 32
input logic [N-1:0] A;			//First operand
input logic [N-1:0] B;			//Second operand
input logic sel;				//If sel=0, the operation is addition, else subtraction
output logic [N-1:0] OUT;		//The Result of the calculation
output logic CarryOut;

genvar i;
wire [N:0] C;

assign C[0] = sel;
assign CarryOut = C[N];

generate
    for(i=0; i<N; i=i+1) begin : stage
        adder_1bit adder(.in1(A[i]), .in2(B[i]^sel), .in3(C[i]), .S(OUT[i]), .C(C[i+1]));
    end
endgenerate
endmodule

//-------------------------Sub_Modules----------------------------//

/////////////////////
// Full Adder 1 bit//
/////////////////////
module adder_1bit(input logic in1, in2, in3,
                  output logic S, C);
assign S = in2^in1^in3;
assign C = (in2&in1)|(in3&(in2^in1));
endmodule

