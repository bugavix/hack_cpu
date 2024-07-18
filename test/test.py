##------------------------------------------------------------------------
## Module Name    : cpu_top_tb
## Creator        : Charbel SAAD
## Creation Date  : 04/06/2024
##
## Description:
## This test bench tests the cpu_top module with a spi_ram simulation
##
##------------------------------------------------------------------------

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.utils import get_sim_time

import numpy as np

run_state = True

ram = np.zeros(2**16, dtype = np.ubyte)

async def spi_ram(dut):
    global ram
    global run_state
    ram_instruction = np.ubyte(0)
    ram_address = np.ushort(0)
    ram_buffer = np.ubyte(0)
    while run_state:
        await FallingEdge(dut.mem_sclk_o) # RAM functioning
        print(f"Ram called at {get_sim_time(units = 'ns')}")
        # instruction fetch
        ram_instruction = 0
        for i in range(8):
            await RisingEdge(dut.mem_sclk_o)
            ram_instruction |= np.left_shift(dut.mem_out_o.value.integer, 7 - i)
        print(f"At {get_sim_time('ns')}: instruction finished fetching: instruction {ram_instruction}")

        # address fetch
        ram_address = 0
        for i in range(16):
            await RisingEdge(dut.mem_sclk_o)
            ram_address |= np.left_shift(dut.mem_out_o.value.integer, 15 - i)
        print(f"At {get_sim_time('ns')}: address finished fetching: address {ram_address}")
        
        stop_ram = False

        # instruction decoding and execution
        if ram_instruction == 2: # WRITE to RAM
            while not stop_ram:
                ram_buffer = 0
                for i in range(8):
                    await RisingEdge(dut.clk)
                    if dut.mem_csb_o.value.integer:
                        stop_ram = True
                        break
                    else:
                        ram_buffer |= np.left_shift(dut.mem_out_o.value.integer, 7 - i)
                if not stop_ram:
                    ram[ram_address] = ram_buffer
                    print(f"At {get_sim_time('ns')}: Wrote byte {ram[ram_address]} at address {ram_address}")
                ram_address += 1
        elif ram_instruction == 3: # READ from RAM
            while not stop_ram:
                for i in range(8):
                    await FallingEdge(dut.clk)
                    if dut.mem_csb_o.value.integer:
                        stop_ram = True
                        break
                    else:
                        dut.mem_in_i.value = 1 if ram[ram_address] & 2 ** (7 - i) else 0
                if not stop_ram:
                    print(f"At {get_sim_time('ns')}: outputed byte {ram[ram_address]} from address {ram_address}")
                ram_address += 1


async def generate_clock(dut):
    global run_state
    while run_state:
        dut.clk.value = 0
        await Timer(5, units = "ns")
        dut.clk.value = 1
        await Timer(5, units = "ns")

run_debug = True

async def generate_sclk(dut):
    global run_debug
    first = True
    while run_debug:
        if first:
            dut.debug_sclk_i.value = 1
            await Timer(5, units = "ns")
            first = False
        dut.debug_sclk_i.value = 0
        await Timer(5, units = "ns")
        dut.debug_sclk_i.value = 1
        await Timer(5, units = "ns")

@cocotb.test()
async def cpu_top_tb(dut):
    global ram
    global run_state
    run_state = True
    cocotb.start_soon(spi_ram(dut))
    cocotb.start_soon(generate_clock(dut))
    dut.halt_i.value = 0
    dut.debug_csb_i.value = 1
    dut.resetb.value = 0
    dut.debug_sclk_i.value = 1
    dut.debug_csb_i.value = 1
    await Timer(60, units = "ns")
    dut.resetb.value = 1
    # TEST START

    ram[0] = 0xFE 
    ram[1] = 0x7F # 7FFE: @32766 

    ram[2] = 0xC8
    ram[3] = 0xEF # EFC8: M = 1

    ram[4] = 0xFA
    ram[5] = 0x7F # 7FFA: @32762

    ram[6] = 0xC8
    ram[7] = 0xEF # EFC8: M = 1

    ram[8] = 0xF8
    ram[9] = 0x7F # 7FF8: @32760

    ram[10] = 0xC8
    ram[11] = 0xEF # EFC8: M = 1

    ram[12] = 0xF6
    ram[13] = 0x7F # 7FF6: @32758

    ram[14] = 0x98
    ram[15] = 0xEA # EA98: MD = 0 

    ram[16] = 0xFC
    ram[17] = 0x7F # 7FFC: @32764

    ram[18] = 0xD0
    ram[19] = 0xF4 # F4D0: D = D - M 

    ram[20] = 0x3A
    ram[21] = 0x00 # 003A: @58

    ram[22] = 0x03
    ram[23] = 0xE3 # E303: D ; JGE

    ram[24] = 0xFA
    ram[25] = 0x7F # 7FFA: @32762

    ram[26] = 0x10
    ram[27] = 0xFC # FC10: D = M

    ram[28] = 0xF8
    ram[29] = 0x7F # 7FF8: @32760

    ram[30] = 0x90
    ram[31] = 0xF0 # F090: D = D + M

    ram[32] = 0xFE
    ram[33] = 0x7F # 7FFE: @32766

    ram[34] = 0x08
    ram[35] = 0xE3 # E308: M = D

    ram[36] = 0xF8
    ram[37] = 0x7F # 7FF8: @32760

    ram[38] = 0x10
    ram[39] = 0xFC # FC10: D = M

    ram[40] = 0xFA
    ram[41] = 0x7F # 7FFA: @32762

    ram[42] = 0x08
    ram[43] = 0xE3 # E308: M = D

    ram[44] = 0xFE
    ram[45] = 0x7F # 7FFE: @32766

    ram[46] = 0x10
    ram[47] = 0xFC # FC10: D = M

    ram[48] = 0xF8
    ram[49] = 0x7F # 7FF8: @32760

    ram[50] = 0x08
    ram[51] = 0xE3 # E308: M = D

    ram[52] = 0xF6
    ram[53] = 0x7F # 7FF6: @32758

    ram[54] = 0xD8 
    ram[55] = 0xFD # FDD8: MD = M + 1 

    ram[56] = 0x10
    ram[57] = 0x00 # 0010: @16

    ram[58] = 0x07
    ram[59] = 0xEA # EA07: 0 ; JMP

    ram[0x7FFC] = 0x04
    ram[0x7FFD] = 0x00 # initializing n with the value 4

    await Timer(64000, units = "ns")
    assert ram[0x7FFE] == 8, "res has a wrong value"

    # Testing debug
    regD = np.ushort(0)
    regA = np.ushort(0)
    pc = np.ushort(0)
    regIR = np.ushort(0)
    dut.halt_i.value = 1
    await Timer(10, units = "ns") 
    
    for k in range(4):
        target = [0, 58, 58, 0]
        data = np.zeros(4, dtype = np.ushort)
        dut.debug_csb_i.value = 0
        run_debug = True
        cocotb.start_soon(generate_sclk(dut))
        
        for i in range(2):
            await FallingEdge(dut.debug_sclk_i)
            dut.debug_in_i.value = 1 if k & 2**(1 - i) else 0

        await RisingEdge(dut.debug_sclk_i)
        for i in range(16):
            await RisingEdge(dut.debug_sclk_i)
            data[k] |= np.left_shift(dut.debug_out_o.value.integer, 15 - i)

        if k != 3 :
            assert data[k] == target[k], f"{data[k]}, {target[k]}"

        run_debug = False
        dut.debug_csb_i.value = 1 # Ending the debug transfer
        await Timer(20, units = "ns")

    await Timer(1000, units = "ns")
    
    # TEST END
    run_state = False
    await Timer(1, units = "ns")
