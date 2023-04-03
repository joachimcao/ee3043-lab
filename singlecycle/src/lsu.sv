module lsu (
  // APB Protocol
  input  logic [31:0]       paddr_i  ,
  input  logic              penable_i,
  input  logic              pwrite_i ,
  input  logic [31:0]       pwdata_i ,
  input  logic [3:0]        pstrb_i  ,
  output logic [31:0]       prdata_o ,

  input logic               psign_i  ,

  // Peripheral
  input  logic [31:0]       io_sw_i  ,
  output logic [31:0]       io_lcd_o ,
  output logic [31:0]       io_ledg_o,
  output logic [31:0]       io_ledr_o,
  output logic [31:0]       io_hex0_o,
  output logic [31:0]       io_hex1_o,
  output logic [31:0]       io_hex2_o,
  output logic [31:0]       io_hex3_o,
  output logic [31:0]       io_hex4_o,
  output logic [31:0]       io_hex5_o,
  output logic [31:0]       io_hex6_o,
  output logic [31:0]       io_hex7_o,

  /* verilator lint_off UNUSED */
  input  logic              clk_i    ,
  input  logic              rst_ni
  /* verilator lint_on UNUSED */
);

  /* verilator lint_off UNUSED */
  logic unused;
  assign unused = |addr[1:0] || |paddr_i[31:11];
  /* verilator lint_on UNUSED */

  // Peripheral Buffer
  logic [31:0]       periph_in;
  logic [31:0]       periph_out [10:0];

  // Local declaration
  logic [11:0]       addr;
  logic [1:0]        sel;
  logic              write_dm;
  logic              write_po;
  logic [31:0]       rdata_dm;
  logic [31:0]       rdata_pi;
  logic [31:0]       rdata_po;

  logic [31:0]       rdata;

  assign addr = paddr_i[11:0];

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_periph_in
    if (!rst_ni) begin
      periph_in <= '0;
    end
    else begin
      periph_in <= io_sw_i;
    end
  end
  assign rdata_pi = periph_in;

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_periph_out
    if (!rst_ni) begin
      for (int i = 0; i < 10; i++)
        periph_out[i] <= '0;
    end
    else begin
      if (write_po) begin
        if (pstrb_i[0]) begin
          periph_out[addr[7:4]][ 7: 0] <= pwdata_i[ 7: 0];
        end
        if (pstrb_i[1]) begin
          periph_out[addr[7:4]][15: 8] <= pwdata_i[15: 8];
        end
        if (pstrb_i[2]) begin
          periph_out[addr[7:4]][23:16] <= pwdata_i[23:16];
        end
        if (pstrb_i[3]) begin
          periph_out[addr[7:4]][31:24] <= pwdata_i[31:24];
        end
      end
    end
  end
  assign rdata_po = periph_out[addr[7:4]];

  assign io_hex0_o = periph_out[0];
  assign io_hex1_o = periph_out[1];
  assign io_hex2_o = periph_out[2];
  assign io_hex3_o = periph_out[3];
  assign io_hex4_o = periph_out[4];
  assign io_hex5_o = periph_out[5];
  assign io_hex6_o = periph_out[6];
  assign io_hex7_o = periph_out[7];
  assign io_ledr_o = periph_out[8];
  assign io_ledg_o = periph_out[9];
  assign io_lcd_o  = periph_out[10];

  data_memory dataMemory (
    .paddr_i  (addr[9:0]),
    .penable_i(1'b1    ),
    .pwrite_i (write_dm),
    .pwdata_i (pwdata_i),
    .pstrb_i  (pstrb_i ),
    .prdata_o (rdata_dm),
    .clk_i    (clk_i   ),
    .rst_ni   (rst_ni  )
  );

  always_comb begin : proc_gen_sel
    casez (addr[11:8])
      4'h0, 4'h1, 4'h2, 4'h3:    sel = 2'h1;
      4'h4:    sel = 2'h2;
      4'h5:    sel = 2'h3;
      default: sel = 2'h0;
    endcase

    write_dm = 1'b0;
    write_po = 1'b0;
    if (pwrite_i && penable_i) begin
      write_dm = (sel == 2'h1);
      write_po = (sel == 2'h2);
    end
  end

  always_comb begin : proc_sel_rdata
    case (sel)
      2'h0: rdata = '0;
      2'h1: rdata = rdata_dm;
      2'h2: rdata = rdata_po;
      2'h3: rdata = rdata_pi;
    endcase

    prdata_o[ 7: 0] = pstrb_i[0] ? rdata[ 7: 0] :                        '0;
    prdata_o[15: 8] = pstrb_i[1] ? rdata[15: 8] : {8{rdata[ 7] && psign_i}};
    prdata_o[23:16] = pstrb_i[2] ? rdata[23:16] : {8{rdata[15] && psign_i}};
    prdata_o[31:24] = pstrb_i[3] ? rdata[31:24] : {8{rdata[31] && psign_i}};
  end

endmodule : lsu
