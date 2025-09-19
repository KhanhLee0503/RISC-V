module Shift_Logic(a,b,sel_sr,r);
parameter N = 32;
input [N-1:0] a;
input [N-1:0] b;
input sel_sr;		//If sel_sr = 0 ,the operation is ShiftLeft, else Shift Right
output [N-1:0] r;	

wire [N-1:0] sll_o;
wire [N-1:0] srl_o;

ShiftLeft_Logic sll(.a(a), .b(b), .y(sll_o));
ShiftRight_Logic srl(.a(a), .b(b), .y(srl_o));
				
mux2to1_32bit mux1(.In1(sll_o), .In2(srl_o), .sel(sel_sr), .out(r));			
endmodule



///////////////////////////
//Shift Left Logic Block//
///////////////////////////
module ShiftLeft_Logic(a, b, y);
    parameter N = 32;
    input [N-1:0] a;
    input [4:0] b; // The hien so bit can dich
    output reg[N-1:0] y;

    always_comb begin
        reg [N-1:0] temp_shift;
        temp_shift = a;
        
        // Stage 1
        if (b[0]) begin
            temp_shift = {temp_shift[N-2:0], 1'b0};
        end
        
        // Stage 2
        if (b[1]) begin
            temp_shift = {temp_shift[N-3:0], 2'b0};
        end
        
        // Stage 3
        if (b[2]) begin
            temp_shift = {temp_shift[N-5:0], 4'b0};
        end
        
        // Stage 4
        if (b[3]) begin
            temp_shift = {temp_shift[N-9:0], 8'b0};
        end
        
        // Stage 5
        if (b[4]) begin
            temp_shift = {temp_shift[N-17:0], 16'b0};
        end
    
        y = temp_shift;
    end
endmodule



///////////////////////////
//Shift Right Logic Block//
///////////////////////////
module ShiftRight_Logic(a, b, y);
    parameter N = 32;
    input [N-1:0] a;
    input [4:0] b; // 5 bit hien thi so bit muon dich
    output reg[N-1:0] y;

    always_comb begin
        reg [N-1:0] temp_shift;
        temp_shift = a;
        
		  //Stage 1
        if (b[0]) begin
            temp_shift = {1'b0, temp_shift[N-1:1]};
        end
        
        //Stage 2
        if (b[1]) begin
            temp_shift = {2'b0, temp_shift[N-1:2]};
        end
        
        // Stage 3
        if (b[2]) begin
            temp_shift = {4'b0, temp_shift[N-1:4]};
        end
        
        // Stage 4
        if (b[3]) begin
            temp_shift = {8'b0, temp_shift[N-1:8]};
        end
        
        // Stage 5
        if (b[4]) begin
            temp_shift = {16'b0, temp_shift[N-1:16]};
        end
        
        y = temp_shift;
    end
endmodule


//////////////////////
//MUX 2 to 1 - 32bit//
//////////////////////
module mux2to1_32bit(input [31:0]In1, input [31:0]In2, input sel, output reg[31:0]out);
always_comb begin
	case(sel)
		1'b0: out = In1;
		1'b1: out = In2;
		default : out = 32'b0;
	endcase
end
endmodule	

