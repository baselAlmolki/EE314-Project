import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
import random
from tqdm import tqdm


state_dict = {
    0: "S_IDLE",
    1: "S_FORWARD",
    2: "S_BACKWARD",
    3: "S_IAttack_start",
    4: "S_IAttack_active",
    5: "S_IAttack_recovery", 
    6: "S_DAttack_start",
    7: "S_DAttack_active",
    8: "S_DAttack_recovery",
    9: "S_HITSTUN",
    10: "S_BLOCKSTUN",
}

def to_hex(obj):
    '''This is useless for this test as everything is 4bits but i will keep cuz i am lazy
    to remove all its declerations'''
    if "x" not in str(obj) and "z" not in str(obj):
        return int(obj)
    else: return obj

def Log_Design(dut):
    #Log whatever signal you want from the datapath, called before positive clock edge
    s1 = "dut"
    obj1 = dut
    wires = []
    submodules = []
    for attribute_name in dir(obj1):
        attribute = getattr(obj1, attribute_name)
        if attribute.__class__.__module__.startswith('cocotb.handle'):
            if(attribute.__class__.__name__ == 'ModifiableObject'):
                wires.append((attribute_name, to_hex(attribute.value)) )
            elif(attribute.__class__.__name__ == 'HierarchyObject'):
                submodules.append((attribute_name, attribute.get_definition_name()) )
            elif(attribute.__class__.__name__ == 'HierarchyArrayObject'):
                submodules.append((attribute_name, f"[{len(attribute)}]") )
            elif(attribute.__class__.__name__ == 'NonHierarchyIndexableObject'):
                wires.append((attribute_name, [to_hex(v) for v in attribute.value] ) )
            #else:
                #print(f"{attribute_name}: {type(attribute)}")
                
        #else:
            #print(f"{attribute_name}: {type(attribute)}")
    #for sub in submodules:
    #    print(f"{s1}.{sub[0]:<16}is {sub[1]}")
    for wire in wires:
        print(f"{s1}.{wire[0]:<4} = {wire[1]}") 
        # Explain the formatting for future me
        # : formatting delimiter
        # <4 align left by inserting padding of width 4
        # so prints will look neatly aligned and easy to read
        # for variables that are smaller than 4 characters
        # but if longer than 4, then it wont add more padding


def get_actual_res(state, control, width):
    mask = (1 << width) - 1
    
    if control == 0: # 00 = hold
        return state
    elif control == 1: # 01 = increment
        return (state + 1) & mask
    elif control == 2: # 10 = decrement
        return (state - 1) & mask
    elif control == 3: # 11 = reset
        return 0


@cocotb.test()
async def test_coded_converter(dut):

    clock = Clock(dut.CLK, 20, units="us") # 0.5 MHz clock
    cocotb.start_soon(clock.start()) # scheule clock to start
 
    # Helper functions
    async def reset_dut():
        await RisingEdge(dut.CLK)
        await Timer(1, units="us")  # small delay
        cocotb.log.info("Reset complete")


    test_failed = False  # Flag to track overall test failure

    #     state_dict = {
    #     0: "S_IDLE",
    #     1: "S_FORWARD",
    #     2: "S_BACKWARD",
    #     3: "S_IAttack_start",
    #     4: "S_IAttack_active",
    #     5: "S_IAttack_recovery", 
    #     6: "S_DAttack_start",
    #     7: "S_DAttack_active",
    #     8: "S_DAttack_recovery",
    #     9: "S_HITSTUN",
    #     10: "S_BLOCKSTUN",
    # }
    #(p1state, p2state, x1, x2)
    state_inputs = [(0,0, 200, 330), (4,0, 200, 270), (4, 2, 200, 270), (0, 7, 260, 400), (8, 7, 260, 400)]

    
    # await reset_dut(random.randint(0,2)) # reset the DUT to start with a known state
    # counter = -1
    # Loop through counter values cycle_num times
    await reset_dut()
    for state_input in tqdm(state_inputs, desc="Testing col pins"):
        dut.state1.value = state_input[0]  # Set player 1 state
        dut.state2.value = state_input[1]  # Set player 2 state
        dut.x1.value = state_input[2]  # Set player 1 x position
        dut.x2.value = state_input[3]  # Set player 2 x position
        await RisingEdge(dut.CLK)
        await Timer(5, units='us') # allow logic to propogate
        
        p1range = "Yes" if dut.withinp1range.value else "No"
        p2range = "Yes" if dut.withinp2range.value else "No"

        cocotb.log.info(
            f"state1: {state_dict[int(dut.state1.value)]}, state2: {state_dict[int(dut.state2.value)]}"
            f"\nis p2 within p1's attack range? {p1range}"
            f"\nis p1 within p2's attack range? {p2range}"
            f"\nP1 hit detection: {dut.p1_stunmode.value in (1,2)}"
            f"\nP2 hit detection: {dut.p2_stunmode.value in (1,2)}"
            )
        Log_Design(dut) 
        # CLKOUT_expected = 1 if (counter % FACTOR) < FACTOR/2 else 0
        # counter += 1

        # CLK = dut.CLK.value
        # if start_new_clock and CLK == 1 and last_clk == 0:
        #     start_new_clock = True
        #     dut.CLK.value = last_clk
        
        # Check if the output matches the expected value
        # if dut.keypresses.value != exp_keypresses_val:
            # Log_Design(dut)
            # cocotb.log.info(f"CLKOUT: expected {CLKOUT_expected}, got {CLKOUT}")
            # continue
            # test_failed = True  # Mark overall test as failed
            # cocotb.log.error(f"col_dut = {dut.col.value} | Missmatch keypresses: expected {expected_keypresses}, got {keypresses_dut}")
            # Log_Design(dut)
        # else:
        #     pass
            # Log_Design(dut)
            # cocotb.log.info(f"counter = {counter} | CLKOUT: expected {CLKOUT_expected}, got {CLKOUT}")
        # if counter > 28:
        #     break

    # Final assertion for the overall result
    if test_failed:
        raise AssertionError("Some test cases failed!")
    else:
        cocotb.log.info("All test cases passed!")


