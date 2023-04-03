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

module regfile (
  // Read ports
  input  logic [4:0]  rs1_addr_i,
  input  logic [4:0]  rs2_addr_i,

  output logic [31:0] rs1_data_o,
  output logic [31:0] rs2_data_o,

  // Write ports
  input  logic [4:0]  rd_addr_i ,
  input  logic [31:0] rd_data_i ,
  input  logic        rd_wren_i ,

  // Clock and asynchronous reset active low
  input  logic        clk_i     ,
  input  logic        rst_ni
);

  logic [31:0] register [0:31];

  always @(posedge clk_i or negedge rst_ni) begin : proc_write
    if (~rst_ni) begin
      for (int unsigned i=0; i < 32; i++) begin
        register[i] <= '0;
      end
    end
    else begin
      if (rd_wren_i && |rd_addr_i)
        register[rd_addr_i] <= rd_data_i;
    end
    //$writememh("./memory/regfile.mem", register);
  end

  always_comb begin : proc_read
    rs1_data_o = register[rs1_addr_i];
    rs2_data_o = register[rs2_addr_i];
  end

endmodule : regfile
