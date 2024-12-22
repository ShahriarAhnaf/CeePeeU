module pd(
  input clock,
  input reset
);

	(* dont_touch="true" *) reg read_write;
  (* dont_touch="true" *) reg fetch_enable;
  (* dont_touch="true" *) reg[31:0] i_mem_data_in;
  
  // decode signals directly
  (* dont_touch="true" *) wire [6:0] opcode; // 7 bit opcode always
  (* dont_touch="true" *) reg  [6:0] ex_opcode; // used for ALU choices in EX
  (* dont_touch="true" *) wire [4:0] source_1; // 5 bit register locations
  (* dont_touch="true" *) wire [4:0] source_2; // 5 bit register locations
  (* dont_touch="true" *) wire [4:0] destination; // 5 bit register locations
  (* dont_touch="true" *) wire [6:0] funct7; 
  (* dont_touch="true" *) wire [2:0] funct3;
  (* dont_touch="true" *) wire [4:0] shamt; // shift amount
  // have to calculate these
  (* dont_touch="true" *) reg[31:0] extended_imm; // always 32 bits sign extended

  //alu signals 
  (* dont_touch="true" *) reg[31:0] alu_a;
  (* dont_touch="true" *) reg[31:0] alu_b;
 (* dont_touch="true" *) wire [31:0] alu_result;
  (* dont_touch="true" *) reg[3:0] ALU_Control;
  // wires 
  (* dont_touch="true" *) wire [31:0] mem_address;
  (* dont_touch="true" *) wire [31:0] instruction;

  // WriteBacks stage, register control signals 
 (* dont_touch="true" *) reg[4:0] addr_rd;
 (* dont_touch="true" *) reg[31:0] data_rd;
 (* dont_touch="true" *) reg[31:0] data_wb; // for load data
(* dont_touch="true" *) reg wb_dmem_load; // WB stage for load.
(* dont_touch="true" *) reg[31:0] wb_load_data;
(* dont_touch="true" *) reg[2:0] wb_funct3;

 // register read... decode stage?
 (* dont_touch="true" *) wire  [4:0] addr_rs1;
 (* dont_touch="true" *) wire [4:0] addr_rs2;
 (* dont_touch="true" *) wire [31:0] data_rs1;
 (* dont_touch="true" *) wire [31:0] data_rs2;
 (* dont_touch="true" *) reg reg_rw;


// execute stage

(* dont_touch="true" *) reg ex_reg_rw; // execute signal
(* dont_touch="true" *) reg[31:0] ex_imm;
(* dont_touch="true" *) reg[6:0] ex_funct7;
(* dont_touch="true" *) reg[2:0] ex_funct3;
(* dont_touch="true" *) reg[31:0] eff_addr;
// (* dont_touch="true" *) reg[31:0] ex_reg1;
// (* dont_touch="true" *) reg[31:0] ex_reg2;
(* dont_touch="true" *) reg[4:0] ex_rd;
(* dont_touch="true" *) reg[31:0] ex_reg_data;
(* dont_touch="true" *) reg ex_dmem_rw;
(* dont_touch="true" *) reg ex_dmem_load;
(* dont_touch="true" *) reg[31:0] ex_rs1;
(* dont_touch="true" *) reg[31:0] ex_rs2;
(* dont_touch="true" *) reg[4:0] ex_source1;
(* dont_touch="true" *) reg[4:0] ex_source2;
(* dont_touch="true" *) reg[2:0] ex_instr_type; // subcategory


// memory stage control signals
(* dont_touch="true" *) reg dmem_rw;
reg [1:0] Mem_type;
reg [31:0] dmem_addr;
(* dont_touch="true" *) wire[31:0] dmem_out;
reg [31:0] dmem_in;
// memory stage
(* dont_touch="true" *) reg[31:0] m_data;
(* dont_touch="true" *) reg[2:0] m_funct3;
(* dont_touch="true" *) reg[4:0] m_rd;
(* dont_touch="true" *) reg[31:0] m_reg_data;
(* dont_touch="true" *) reg[31:0] m_reg2; // needs to know reg2 addrs
(* dont_touch="true" *) reg[4:0] m_addr_rs2;
(* dont_touch="true" *) reg m_reg_rw;
(* dont_touch="true" *) reg dmem_load;


dmemory main_mem (
  .clock(clock), 
  .read_write(dmem_rw),
  .access_size(Mem_type),
  .address(dmem_addr),
  .data_out(dmem_out),
  .data_in(dmem_in)
);

//instantiate controlled logic
imemory imem
(
	.clock(clock), 
	.read_write(read_write),
  .address(mem_address), 
  .data_in(i_mem_data_in), 
  .data_out(instruction), 
  .enable(fetch_enable)
);

register_file register_block
(
 clock, 
 addr_rs1, 
 addr_rs2,
 addr_rd,
 data_rd,
 data_rs1,
 data_rs2,
 reg_rw
);

ALU alu (
   ALU_Control, // 16 options???
   alu_a,
   alu_b,
   alu_result
);

// Define ALU operation codes (same as in ALU module)
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

(*dont_touch="true"*)(* dont_touch="true" *) reg[31:0] pc;
(*dont_touch="true"*)(* dont_touch="true" *) reg[31:0] d_pc;
(*dont_touch="true"*)(* dont_touch="true" *) reg[31:0] e_pc;
(*dont_touch="true"*)(* dont_touch="true" *) reg[31:0] m_pc;
(*dont_touch="true"*)(* dont_touch="true" *) reg[31:0] w_pc;

initial begin 
  pc = 32'h01000000;
end


assign mem_address = pc;

  // Instruction type encoding
  // grey encoding?
localparam R_TYPE   = 3'b000;
localparam I_TYPE   = 3'b001;
localparam S_TYPE   = 3'b010;
localparam B_TYPE   = 3'b011;
localparam J_TYPE   = 3'b100;  
localparam U_TYPE   = 3'b101; 
localparam SHIFT_TYPE = 3'b111; 
localparam LOAD_OPCODE = 7'b0000011;
localparam STORE_OPCODE= 7'b0100011;
 
(* dont_touch="true" *) reg[2:0] instr_type; // subcategory
(* dont_touch="true" *) reg R_branch_taken; // for double squashing branches
// assign constants
assign opcode = R_branch_taken ? 7'h13 : instruction[6:0]; // its always the first few
assign source_1 = R_branch_taken ? 5'h0 : instruction[19:15]; // for for R,I,S,B instructions
assign source_2 = R_branch_taken ? 5'h0 : instruction[24:20]; // for R,S,B instructions
assign destination = (R_branch_taken) ? 5'h0 :instruction[11:7]; // 5 bit register locations // could be muxed with  branch_taken ? 5'h0 :
assign funct7 = instruction[31:25]; 
assign funct3 = instruction[14:12];
assign shamt = instruction[24:20];


assign addr_rs1 = source_1;
assign addr_rs2 = source_2;
// assign addr_rd = destination; // needs to be pipelined through


// stall control signals

(* dont_touch="true" *) reg branch_taken;
(* dont_touch="true" *) reg stall;
(* dont_touch="true" *) reg data_in_WB_stall;
(* dont_touch="true" *) reg possible_to_bypass;
(* dont_touch="true" *) reg load_stall_necessary;
(* dont_touch="true" *) reg valid_r1;
(* dont_touch="true" *) reg valid_r2;

always@(posedge clock) begin
  if(reset)begin 
    pc <= 32'h01000000;// default pc start  
    read_write <= 0; // reading
    // fetch_enable <= 1;
    R_branch_taken <=1; // insert a nop into the next cycle to negate the instruction coming
    // nothing
    d_pc <= 0;
    e_pc <= 0;
    m_pc <= 0;
    w_pc <= 0;

    // decode stage propogation 
    // capture from register file in decode stage
    ex_opcode <= 0;
    ex_funct3 <= 0;
    ex_funct7 <= 0;
    // ex_reg1 <= 0; 
    // ex_reg2 <= 0; 
    ex_rd <= 0;
    ex_imm <= 0;
    ex_instr_type <= 0;
    ex_source1 <=0;
    ex_source2 <=0;

    //execute
    m_rd <= 0;
    dmem_rw <= 0;
    dmem_addr <= 0;   // only used when read_write is 1.
    m_reg_data <= 0; // always carry through
    m_funct3 <= 0;
    m_reg_rw <= 0;
    dmem_load <= 0;
    dmem_rw <= 0;

    //dmem
    reg_rw <= 0;
    data_wb <= 0;
    addr_rd <= 0;   
    wb_dmem_load <= 0;  
    wb_funct3 <= 0;
  end
  else begin 
    read_write <= 0; // reading
   R_branch_taken <= 0; // for double stalling
    // fetch_enable <= 1; // fetching
    if(branch_taken) begin 
      // when the fire nation attacks
        pc <= eff_addr;

        // VOID THE DECODE INSTRUCTIONS??? in the next cycle...
        R_branch_taken <= branch_taken;
        // add in no op in the in the decode instruction
        // fetch_enable <= 0; // to get a no op in fetch 
        ex_opcode <= 7'h13;
        ex_funct3 <= 0;
        ex_funct7 <= 0;
        // ex_reg1 <= 0; 
        // ex_reg2 <= 0; 
        ex_rd <= 0;
        ex_imm <= 0;
        ex_source1 <= 0;
        ex_source2 <= 0;
        ex_instr_type <= 0;
    end else if (stall) begin 
      // fetch_enable <= 0; // stop le fetching...


      // no new fethcing
      e_pc <= d_pc;
      m_pc <= e_pc;
      w_pc <= m_pc;
      // add in nop INTO THE EX STAGE
      ex_opcode <= 7'h13; // addi
      ex_funct3 <= 0;
      ex_funct7 <= 0;
      // ex_reg1 <= 0; 
      // ex_reg2 <= 0; 
      ex_rd <= 0;
      ex_imm <= 0;
      ex_source1 <= 0;
      ex_source2 <= 0;
      ex_instr_type <= 0;

      // still propogate all other pipelining regs through but no pc propogations
    end else begin 
        // all four nations in harmony
        pc <= pc + 32'd4; 
        d_pc <= pc;
        // d_instruction <= instruction; // decode only after fetch. // normal operation
         // decode stage propogation 
      // capture from register file in decode stage
      ex_opcode <= opcode;
      ex_funct3 <= funct3;
      ex_funct7 <= funct7;
      // ex_reg1 <= data_rs1; // these are read straight in the execute stage now.
      // ex_reg2 <= data_rs2; 
      ex_rd <= (instr_type == B_TYPE || instr_type == S_TYPE) ?  5'h0 : destination; // to avoid false forwarding on branch and store instructions
      ex_imm <= extended_imm;
      ex_source1 <= source_1;
      ex_source2 <= source_2;
      ex_instr_type <= instr_type;
    end
      // normal propogration
      e_pc <= d_pc;
      m_pc <= e_pc;
      w_pc <= m_pc;

      // fetch stage signal propogation
      
      // these should always be pipelining
      //execute
      m_rd <= ex_rd;
      dmem_rw <= ex_dmem_rw;
      dmem_addr <= alu_result;   // only used when read_write is 1.
      m_reg_data <= ex_reg_data; // always carry through
      m_funct3 <= ex_funct3;
      m_reg_rw <= ex_reg_rw;
      dmem_load <= ex_dmem_load;
      dmem_rw <= ex_dmem_rw;
      m_reg2 <= ex_rs2;
      m_addr_rs2 <= ex_source2;
      //dmem
      reg_rw <= m_reg_rw;
      data_wb <= m_data;
      addr_rd <= m_rd; //register addr
      wb_dmem_load <= dmem_load;
      wb_funct3 <= m_funct3;
      //writeback
      // 
    end
  end



always @(*)begin
    valid_r1 = (instr_type != U_TYPE) && (instr_type != J_TYPE);
    valid_r2 = (instr_type != I_TYPE) && (instr_type != U_TYPE) && (instr_type != J_TYPE);
    data_in_WB_stall =  reg_rw && addr_rd != 0 &&
                        ( 
                          ( addr_rd == addr_rs1 && valid_r1) || 
                          ( addr_rd == addr_rs2 && valid_r2 ) 
                        ); 

    possible_to_bypass = (m_rd == addr_rd || addr_rd == ex_rd);
 
    // // edge case, if you cant potentially bypass unless next opcode is a load you must wait till after ME stage.
    load_stall_necessary = (ex_opcode == LOAD_OPCODE && 
                            // check if the load destination is any of the read operands
                            (
                              (ex_rd == addr_rs1 && valid_r1 ) ||  // stores are special since they can forward r1 from wb->me
                              (ex_rd == addr_rs2 && valid_r2 && (opcode != STORE_OPCODE ))
                            )
                           );
      stall = load_stall_necessary || 
        ( 
          // (d_pc != w_pc) && // if pipeline is filled with bubbles
          // another edge case, you CAN bypass if you are a store and the next op is a load. 
          !(possible_to_bypass)  && // dont stall if register value can be bypassed later
          data_in_WB_stall
        );

      fetch_enable = ~(stall | branch_taken); // dependednt to make nops 
end



// immediate value calculatin
// decode stage
always @(*)begin 
  // assign constants 
  case (instr_type)
    R_TYPE: begin
      extended_imm = 32'b0;
    end
    I_TYPE: begin
      // 12 bytes 
      // replicates msb 20 times
      extended_imm = {{20{instruction[31]}},instruction[31:20]}; 
    end
    S_TYPE: begin
      extended_imm = {{20{instruction[31]}},instruction[31:25], instruction[11:7]}; 
    end
    B_TYPE: begin
      extended_imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; 
    end
    J_TYPE: begin
      //                                         20th               19-12                 11th          10:1
      extended_imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}; 
    end
    U_TYPE: begin
      extended_imm = {instruction[31:12], {12{1'b0}}}; 
    end
    default: begin
       extended_imm = 32'b0;
    end
  endcase
end

// instruction type finding
// decode stage
always @(*) begin
        case (opcode)
            // R type + ECALL instr
            7'b0110011, 7'b1110011: instr_type = R_TYPE; // R-type (register-register ALU instructions)
            7'b0110111,7'b0010111: instr_type = U_TYPE;
            7'b1100011: instr_type = B_TYPE;
            7'b0000011,7'b1100111: instr_type = I_TYPE;
            7'b0010011: begin 
              // always immediate
               instr_type = I_TYPE;    
            end 
            7'b0100011: instr_type = S_TYPE; // store
            7'b1101111: instr_type = J_TYPE; // only J type JAL instruction
            default:    instr_type = 3'bxxx;  // Undefined instruction
        endcase
end




always@(*) begin
      
    // figure out what to store.. 
    dmem_in = 0; // default
    case(m_funct3)
          3'b000: begin 
            Mem_type = 0; // byte
            dmem_in = { {24{data_rs2[7]}}, data_rs2[7:0]};
          end
          3'b001: begin 
            Mem_type = 1; // half w
            dmem_in = { {16{data_rs2[7]}}, data_rs2[15:0]};
          end
          3'b010: begin 
            Mem_type = 2;  // word 
            dmem_in = {data_rs2};
          end
          // LOAD MEM TYPES, COMPRESSING LOGIC
          3'b100: begin 
            Mem_type = 0; // byte unsigned
          end 
          3'b101:begin 
            Mem_type = 1; // half unsigned
          end 
          default begin 
            Mem_type = 0;
          end
    endcase
     // store...
    if(dmem_rw) begin
        // forward case
        if(addr_rd == m_addr_rs2 && addr_rd != 0) begin
          dmem_in = data_rd; // the data from writeback register
        end else begin 
          dmem_in = m_reg2; 
        end
    end
    // passing through for non load and stores
    m_data = m_reg_data;
end

always@(*) begin 
  wb_load_data = 0;
  data_rd = data_wb; // default
  if(wb_dmem_load) begin 
      // load
      // THIS IS IN THE WB STAGE.
      // dmem output needs to go to register file
      case (wb_funct3)
            3'b000: begin 
              // sign extended
              wb_load_data = {{24{dmem_out[7]}}, dmem_out[7:0]}; // 
            end 
            3'b001: begin 
              // sign extended
              wb_load_data = {{16{dmem_out[15]}}, dmem_out[15:0]};
            end 
            3'b010: begin 
              // just original
              wb_load_data = {dmem_out};
            end 
            3'b100: begin 
              //byte unsigned
              wb_load_data = {{24{1'b0}}, dmem_out[7:0]}; // 
            end 
            3'b101:begin 
              // half word unsigned
              wb_load_data = {{16{1'b0}}, dmem_out[15:0]}; // 
            end 
            default begin 
              wb_load_data = 0;
            end
      endcase  
    data_rd = wb_load_data;
  end 
end


// branch taken algorithm
// all control logic for execute
always @(*) begin
        // if(reset)begin
        //   eff_addr = e_pc;
        //   ALU_Control = 4'b1111; // Default to UNDEFINED
        //   ex_reg_rw = 0; // default is 0
        //   alu_a = 0; // data_rs1 
        //   alu_b = ex_imm; 
        //   branch_taken  = 0;
        //   ex_dmem_rw = 0; // default no mem
        //   ex_dmem_load = 0;
        //   ex_reg_data = 0;
        //   ex_rs1 =0;
        //   ex_rs2 =0;
        // end 
        // else begin 
        // Default ALU_Control
          eff_addr = e_pc;
          ALU_Control = 4'b1111; // Default to UNDEFINED
          ex_reg_rw = 0; // default is 0
          alu_a = 0; // data_rs1 
          alu_b = ex_imm; 
          branch_taken  = 0;
          ex_dmem_rw = 0; // default no mem
          ex_dmem_load = 0;
          ex_reg_data = 0;
          ex_rs1 =data_rs1;
          ex_rs2 =data_rs2;
          
          // forwarding paths 
          // rs1
          // nop proofed by != 0 (* dont_touch="true" *) regaddr
           if (!( (ex_instr_type == U_TYPE) || (ex_instr_type == J_TYPE) ) ) begin
              if(m_rd == ex_source1 && (m_rd != 0) ) begin// me->ex 
                ex_rs1 = m_data;
              end else if(addr_rd == ex_source1 && (addr_rd != 0))  begin// wb -> ex 
                ex_rs1 = data_rd;
              end
           end
          //rs2
          if (!( (ex_instr_type == I_TYPE) || (ex_instr_type == U_TYPE) || (ex_instr_type == J_TYPE) )  ) begin // only forward if its useful
            if( (m_rd == ex_source2) && (m_rd != 0) )  begin// me->ex 
              ex_rs2 = m_data;
            end else if( (addr_rd == ex_source2) && (addr_rd != 0))  begin// wb -> ex 
              ex_rs2 = data_rd;
            end
          end

          case (ex_opcode)
              7'b0110011: begin // R-Type
                  ex_reg_rw = 1; // all these needs (* dont_touch="true" *) regwrites 
                  alu_a = ex_rs1;  
                  alu_b = ex_rs2; 
                  // extra ALU controls
                  case (ex_funct3)
                      3'b000: begin
                          if (ex_funct7 == 7'b0000000)
                              ALU_Control = ADD; // ADD
                          else if (ex_funct7 == 7'b0100000)
                              ALU_Control = SUB; // SUB
                          else
                              ALU_Control = 4'b1111; // Undefined
                      end
                      3'b111: ALU_Control = AND; // AND
                      3'b110: ALU_Control = OR;  // OR
                      3'b100: ALU_Control = XOR; // XOR
                      3'b001: ALU_Control = SLL; // SLL
                      3'b101: begin
                          if (ex_funct7 == 7'b0000000)
                              ALU_Control = SRL; // SRL
                          else if (ex_funct7 == 7'b0100000)
                              ALU_Control = SRA; // SRA
                          else
                              ALU_Control = 4'b1111; // Undefined
                      end
                      3'b010: ALU_Control = SLT; // SLT
                      3'b011: ALU_Control = SLTU; // SLTU
                      default: ALU_Control = 4'b1111; // Undefined
                  endcase

                  ex_reg_data = alu_result; // register write  ORDER MATTERS
              end

              7'b0010011: begin // I-Type (Immediate)
                ex_reg_rw = 1; // all these needs (* dont_touch="true" *) regwrites 
                
                  // extra ALU control differentiating
                  case (ex_funct3)
                      3'b000: ALU_Control = ADD; // ADDI
                      3'b111: ALU_Control = AND; // ANDI
                      3'b110: ALU_Control = OR;  // ORI
                      3'b100: ALU_Control = XOR; // XORI
                      3'b001: ALU_Control = SLL; // SLLI
                      3'b101: begin // shift right ones are based on funct 7 
                          if (ex_funct7 == 7'b0000000)
                              ALU_Control = SRL; // SRLI
                          else if (ex_funct7 == 7'b0100000)
                              ALU_Control = SRA; // SRAI
                          else
                              ALU_Control = 4'b1111; // Undefined
                      end
                      3'b010: ALU_Control = SLT; // SLTI
                      3'b011: ALU_Control = SLTU; // SLTIU
                      default: ALU_Control = 4'b1111; // Undefined
                  endcase
                // ORDER MATTERS 
                // must wait for ALU control to resolve before using value
                alu_a = ex_rs1; // data_rs1 
                alu_b = ex_imm;
                ex_reg_data = alu_result; // ALU result into register file 
              end
              7'b0110111: begin 
                ex_reg_rw = 1; // write to rd
                ALU_Control = LUI;    // LUI // only uses B
                alu_b = ex_imm; // default but explicit anyway
                ex_reg_data = alu_result;
              end 
              7'b0010111: begin 
                ex_reg_rw = 1; // write to rd
                ALU_Control = AUIPC;  // AUIPC
                alu_a = e_pc;
                alu_b = ex_imm; // default but put anyway
                ex_reg_data = alu_result;
              end 
              7'b0100011: // store operations 
              begin
                ex_dmem_rw = 1; // writes to mem
                ALU_Control= ADD;
                alu_a = ex_rs1;
                alu_b = ex_imm; // default but being explicit
              end
              7'b0000011: // load ops 
              begin 
                ex_reg_rw = 1; // writes to reg
                ex_dmem_load = 1;
                ALU_Control= ADD;
                alu_a = ex_rs1;
                alu_b = ex_imm; // default but being explicit
              end
              7'b1100011: // branch control signals
              begin 
                ALU_Control = ADD;
                alu_a = e_pc;
                alu_b = ex_imm; 
                eff_addr = alu_result; // pc += imm
                // branhch opcodes 
                case(ex_funct3)
                      3'b000: begin // BEQ: Branch if equal
                          branch_taken = (ex_rs1 == ex_rs2) ? 1'b1 : 1'b0;
                      end
                      3'b001: begin // BNE: Branch if not equal
                          branch_taken = (ex_rs1 != ex_rs2) ? 1'b1 : 1'b0;
                      end
                      3'b100: begin // BLT: Branch if less than (signed)
                          branch_taken = ($signed(ex_rs1) < $signed(ex_rs2)) ? 1'b1 : 1'b0;
                      end
                      3'b101: begin // BGE: Branch if greater or equal (signed)
                          branch_taken = ($signed(ex_rs1) >= $signed(ex_rs2)) ? 1'b1 : 1'b0;
                      end
                      3'b110: begin // BLTU: Branch if less than (unsigned)
                          branch_taken = (ex_rs1 < ex_rs2) ? 1'b1 : 1'b0;
                      end
                      3'b111: begin // BGEU: Branch if greater or equal (unsigned)
                          branch_taken = (ex_rs1 >= ex_rs2) ? 1'b1 : 1'b0;
                      end
                      default: begin
                          // Undefined funct3 for branch
                          branch_taken = 1'b0;
                      end
                  endcase
              end
              7'b1101111: // JAL
              begin 
               branch_taken = 1;
               ALU_Control = ADD;
                ex_reg_rw = 1; // rd 
                ex_reg_data = e_pc+4;
                alu_a = e_pc;
                alu_b = ex_imm;
                eff_addr = alu_result; // pc += imm
              end
              7'b1100111: // JALR
              begin 
                branch_taken = 1;
                ex_reg_rw = 1; // rd 
                ex_reg_data = e_pc+4;
                ALU_Control = ADD;
                alu_a = ex_rs1;
                alu_b = ex_imm;
                eff_addr = alu_result; // pc = rs1 + imm
              end
              // Add other opcode cases if needed
              default begin
              // unknown opcode
              end
          endcase
        // end
 end

endmodule