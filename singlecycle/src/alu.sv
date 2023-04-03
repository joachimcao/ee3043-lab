/*******************************************************************************
Creator:        Hai Cao Xuan (caoxuanhaipr@gmail.com)

Additional Contributions by:

File Name:      alu.sv
Design Name:    ALU
Project Name:   LUNAcore
Description:    Arithmetic Logic Unit

Changelog:      06.07.2022 - First draft, v0.1

*******************************************************************************/

/*******************************************************************************

Copyright (c) 2022 Hai Cao Xuan

*******************************************************************************/

`default_nettype none

module alu
import mypkg::*;
(
  input  logic [31:0] operand_a_i,
  input  logic [31:0] operand_b_i,
  input  alu_op_e     alu_op_i   ,

  output logic [31:0] alu_data_o ,
  output logic        bru_exp_o
);

//////////////////////////////////////////
// Arithmetic Unit - Adder & Subtractor //
//////////////////////////////////////////

  logic        adder_negate;
  logic [32:0] adder_operand_a;
  logic [32:0] adder_operand_b;
  logic [32:0] adder_result_ext;
  logic [31:0] adder_result;

  always_comb begin : proc_negate_b
    adder_negate = 1'b0;
    if (alu_op_i == A_SUB) begin
      adder_negate = 1'b1;
    end
  end

  assign adder_operand_a = {operand_a_i, 1'b1};
  assign adder_operand_b = {operand_b_i, 1'b0} ^ {33{adder_negate}};

  assign adder_result_ext = $unsigned(adder_operand_a) + $unsigned(adder_operand_b);
  assign adder_result = adder_result_ext[32:1];

////////////////
// Comparator //
////////////////

  logic compr_less;
  logic compr_sign_a;
  logic compr_sign_b;

  always_comb begin : proc_compare
    compr_sign_a = 1'b0;
    compr_sign_b = 1'b0;
    if (alu_op_i == A_SLT) begin
      compr_sign_a = operand_a_i[31];
      compr_sign_b = operand_b_i[31];
    end

    compr_less = ($signed({compr_sign_a, operand_a_i})
                < $signed({compr_sign_b, operand_b_i}));
  end

/////////////
// Shifter //
/////////////

  logic        shftr_left;
  logic        shftr_arth;
  logic [4:0]  shftr_amt;
  logic [31:0] shftr_reversed;
  logic [31:0] shftr_operand;
  logic [32:0] shftr_operand_ext;
  logic [32:0] shftr_right_result;
  logic [31:0] shftr_left_result;
  logic [31:0] shftr_result;

// Think about Function automatic here
  genvar i;
  generate
    for (i = 0; i < 32; i++) begin : proc_reverse_operand
      assign shftr_reversed[i] = operand_a_i[31-i];
    end
  endgenerate

  assign shftr_left = (alu_op_i == A_SLL);
  assign shftr_arth = (alu_op_i == A_SRA);

  assign shftr_amt = operand_b_i[4:0];

  assign shftr_operand = shftr_left ? shftr_reversed : operand_a_i;
  assign shftr_operand_ext = {shftr_arth & shftr_operand[31], shftr_operand};

  assign shftr_right_result = $unsigned($signed(shftr_operand_ext) >>> shftr_amt);

  genvar j;
  generate
    for (j = 0; j < 32; j++) begin : proc_reverse_result
      assign shftr_left_result[j] = shftr_right_result[31-j];
    end
  endgenerate

  assign shftr_result = shftr_left ? shftr_left_result : shftr_right_result[31:0];

///////////////////
// Select Result //
///////////////////

  /* verilator lint_off UNUSED */
  logic unused;
  assign unused = adder_result_ext[0] | shftr_right_result[32];
  /* verilator lint_on UNUSED */


  logic [31:0] alu_result;

  always_comb begin : proc_choose_result
    alu_result = 32'h0;
    case (alu_op_i)
      // Addition/Subtraction
      A_ADD,
      A_SUB : alu_result = adder_result;

      // Logic operations
      A_XOR : alu_result = operand_a_i ^ operand_b_i;
      A_OR  : alu_result = operand_a_i | operand_b_i;
      A_AND : alu_result = operand_a_i & operand_b_i;

      // Shift operations
      A_SLL,
      A_SRL, A_SRA : alu_result = shftr_result;

      // Comparisons
      A_SLT,
      A_SLTU : alu_result = {31'b0, compr_less};

      default   : alu_result = 32'h0;
    endcase

    alu_data_o  = alu_result;
    bru_exp_o   = |alu_result;
  end

endmodule : alu
