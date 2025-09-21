module BRC_test();
reg sign_sel;
reg signed[31:0] a;
reg signed[31:0] b;
wire Equal;
wire LessThan;
parameter SIGNED = 1'b1;
parameter UNSIGNED = 1'b0;
BRC dut(.i_rs1_data(a), .i_rs2_data(b), .i_br_un(sign_sel), .o_br_less(LessThan), .o_br_equal(Equal));

initial begin
     #10
    a = -32'd2002;
    b = -32'd4000;
    sign_sel = SIGNED;

    #10
    a = -32'd18930002;
    b = 32'd1847;
    sign_sel = SIGNED;

     #10
    a = 32'd75830;
    b = -32'd1000;
    sign_sel = SIGNED;

    #10
    a = 32'd25002;
    b = 32'd4000;
    sign_sel = SIGNED;

    #10
    a = 32'd125002;
    b = 32'd3404000;
    sign_sel = SIGNED;

    #10
    a = 32'd12500;
    b = 32'd12500;
    sign_sel = SIGNED;
    
    #10
    a = -32'd12500;
    b = -32'd12500;
    sign_sel = SIGNED;

    #10
    a = -32'd25002;
    b = -32'd4000;
    sign_sel = UNSIGNED;

    #10
    a = -32'd18930002;
    b = 32'd102847;
    sign_sel = UNSIGNED;

     #10
    a = 32'd75830;
    b = -32'd2834000;
    sign_sel = UNSIGNED;

    #10
    a = 32'd25002;
    b = 32'd4000;
    sign_sel = UNSIGNED;

    #10
    a = 32'd125002;
    b = 32'd3404000;
    sign_sel = UNSIGNED;

    #10
    a = 32'd12500;
    b = 32'd12500;
    sign_sel = UNSIGNED;

    #10
    a = -32'd12500;
    b = -32'd12500;
    sign_sel = UNSIGNED;
end

always@ (*) begin
    #1
    case(sign_sel)
        SIGNED: begin
            //r_ = a < b ;
            if (LessThan == $signed(a) < $signed(b)) $display("[%t][Information] Operation is Compare Signed. a is %d, b is %d, Equal is %d, LessThan is %d, correct!", $time,a,b,Equal,LessThan);
            else if (Equal == (a==b)) $display("[%t][Information] Operation is Compare Signed. a is %d, b is %d, Equal is %d, LessThan is %d, correct!", $time,a,b,Equal,LessThan);
            else $display("[%t][Information] Operation is Compare Signed. a is %d, b is %d, Equal is %d, LessThan is %d, NOT correct!", $time,a,b,Equal,LessThan);
        end
        UNSIGNED: begin
            //r_ = a < b unsigned;
            if ( LessThan ==  $unsigned(a) < $unsigned(b)) $display ("[%t][Information] Operation is Compare Unsigned. a is %d, b is %d, Equal is %d, LessThan is %d, correct!", $time,a,b,Equal,LessThan);
            else if (Equal == (a==b)) $display("[%t][Information] Operation is Compare Unsigned. a is %d, b is %d, Equal is %d, LessThan is %d, correct!", $time,a,b,Equal,LessThan);
            else $display("[%t][Information] Operation is Compare Unsigned. a is %d, b is %d, Equal is %d, LessThan is %d, NOT correct!", $time,a,b,Equal,LessThan);
        end

        default: $display ("[%t][Warning] Operator is invalid!", $time);
    endcase
end

endmodule