##------------------------------------------------------------------------
## Module Name    : test
## Creator        : Charbel SAAD
## Creation Date  : 18/07/2024
##
## Description:
## This test bench tests the cpu_top module with a spi_ram simulation and
## a custumizable user code
##
##------------------------------------------------------------------------

import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.utils import get_sim_time

import numpy as np

run_state = True

ram = np.zeros(2**16, dtype = np.ubyte)

def read_code(file_path):
    global ram
    with open(file_path, 'rb') as f:
        data = np.fromfile(f, dtype='ubyte')
    if data.size <= ram.size:
        ram[:data.size] = data
    else:
        ram = data[:ram.size]
        print("The code can't fit entirely in the RAM, it will be trimmed.")

def save_ram(file_path):
    global ram
    with open(file_path, 'wb') as f:
        ram.tofile(f)

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
    while run_debug:
        dut.debug_sclk_i.value = 0
        await Timer(5, units = "ns")
        dut.debug_sclk_i.value = 1
        await Timer(5, units = "ns")

@cocotb.test()
async def test(dut):
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

    read_code("a.out")
    await Timer(200000, units = 'ns')
    save_ram("ram.bin")

    # TEST END
    run_state = False
    await Timer(1, units = "ns")
