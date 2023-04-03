/*******************************************************************************
Creator:        Hai Cao Xuan (caoxuanhaipr@gmail.com)

Additional Contributions by:

File Name:      riscv_pkg.svh
Design Name:    RISCV Package
Project Name:   LUNAcore
Description:    Package of common defines for RISC-V specification

Changelog:      06.07.2022 - First draft, v0.1

*******************************************************************************/

/*******************************************************************************

Copyright (c) 2022 Hai Cao Xuan

*******************************************************************************/

package riscv_pkg;

////////////////
// Opcode Map //
////////////////

// instr[1:0] = 11 by default

  typedef enum logic[6:0] {
    OP_LOAD    = 7'b00_000_11,
    OP_LOADFP  = 7'b00_001_11,
    OP_CUSTOM0 = 7'b00_010_11,
    OP_MISCMEM = 7'b00_011_11,
    OP_OPIMM   = 7'b00_100_11,
    OP_AUIPC   = 7'b00_101_11,
    OP_OPIMM32 = 7'b00_110_11,

    OP_STORE   = 7'b01_000_11,
    OP_STOREFP = 7'b01_001_11,
    OP_CUSTOM1 = 7'b01_010_11,
    OP_AMO     = 7'b01_011_11,
    OP_OP      = 7'b01_100_11,
    OP_LUI     = 7'b01_101_11,
    OP_OP32    = 7'b01_110_11,

    OP_MADD    = 7'b10_000_11,
    OP_MSUB    = 7'b10_001_11,
    OP_NMSUB   = 7'b10_010_11,
    OP_NMADD   = 7'b10_011_11,
    OP_OPFP    = 7'b10_100_11,
    OP_RESRVD0 = 7'b10_101_11,
    OP_CUSTOM2 = 7'b10_110_11,

    OP_BRANCH  = 7'b11_000_11,
    OP_JALR    = 7'b11_001_11,
    OP_RESRVD1 = 7'b11_010_11,
    OP_JAL     = 7'b11_011_11,
    OP_SYSTEM  = 7'b11_100_11,
    OP_RESRVD2 = 7'b11_101_11,
    OP_CUSTOM3 = 7'b11_110_11
  } opcode_e;

///////////////////////
// Instruction Types //
///////////////////////

  typedef struct packed {
    logic [31:25] funct7;
    logic [24:20] rs2   ;
    logic [19:15] rs1   ;
    logic [14:12] funct3;
    logic [11:7]  rd    ;
    logic [6:0]   opcode;
  } rtype_s;

  typedef struct packed {
    logic [31:27] rs3_addr;
    logic [26:25] funct2;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] funct3;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } r4type_s;

  typedef struct packed {
    logic [31:20] imm   ;
    logic [19:15] rs1   ;
    logic [14:12] funct3;
    logic [11:7]  rd    ;
    logic [6:0]   opcode;
  } itype_s;

  typedef struct packed {
    logic [31:25] imm1  ;
    logic [24:20] rs2   ;
    logic [19:15] rs1   ;
    logic [14:12] funct3;
    logic [11:7]  imm0  ;
    logic [6:0]   opcode;
  } stype_s;

  typedef struct packed {
    logic [31:12] imm   ;
    logic [11:7]  rd    ;
    logic [6:0]   opcode;
  } utype_s;

/////////////////////////
// Immediate Generator //
/////////////////////////
/*verilator lint_off UNUSED*/
  function automatic logic [31:0] imm_itype (logic [31:0] instr);
    imm_itype = {{21{instr[31]}}, instr[30:20]};
  endfunction

  function automatic logic [31:0] imm_stype (logic [31:0] instr);
    imm_stype = {{21{instr[31]}}, instr[30:25], instr[11:7]};
  endfunction

  function automatic logic [31:0] imm_btype (logic [31:0] instr);
    imm_btype = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
  endfunction

  function automatic logic [31:0] imm_utype (logic [31:0] instr);
    imm_utype = {instr[31:12], 12'b0};
  endfunction

  function automatic logic [31:0] imm_jtype (logic [31:0] instr);
    imm_jtype = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
  endfunction
/*verilator lint_on UNUSED*/

endpackage : riscv_pkg
