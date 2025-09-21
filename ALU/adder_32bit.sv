module adder_32bit(A, B, sel, OUT, CarryOut);
parameter N = 32;
input [N-1:0] A;
input [N-1:0] B;
input sel;	//If sel=0, the operation is addition, else subtraction
output [N-1:0] OUT;
output CarryOut;
genvar i;
wire [N:0] C;

assign CarryOut = 0;
assign C[0] = sel;
assign C[N] = CarryOut;

generate
    for(i=0; i<N; i=i+1) begin : adder
        adder_1bit stage(.in1(A[i]), .in2(B[i]), .in3(C[i]), .sel(sel), .S(OUT[i]), .C(C[i+1]));
    end
endgenerate
endmodule


module adder_1bit(input in1, in2, in3, sel,
                  output S, C);
assign S = (in2^sel)^in1^in3;
assign C = ((in2^sel)&in1)|(in3&((in2^sel)^in1));
endmodule