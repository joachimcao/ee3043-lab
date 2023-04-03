/*******************************************************************************
Creator:        Hai Cao Xuan (caoxuanhaipr@gmail.com)

Additional Contributions by:

File Name:      inst_decode.sv
Design Name:    Instruction Decode
Project Name:   LUNAcore
Description:    Decode instructions from fetch

Changelog:      08.18.22 - First draft, v0.1

********************************************************************************
Copyright (c) 2022 Hai Cao Xuan
*******************************************************************************/

`default_nettype none

module decoder
import mypkg::*;
(
  // input
  input  logic [31:0] instr_i     ,

  // output
  output logic [4:0]  rs1_addr_o  ,
  output logic [4:0]  rs2_addr_o  ,
  output logic [4:0]  rd_addr_o   ,
  output logic [31:0] imm_o       ,
  output alu_op_e     alu_op_o    ,
  output logic        rd_wren_o   ,
  output logic [1:0]  op_b_sel_o  ,
  output logic        is_pc_o     ,
  output logic        is_control_o,
  output bru_op_e     bru_op_o    ,
  output logic        is_load_o   ,
  output logic [4:0]  lsu_strb_o  ,
  output logic        mem_wr_o    ,
  output logic        illegal_o
);

  // Register Addresses and Decoded signal
  always_comb begin : proc_reg_addr
    illegal_o    = 1'b0;
    rs1_addr_o   = 5'h0;
    rs2_addr_o   = 5'h0;
    rd_addr_o    = 5'h0;
    rd_wren_o    = 1'b0;
    op_b_sel_o   = 2'b00;
    is_pc_o      = 1'b0;
    is_control_o = 1'b0;
    is_load_o    = 1'b0;
    mem_wr_o     = 1'b0;
    case (instr_i[6:0])
      // Register - Register
      7'b011_00_11: begin
        // OP_OP: begin
        rs1_addr_o   = instr_i[19:15];
        rs2_addr_o   = instr_i[24:20];
        rd_addr_o    = instr_i[11:7];
        rd_wren_o    = 1'b1;
        op_b_sel_o   = 2'b00;
      end
      // Immediate - Register
      7'b001_00_11: begin
        // OP_OPIMM : begin
        rs1_addr_o   = instr_i[19:15];
        rd_addr_o    = instr_i[11:7];
        rd_wren_o    = 1'b1;
        op_b_sel_o   = 2'b01;
      end
      // Load
      7'b000_00_11: begin
        // OP_LOAD : begin
        rs1_addr_o   = instr_i[19:15];
        rd_addr_o    = instr_i[11:7];
        rd_wren_o    = 1'b1;
        op_b_sel_o   = 2'b01;
        is_load_o    = 1'b1;
      end
      // Store
      7'b010_00_11: begin
        // OP_STORE : begin
        rs1_addr_o   = instr_i[19:15];
        rs2_addr_o   = instr_i[24:20];
        op_b_sel_o   = 2'b01;
        mem_wr_o     = 1'b1;
      end
      // Conditional Branch
      7'b110_00_11: begin
        // OP_BRANCH : begin
        rs1_addr_o   = instr_i[19:15];
        rs2_addr_o   = instr_i[24:20];
        op_b_sel_o   = 2'b00;
        is_control_o = 1'b1;
      end
      // Jump and Link
      7'b110_11_11: begin
        // OP_JAL : begin
        rd_addr_o    = instr_i[11:7];
        rd_wren_o    = 1'b1;
        op_b_sel_o   = 2'b10;
        is_pc_o      = 1'b1;
        is_control_o = 1'b1;
      end
      // Jump and Link Register
      7'b110_01_11: begin
        // OP_JALR : begin
        rs1_addr_o   = instr_i[19:15];
        rd_addr_o    = instr_i[11:7];
        rd_wren_o    = 1'b1;
        op_b_sel_o   = 2'b10;
        is_pc_o      = 1'b1;
        is_control_o = 1'b1;
      end
      // Load Upper Immediate
      7'b011_01_11: begin
        // OP_LUI : begin
        rd_addr_o    = instr_i[11:7];
        rd_wren_o    = 1'b1;
        op_b_sel_o   = 2'b01;
      end
      // Add Upper Immediate PC
      7'b001_01_11: begin
        // OP_AUIPC : begin
        rd_addr_o    = instr_i[11:7];
        rd_wren_o    = 1'b1;
        op_b_sel_o   = 2'b01;
        is_pc_o      = 1'b1;
      end
      default: begin
        illegal_o = 1'b1;
      end
    endcase
  end

  // ALU and BRU Operator
  always_comb begin : proc_alu_bru
    alu_op_o   = A_ADD;
    bru_op_o   = B_BEQ;
    lsu_strb_o = 5'b00000;

    if ((instr_i[6:0] == OP_OP) || (instr_i[6:0] == OP_OPIMM)) begin
      case (instr_i[14:12])
        3'b000: begin
          alu_op_o = (instr_i[30] && (instr_i[6:0] == OP_OP)) ? A_SUB : A_ADD;
        end
        3'b001: begin
          alu_op_o = A_SLL;
        end
        3'b010: begin
          alu_op_o = A_SLT;
        end
        3'b011: begin
          alu_op_o = A_SLTU;
        end
        3'b100: begin
          alu_op_o = A_XOR;
        end
        3'b101: begin
          alu_op_o = instr_i[30] ? A_SRA : A_SRL;
        end
        3'b110: begin
          alu_op_o = A_OR;
        end
        3'b111: begin
          alu_op_o = A_AND;
        end
      endcase
    end

    if (instr_i[6:0] == OP_BRANCH) begin
      case (instr_i[14:12])
        3'b000: begin // BEQ
          bru_op_o = B_BEQ;
          alu_op_o = A_SUB;
        end
        3'b001: begin // BNE
          bru_op_o = B_BNE;
          alu_op_o = A_SUB;
        end
        3'b100: begin
          bru_op_o = B_BLT;
          alu_op_o = A_SLT;
        end
        3'b101: begin // BLT, BGE
          bru_op_o = B_BGE;
          alu_op_o = A_SLT;
        end
        3'b110: begin // BLTU
          bru_op_o = B_BLT;
          alu_op_o = A_SLTU;
        end
        3'b111: begin // BGEU
          bru_op_o = B_BGE;
          alu_op_o = A_SLTU;
        end
        default: begin
          bru_op_o = B_BEQ;
          alu_op_o = A_ADD;
        end
      endcase
    end
    if (instr_i[6:0] == OP_JAL) begin
      bru_op_o = B_JAL;
    end
    if (instr_i[6:0] == OP_JALR) begin
      bru_op_o = B_JALR;
    end

    if ((instr_i[6:0] == OP_LOAD) || (instr_i[6:0] == OP_STORE)) begin
      case (instr_i[14:12])
        3'b000: begin // LB and SB
          lsu_strb_o = 5'b10001;
        end
        3'b001: begin // LH and SH
          lsu_strb_o = 5'b10011;
        end
        3'b010: begin // LW and SW
          lsu_strb_o = 5'b11111;
        end
        3'b100: begin // LBU
          lsu_strb_o = 5'b00001;
        end
        3'b101: begin // LHU
          lsu_strb_o = 5'b00011;
        end
        default: begin
          lsu_strb_o = 5'b00000;
        end
      endcase
    end
  end

  // Immediate Generator
  always_comb begin : proc_imm_gen
    imm_o   = 32'h0;
    case (instr_i[6:0])
      // Immediate - Register
      7'b001_00_11: begin
        // OP_OPIMM : begin
        imm_o = {{21{instr_i[31]}}, instr_i[30:20]};
      end
      // Load
      7'b000_00_11: begin
        // OP_LOAD : begin
        imm_o = {{21{instr_i[31]}}, instr_i[30:20]};
      end
      // Store
      7'b010_00_11: begin
        // OP_STORE : begin
        imm_o = {{21{instr_i[31]}}, instr_i[30:25], instr_i[11:7]};
      end
      // Conditional Branch
      7'b110_00_11: begin
        // OP_BRANCH : begin
        imm_o = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
      end
      // Jump and Link
      7'b110_11_11: begin
        // OP_JAL : begin
        imm_o = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
      end
      // Jump and Link Register
      7'b110_01_11: begin
        // OP_JALR : begin
        imm_o = {{21{instr_i[31]}}, instr_i[30:20]};
      end
      // Load Upper Immediate
      7'b011_01_11: begin
        // OP_LUI : begin
        imm_o = {instr_i[31:12], 12'b0};
      end
      // Add Upper Immediate PC
      7'b001_01_11: begin
        // OP_AUIPC : begin
        imm_o = {instr_i[31:12], 12'b0};
      end
      default: begin
        imm_o   = 32'h0;
      end
    endcase
  end

endmodule : decoder
