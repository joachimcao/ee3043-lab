README

--------------------------------------------------------------------------------
1. INSTRUCTION MEMORY

This is a 8KB memory to contain binary code, compiled from RISCV assembly code.
a. Module name: inst_memory
b. Inputs:
    i. paddr_i - 13bit address
   ii. clk_i   - clock
  iii. rst_ni  - low active reset
c. Outputs:
    i. prdata_o - 32bit data
d. You can put data into this memory using the keyword $readmemh.
   There are two memory data, instmem.data.sim, which is for testbench only, and instmem.data.kit, which is for implementing on DE2.
    i. If you use Windows
       You should copy instmem.data.kit, which is in mem directory, into your D: disk,
       in the line 27: $readmemh("../memory/instmem.data.kit", imem);
       change the path to "D:\\instmem.data.kit"
   ii. If you use Linux
       You do not need to do anything.

--------------------------------------------------------------------------------
2. DATA MEMORY

This is a 2KB memory to store data while the processor is running.
a. Module name: data_memory
b. Inputs:
    i. paddr_i   - 11-bit address
   ii. penable_i - enable the memory, 1 if you want to read or write
  iii. pwrite_i  - 1 if write, 0 if read
   iv. pwdata_i  - 32-bit data to write into the memory at the paddr_i address
    v. pstrb_i   - 4-bit byte mask, for example, 0100 will allow users to access bit slice [23:16] only, 1111 bit slice [31:0]
   vi. clk_i     - clock
  vii. rst_ni    - low active reset
c. Outputs
    i. prdata_o  - 32-bit data read from memory at the paddr_i address

--------------------------------------------------------------------------------
3. IMPLEMENTATION

When creating a Quartus project, you have to name it "wrapper"
The device is Cyclone II, "EP2C35F672C6"
Import the pin assignment using file "de2_pin.qsf"
Please check the path in the line 27 of inst_memory.sv
