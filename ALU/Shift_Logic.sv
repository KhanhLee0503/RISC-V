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
module ShiftLeft_Logic(a,b,y);
parameter N = 32;
input [N-1:0] a;
input [N-1:0] b;
output [N-1:0] y;
		always_comb begin
			case(b) 
			32'd0 : y={a[N-1:0]};
			32'd1 : y={a[N-2:0],1'b0};
			32'd2 : y={a[N-3:0],2'b0};
			32'd3 : y={a[N-4:0],3'b0};
			32'd4 : y={a[N-5:0],4'b0};
			32'd5 : y={a[N-6:0],5'b0};
			32'd6 : y={a[N-7:0],6'b0};
			32'd7 : y={a[N-8:0],7'b0};
			32'd8 : y={a[N-9:0],8'b0};
			32'd9 : y={a[N-10:0],9'b0};
			32'd10 : y={a[N-11:0],10'b0};
			32'd11 : y={a[N-12:0],11'b0};
			32'd12 : y={a[N-13:0],12'b0};
			32'd13 : y={a[N-14:0],13'b0};
			32'd14 : y={a[N-15:0],14'b0};
			32'd15 : y={a[N-16:0],15'b0};
			32'd16 : y={a[N-17:0],16'b0};
			32'd17 : y={a[N-18:0],17'b0};
			32'd18 : y={a[N-19:0],18'b0};
			32'd19 : y={a[N-20:0],19'b0};
			32'd20 : y={a[N-21:0],20'b0};
			32'd21 : y={a[N-22:0],21'b0};
			32'd22 : y={a[N-23:0],22'b0};
			32'd23 : y={a[N-24:0],23'b0};
			32'd24 : y={a[N-25:0],24'b0};
			32'd25 : y={a[N-26:0],25'b0};
			32'd26 : y={a[N-27:0],26'b0};
			32'd27 : y={a[N-28:0],27'b0};
			32'd28 : y={a[N-29:0],28'b0};
			32'd29 : y={a[N-30:0],29'b0};
			32'd30 : y={a[N-31:0],30'b0};
			32'd31 : y={a[0],31'b0};
			default y=32'b0;
			endcase
			end
endmodule



///////////////////////////
//Shift Right Logic Block//
///////////////////////////
module ShiftRight_Logic(a,b,y);
parameter N = 32;
input [N-1:0] a;
input [N-1:0] b;
output [N-1:0] y;	
						
			always_comb begin
			case(b) 
			32'd0 : y={ a[N-1:0]};
			32'd1 : y={1'b0 , a[N-1:1 ]};
			32'd2 : y={2'b0 , a[N-1:2 ]};
			32'd3 : y={3'b0 , a[N-1:3 ]};
			32'd4 : y={4'b0 , a[N-1:4 ]};
			32'd5 : y={5'b0 , a[N-1:5 ]};
			32'd6 : y={6'b0 , a[N-1:6 ]};
			32'd7 : y={7'b0 , a[N-1:7 ]};
			32'd8 : y={8'b0 , a[N-1:8 ]};
			32'd9 : y={9'b0 , a[N-1:9 ]};
			32'd10 : y={10'b0 , a[N-1:10 ]};
			32'd11 : y={11'b0 , a[N-1:11 ]};
			32'd12 : y={12'b0 , a[N-1:12 ]};
			32'd13 : y={13'b0 , a[N-1:13 ]};
			32'd14 : y={14'b0 , a[N-1:14 ]};
			32'd15 : y={15'b0 , a[N-1:15 ]};
			32'd16 : y={16'b0 , a[N-1:16 ]};
			32'd17 : y={17'b0 , a[N-1:17 ]};
			32'd18 : y={18'b0 , a[N-1:18 ]};
			32'd19 : y={19'b0 , a[N-1:19 ]};
			32'd20 : y={20'b0 , a[N-1:20 ]};
			32'd21 : y={21'b0 , a[N-1:21 ]};
			32'd22 : y={22'b0 , a[N-1:22 ]};
			32'd23 : y={23'b0 , a[N-1:23 ]};
			32'd24 : y={24'b0 , a[N-1:24 ]};
			32'd25 : y={25'b0 , a[N-1:25 ]};
			32'd26 : y={26'b0 , a[N-1:26 ]};
			32'd27 : y={27'b0 , a[N-1:27 ]};
			32'd28 : y={28'b0 , a[N-1:28 ]};
			32'd29 : y={29'b0 , a[N-1:29 ]};
			32'd30 : y={30'b0 , a[N-1:30 ]};
			32'd31 : y={31'b0 , a[N-1]};
			default y=32'b0;
			endcase
			end
endmodule

//////////////////////
//MUX 2 to 1 - 32bit//
//////////////////////
module mux2to1_32bit(input [31:0]In1, input [31:0]In2, input sel, output [31:0]out);
wire [31:0]out_bar;
always_comb begin
	case(sel)
		1'b0: out_bar = In1;
		1'b1: out_bar = In2;
		default : out_bar = 32'b0;
	endcase
end
assign out = out_bar;
endmodule	

