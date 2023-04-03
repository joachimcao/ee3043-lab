/*******************************************************************************
Creator:        Hai Cao Xuan (caoxuanhaipr@gmail.com)

Additional Contributions by:

File Name:      bru.sv
Design Name:    bru
Project Name:   LUNAcore
Description:    Branch Unit

Changelog:      06.07.2022 - First draft, v0.1

*******************************************************************************/

/*******************************************************************************

Copyright (c) 2022 Hai Cao Xuan

*******************************************************************************/

`default_nettype none

module bru
import mypkg::*;
(
  input  logic [31:0] pc_i        ,
  input  logic [31:0] rs1_data_i  ,
  input  logic [31:0] imm_i       ,
  input  logic        is_control_i,
  input  bru_op_e     bru_op_i    ,
  input  logic        bru_exp_i   ,

  output logic [31:0] pc_bru_o    ,
  output logic        is_taken_o
);

  logic [31:0] base;
  logic [31:0] offset;

  assign offset     = imm_i;

  always_comb begin : proc_cal_pc
    is_taken_o = 1'b0;
    base       = pc_i;
    if (is_control_i) begin
      case (bru_op_i)
        B_BEQ, B_BGE: begin
          is_taken_o = !bru_exp_i;
        end
        B_BNE, B_BLT: begin
          is_taken_o =  bru_exp_i;
        end
        B_JAL: begin
          is_taken_o = 1'b1;
        end
        B_JALR: begin
          is_taken_o = 1'b1;
          base       = rs1_data_i;
        end
        default: begin
          is_taken_o = 1'b0;
          base       = pc_i;
        end
      endcase
    end
  end

  assign pc_bru_o = base + offset;

endmodule : bru
