module ALU
(
  input [3:0] ALU_op, // 16 options???
  input [31:0] A,
  input [31:0] B,
  output reg [31:0] ALU_Result
);

 // Define ALU operation codes
    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam AND  = 4'b0010;
    localparam OR   = 4'b0011;
    localparam XOR  = 4'b0100;
    localparam SLL  = 4'b0101;
    localparam SRL  = 4'b0110;
    localparam SRA  = 4'b0111;
    localparam SLT  = 4'b1000;
    localparam SLTU = 4'b1001;
    localparam LUI  = 4'b1010;
    localparam AUIPC= 4'b1011;

    always @(*) begin
            case (ALU_op)
                ADD:    ALU_Result = A + B;
                SUB:    ALU_Result = A - B;
                AND:    ALU_Result = A & B;
                OR:     ALU_Result = A | B;
                XOR:    ALU_Result = A ^ B;
                SLL:    ALU_Result = A << (B[4:0]);
                SRL:    ALU_Result = A >> (B[4:0]);
                SRA:    ALU_Result = $signed(A) >>> (B[4:0]); // arith shift
                SLT:    ALU_Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
                SLTU:   ALU_Result = (A < B) ? 32'd1 : 32'd0;
                LUI:    ALU_Result = {B[31:12], 12'd0};
                AUIPC:  ALU_Result = A + {B[31:12], 12'd0};
                default: ALU_Result = 32'd0;
            endcase
    end

endmodule