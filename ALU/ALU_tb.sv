`timescale 1ns/1ns

module ALU_tb();
reg signed [31:0] a;
reg signed [31:0] b;
reg [3:0] op;
wire signed [31:0] r;

parameter ADD  = 4'b0000;
parameter SUB  = 4'b0001;
parameter SLT  = 4'b0010;
parameter SLTU = 4'b0011;
parameter XOR  = 4'b0100;
parameter OR   = 4'b0101;
parameter AND  = 4'b0110;
parameter SLL  = 4'b0111;
parameter SRL  = 4'b1000;
parameter SRA  = 4'b1001;

ALU dut(.i_op_a(a), .i_op_b(b), .i_alu_op(op), .o_alu_data(r));

initial begin
    a = 32'd3232453;
    b = 32'd4995;
    op =  ADD;
  
    #10
    a = -32'd3232453;
    b = -32'd4995;
    op =  ADD;

    #10
    a = 32'd43750349;
    b = -32'd392837334;
    op =  SUB;
  
    
    #10
    a = 32'd12398;
    b = 32'd45;
    op =  XOR;

    
    #10
    a = 32'd12398;
    b = 32'd45;
    op =  OR;
    
    
    #10
    a = 32'd1800000032;
    b = 32'd1283744400;
    op =  AND;

    #10
    a = 32'd49;
    b = 32'd5;
    op =  SLL;

    #10
    a = 32'd12033;
    b = 32'd5;
    op =  SRL;

    #10
    a = -32'd25002;
    b = -32'd4000;
    op =  SLTU;

    #10
    a = -32'd18930002;
    b = 32'd102847;
    op =  SLTU;

     #10
    a = 32'd75830;
    b = -32'd2834000;
    op =  SLTU;

    #10
    a = 32'd25002;
    b = 32'd4000;
    op =  SLTU;

    #10
    a = 32'd125002;
    b = 32'd3404000;
    op =  SLTU;


    #10
    a = -32'd25002;
    b = -32'd4000;
    op =  SLT;

    #10
    a = -32'd18930002;
    b = 32'd102847;
    op =  SLT;

     #10
    a = 32'd75830;
    b = -32'd2834000;
    op =  SLT;

    #10
    a = 32'd25002;
    b = 32'd4000;
    op =  SLT;

    #10
    a = 32'd125002;
    b = 32'd3404000;
    op =  SLT;

    #10
    a = -32'd445060133;
    b = 32'd15;
    op =  SRA;
end   
    
always@ (*) begin
    #1
    case(op)
        ADD: begin
            //r_ = a + b;
            if (r == a + b) $display ("[%t][Information] Operation is ADD. a is %d, b is %d, result is %d, correct!", $time,a,b,r);
            else $display ("[%t][Information] Operation is ADD a is %d, b is %d, result is %d, NOT correct!", $time,a,b,r);
        end
        SUB: begin
            //r_ = a - b;
            if (r == a - b) $display ("[%t][Information] Operation is SUB. a is %d, b is %d, result is %d, correct!", $time,a,b,r);
            else $display ("[%t][Information] Operation is SUB.a is %d, b is %d, result is %d, NOT correct!", $time,a,b,r);
        end
        XOR: begin
            //r_ = a ^ b;
            if (r == (a ^ b)) $display ("[%t][Information] Operation is XOR. a is %d, b is %d, result is %d, correct!", $time,a,b,r);
            else $display ("[%t][Information] Operation is XOR. a is %d, b is %d, result is %d, NOT correct!", $time,a,b,r);
        end
        OR: begin
            //r_ = a | b;
            if (r == (a | b)) $display ("[%t][Information] Operation is OR. a is %d, b is %d, result is %d, correct!", $time,a,b,r);
            else $display ("[%t][Information] Operation is OR. a is %d, b is %d, result is %d, NOT correct!", $time,a,b,r);
        end
        AND: begin
            //r_ = a & b;
            if (r == (a & b)) $display ("[%t][Information] Operation is AND. a is %d, b is %d, result is %d, correct!", $time,a,b,r);
            else $display ("[%t][Information] Operation is AND. a is %d, b is %d, result is %d, NOT correct!", $time,a,b,r);
        end
        SLL: begin
            //r_ = a << b;
            if (r == a << b) $display ("[%t][Information] Operation is Shift Left Logic. a is %d, b is %d, result is %d, correct!", $time,a,b,r);
            else $display ("[%t][Information] Operation is Shift Left Logic. a is %d, b is %d, result is %d, NOT correct!", $time,a,b,r);
        end
        SRL: begin
            //r_ = a >> b;
            if (r == a >> b) $display ("[%t][Information] Operation is Shift Right Logic. a is %d, b is %d, result is %d, correct!", $time,a,b,r);
            else $display ("[%t][Information] Operation is Shift Right Logic. a is %d, b is %d, result is %d, NOT correct!", $time,a,b,r);
        end
        SRA: begin
            //r_ = a >>> b;
            if (r == a >>> b) $display ("[%t][Information] Operation is Shift Right Arithmetic. a is %d, b is %d, result is %d, correct!", $time,a,b,r);
            else $display ("[%t][Information] Operation is Shift Right Arithmetic. a is %d, b is %d, result is %d, NOT correct!", $time,a,b,r);
        end
        SLTU: begin
            //r_ = unsigned (a < b);
            if (r == $unsigned(a) < $unsigned(b) ) $display ("[%t][Information] Operation is Set Less Than Unsigned. a is %d, b is %d, result is %d, correct!", $time,a,b,r);
            else $display ("[%t][Information] Operation is Set Less Than Unsigned. a is %d, b is %d, result is %d, NOT correct!", $time,a,b,r);
        end
        SLT: begin
            //r_ = a < b;
            if (r == $signed(a) < $signed(b) ) $display ("[%t][Information] Operation is Set Less Than. a is %d, b is %d, result is %d, correct!", $time,a,b,r);
            else $display ("[%t][Information] Operation is Set Less Than. a is %d, b is %d, result is %d, NOT correct!", $time,a,b,r);
        end

        default: $display ("[%t][Warning] Operator is invalid!", $time);
    endcase
end


endmodule