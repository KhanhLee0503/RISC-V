module ShiftRight_Arithmetic(a, b, y);
    parameter N = 32;
    input [N-1:0] a;
    input [N-1:0] b; 
    output reg[N-1:0] y;

    wire sign_bit = a[N-1]; // Lấy bit dấu của a

    always_comb begin
        reg [N-1:0] temp_shift;
        temp_shift = a;
        
        // Stage 1
        if (b[0]) begin
            temp_shift = {sign_bit, temp_shift[N-1:1]};
        end
        
        // Stage 2
        if (b[1]) begin
            temp_shift = {{2{sign_bit}}, temp_shift[N-1:2]};
        end
        
        // Stage 3
        if (b[2]) begin
            temp_shift = {{4{sign_bit}}, temp_shift[N-1:4]};
        end
        
        // Stage 4
        if (b[3]) begin
            temp_shift = {{8{sign_bit}}, temp_shift[N-1:8]};
        end
        
        // Stage 5
        if (b[4]) begin
            temp_shift = {{16{sign_bit}}, temp_shift[N-1:16]};
        end
        
        y = temp_shift;
    end
endmodule