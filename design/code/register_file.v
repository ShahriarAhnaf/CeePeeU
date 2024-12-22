module register_file 
(
input clock,  
input [4:0] addr_rs1, 
input [4:0] addr_rs2,
input [4:0] addr_rd,
input [31:0] data_rd,
output reg [31:0] data_rs1,
output reg [31:0] data_rs2,
input write_enable
);

// 32 registers of 32 bits
 (* ram_style = "block" *) reg [31:0] registers[31:0];
integer x;
initial begin 
    // for(x=0; x < 32; x = x + 1) begin 
    //     registers[x] = 32'b0; // zero everything
    // end 
    registers[0] = 32'b0;registers[1] = 32'b0;registers[3] = 32'b0;registers[4] = 32'b0;
    registers[5] = 32'b0;registers[6] = 32'b0;registers[7] = 32'b0;registers[8] = 32'b0;
    registers[9] = 32'b0;registers[10] = 32'b0;registers[11] = 32'b0;registers[12] = 32'b0;
    registers[13] = 32'b0;registers[14] = 32'b0;registers[15] = 32'b0;registers[16] = 32'b0;
    registers[17] = 32'b0;registers[18] = 32'b0;registers[19] = 32'b0;registers[20] = 32'b0;
    registers[21] = 32'b0;registers[22] = 32'b0;registers[23] = 32'b0;registers[24] = 32'b0;
    registers[25] = 32'b0;registers[26] = 32'b0;registers[27] = 32'b0;registers[28] = 32'b0;
    registers[29] = 32'b0;registers[30] = 32'b0;registers[31] = 32'b0;

    registers[2] = 32'h01000000 + `MEM_DEPTH; // stack pointer
end 


// show data always 
always @(posedge clock) begin
    if (write_enable && addr_rd != 0) begin // if write
        registers[addr_rd]     <= data_rd; 
    end 
    data_rs1 <= registers[addr_rs1];
    data_rs2 <= registers[addr_rs2];
end

endmodule