/*******************************************************************************
Creator:        Hai Cao Xuan (caoxuanhaipr@gmail.com)

Additional Contributions by:

File Name:      regfile.sv
Design Name:    Physical Register File
Project Name:   LUNAcore
Description:    Register file with 40 32-bit registers,
                which follows Unified or Merged Register File scheme
                Register 0 always equals 0 and cannot be written.

Changelog:      08.18.22 - First draft, v0.1

********************************************************************************
Copyright (c) 2022 Hai Cao Xuan
*******************************************************************************/

`default_nettype none

module singlecycle
import mypkg::*;
(
  input  logic [31:0]       io_sw_i   ,
  output logic [31:0]       io_lcd_o  ,
  output logic [31:0]       io_ledg_o ,
  output logic [31:0]       io_ledr_o ,
  output logic [31:0]       io_hex0_o ,
  output logic [31:0]       io_hex1_o ,
  output logic [31:0]       io_hex2_o ,
  output logic [31:0]       io_hex3_o ,
  output logic [31:0]       io_hex4_o ,
  output logic [31:0]       io_hex5_o ,
  output logic [31:0]       io_hex6_o ,
  output logic [31:0]       io_hex7_o ,

  output logic [31:0]       pc_debug_o,

  //output logic              illegal_o,

  // Clock and asynchronous reset active low
  input  logic              clk_i     ,
  input  logic              rst_ni
);

  logic [31:0] pc_q      ;
  logic [31:0] pc_d      ;

  logic [31:0] instr     ;

  logic [4:0]  rs1_addr  ;
  logic [4:0]  rs2_addr  ;
  logic [4:0]  rd_addr   ;
  logic [31:0] imm       ;
  alu_op_e     alu_op    ;
  logic        rd_wren   ;
  logic [1:0]  op_b_sel  ;
  logic        is_pc     ;
  logic        is_control;
  bru_op_e     bru_op    ;
  logic        is_load   ;
  logic [4:0]  lsu_strb  ;
  logic        mem_wr    ;

  logic [31:0] rs1_data  ;
  logic [31:0] rs2_data  ;
  logic [31:0] rd_data   ;

  logic [31:0] operand_a ;
  logic [31:0] operand_b ;
  logic [31:0] alu_data  ;
  logic        bru_exp   ;

  logic [31:0] pc_bru    ;
  logic        is_taken  ;

  logic [31:0] ld_data   ;

  /* verilator lint_off UNUSED */
  logic unused;
  logic illegal_o;
  assign unused = illegal_o;
  /* verilator lint_on UNUSED */

  always_comb begin : proc_pc
    pc_d = is_taken ? pc_bru : pc_q + 4;
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      pc_q <= '0;
    end
    else begin
      pc_q <= pc_d;
    end
  end

  assign pc_debug_o = pc_q;

  inst_memory instMemory (
    .clk_i   (clk_i ),
    .rst_ni  (rst_ni),
    .paddr_i (pc_q[12:0]),
    .prdata_o(instr )
  );

  decoder decoder (
    .instr_i     (instr     ),
    .rs1_addr_o  (rs1_addr  ),
    .rs2_addr_o  (rs2_addr  ),
    .rd_addr_o   (rd_addr   ),
    .imm_o       (imm       ),
    .alu_op_o    (alu_op    ),
    .rd_wren_o   (rd_wren   ),
    .op_b_sel_o  (op_b_sel  ),
    .is_pc_o     (is_pc     ),
    .is_control_o(is_control),
    .bru_op_o    (bru_op    ),
    .is_load_o   (is_load   ),
    .lsu_strb_o  (lsu_strb  ),
    .mem_wr_o    (mem_wr    ),
    .illegal_o   (illegal_o )
  );

  regfile regfile (
    .clk_i     (clk_i   ),
    .rst_ni    (rst_ni  ),
    .rs1_addr_i(rs1_addr),
    .rs2_addr_i(rs2_addr),
    .rs1_data_o(rs1_data),
    .rs2_data_o(rs2_data),
    .rd_addr_i (rd_addr ),
    .rd_data_i (rd_data ),
    .rd_wren_i (rd_wren )
  );

  always_comb begin : proc_op_a
    operand_a = is_pc ? pc_q : rs1_data;
  end

  always_comb begin : proc_op_b
    case (op_b_sel)
      2'b00 : operand_b = rs2_data;
      2'b01 : operand_b = imm     ;
      2'b10 : operand_b = 32'h4   ;
      2'b11 : operand_b = rs2_data;
    endcase
  end

  alu alu (
    .operand_a_i(operand_a),
    .operand_b_i(operand_b),
    .alu_op_i   (alu_op   ),
    .alu_data_o (alu_data ),
    .bru_exp_o  (bru_exp  )
  );

  bru bru (
    .pc_i        (pc_q      ),
    .rs1_data_i  (rs1_data  ),
    .imm_i       (imm       ),
    .is_control_i(is_control),
    .bru_op_i    (bru_op    ),
    .bru_exp_i   (bru_exp   ),
    .pc_bru_o    (pc_bru    ),
    .is_taken_o  (is_taken  )
  );

  lsu lsu (
    .paddr_i  (alu_data     ),
    .penable_i(1'b1         ),
    .pwrite_i (mem_wr       ),
    .pwdata_i (rs2_data     ),
    .pstrb_i  (lsu_strb[3:0]),
    .prdata_o (ld_data      ),
    .psign_i  (lsu_strb[4]  ),
    .io_sw_i  (io_sw_i      ),
    .io_lcd_o (io_lcd_o     ),
    .io_ledg_o(io_ledg_o    ),
    .io_ledr_o(io_ledr_o    ),
    .io_hex0_o(io_hex0_o    ),
    .io_hex1_o(io_hex1_o    ),
    .io_hex2_o(io_hex2_o    ),
    .io_hex3_o(io_hex3_o    ),
    .io_hex4_o(io_hex4_o    ),
    .io_hex5_o(io_hex5_o    ),
    .io_hex6_o(io_hex6_o    ),
    .io_hex7_o(io_hex7_o    ),
    .clk_i    (clk_i        ),
    .rst_ni   (rst_ni       )
  );

  assign rd_data = is_load ? ld_data : alu_data;

endmodule : singlecycle
