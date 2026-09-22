import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer


@cocotb.test()
async def test_counter(dut):

    # Start clock: 10 us period
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # -------------------------------------------------
    # RESET
    # -------------------------------------------------
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    # Hold reset for two clock cycles
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Release reset between clock edges
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1

    # LOAD = 0, OUTPUT ENABLE = 1
    dut.ui_in.value = 0b00000010

    # -------------------------------------------------
    # TEST NORMAL COUNTING
    # -------------------------------------------------
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    assert dut.uio_out.value == 1

    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    assert dut.uio_out.value == 2

    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    assert dut.uio_out.value == 3

    # -------------------------------------------------
    # TEST LOAD
    # -------------------------------------------------

    # Set inputs before the next rising edge
    await FallingEdge(dut.clk)

    dut.uio_in.value = 20
    dut.ui_in.value = 0b00000001   # LOAD = 1

    # Load 20 into the counter
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")

    # Turn LOAD off and OUTPUT ENABLE on
    await FallingEdge(dut.clk)

    dut.ui_in.value = 0b00000010

    await Timer(1, units="ns")
    assert dut.uio_out.value == 20

    # Counter should increment 20 -> 21
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    assert dut.uio_out.value == 21

    # -------------------------------------------------
    # TEST 8-BIT WRAPAROUND
    # -------------------------------------------------

    await FallingEdge(dut.clk)

    dut.uio_in.value = 255
    dut.ui_in.value = 0b00000001   # LOAD = 1

    # Load 255
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")

    # Disable LOAD and enable output
    await FallingEdge(dut.clk)

    dut.ui_in.value = 0b00000010

    await Timer(1, units="ns")
    assert dut.uio_out.value == 255

    # 255 + 1 should wrap back to 0
    await RisingEdge(dut.clk)
    await Timer(1, units="ns")
    assert dut.uio_out.value == 0
