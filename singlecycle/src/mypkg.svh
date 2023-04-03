/*******************************************************************************
Creator:        Hai Cao Xuan (caoxuanhaipr@gmail.com)

Additional Contributions by:

File Name:      luna_pkg.svh
Design Name:    LUNA Package
Project Name:   LUNAcore
Description:    Package of configuration and defines for LUNAcore

Changelog:      06.07.2022 - First draft, v0.1

********************************************************************************
Copyright (c) 2022 Hai Cao Xuan
*******************************************************************************/

package mypkg;

  `ifndef VERILATOR
  parameter FREQ = 5000000;
  `endif

  typedef enum logic [3:0] {
    A_ADD, A_SUB ,
    A_XOR, A_OR  , A_AND,
    A_SLL, A_SRL , A_SRA,
    A_SLT, A_SLTU
  } alu_op_e;

  typedef enum logic [2:0] {
    B_BEQ, B_BNE,
    B_BLT, B_BGE,
    B_JAL, B_JALR
  } bru_op_e;

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

endpackage : mypkg
