
/* Your Code Below! Enable the following define's 
 * and replace ??? with actual wires */
// ----- signals -----
// You will also need to define PC properly
`define F_PC                pc
`define F_INSN              instruction

`define D_PC                d_pc
`define D_OPCODE            opcode
`define D_RD                destination
`define D_RS1               source_1
`define D_RS2               source_2
`define D_FUNCT3            funct3
`define D_FUNCT7            funct7
`define D_IMM               extended_imm
`define D_SHAMT             shamt

`define R_WRITE_ENABLE      reg_write_enable
`define R_WRITE_DESTINATION addr_rd
`define R_WRITE_DATA        data_rd
`define R_READ_RS1          addr_rs1
`define R_READ_RS2          addr_rs2
`define R_READ_RS1_DATA     data_rs1
`define R_READ_RS2_DATA     data_rs2

`define E_PC                e_pc
`define E_ALU_RES           alu_result
`define E_BR_TAKEN          branch_taken


`define M_PC                m_pc
`define M_ADDRESS           dmem_addr
`define M_RW                dmem_rw
`define M_SIZE_ENCODED      Mem_type
`define M_DATA              dmem_in // just dmem_in even though it makes no sense

`define W_PC                w_pc
`define W_ENABLE            reg_rw
`define W_DESTINATION       addr_rd
`define W_DATA              data_rd


`define IMEMORY             imem
`define DMEMORY             main_mem


// ----- signals -----

// ----- design -----
`define TOP_MODULE                 pd
// ----- design -----
