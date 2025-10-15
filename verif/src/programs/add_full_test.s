# Test program for verifying all ADD instruction edge cases in a 5-stage pipeline

# --- SETUP ---
# Load initial values for testing
addi x5, x0, 1          # x5 = 1
lui  x6, 0x80000
addi x6, x6, -1         # x6 = max positive signed integer?

# ==============================================================================
# ## 1. Arithmetic Edge Cases ##
# ==============================================================================
# Test: ADD with zero operand (x5 + x0)
# Expected: x10 = 1
add x10, x5, x0

# Test: ADD causing overflow (0x7FFFFFFF + 1)
# Expected: x11 = 0x80000000 (wraps around to most negative number)
add x11, x6, x5

# ==============================================================================
# ## 2. Destination Register ('rd') Edge Case ##
# ==============================================================================
# Test: ADD with rd=x0
# Expected: x0 must remain 0. This is verified by observing the register file.
add x0, x5, x6

# ==============================================================================
# ## 3. Data Hazard Cases (Forwarding) ##
# ==============================================================================
# Setup values for forwarding tests
addi x1, x0, 100
addi x2, x0, 200

# Test: rs1 data forwarded from MEM stage
# Expected: x12 = 300 (from x3) + 1 = 301
add x3, x1, x2      # x3 = 300. Result is in EX stage.
nop                 # x3 result is now in MEM stage.
add x12, x3, x5     # This ADD needs x3 from MEM stage.

# Test: rs2 data forwarded from WB stage
# The result for x12 will be in the WB stage two cycles after the 'add x12' instruction.
# Expected: x13 = 1 + 301 (from x12) = 302
nop
nop
add x13, x5, x12    # This ADD needs x12 from WB stage.

# Test: MEM stage forwarding prioritized over WB (for rs1)
# Expected: x14 = 301 (the newest value of x4), not 300.
add x4, x1, x2      # First, x4 = 300. This instruction will be in MEM.
add x4, x4, x5      # Then, x4 = 300 + 1 = 301. This instruction will be in EX.
add x14, x4, x0     # This ADD needs the result from the second 'add' (EX stage).

# ==============================================================================
# ## 4. Stall Hazard Case (Load-Use) ##
# ==============================================================================
# Test: ADD stalls for 1 cycle after a LW to its source register
# Expected: x16 = 1234 (from loaded x15) + 1 = 1235
addi x8, x0, 100    # Use address 100 for memory
addi x9, x0, 1234   # Value to store/load
sw x9, 0(x8)        # Store 1234 at address 100
lw x15, 0(x8)       # Load 1234 into x15
add x16, x15, x5    # LOAD-USE HAZARD: Pipeline must stall here.

# ==============================================================================
# ## 5. Control Hazard Cases ##
# ==============================================================================
# Test: ADD is flushed when it follows a taken branch
# Expected: x17 should remain 0, proving the add was flushed.
addi x17, x0, 0     # Initialize x17 to 0
beq x0, x0, skip_add # This branch is always taken
add x17, x5, x5     # This ADD is in the branch shadow and must be flushed.
skip_add:

# Test: ADD result is forwarded correctly to a branch
# Expected: The bne is NOT taken (1 != 1 is false). x19 should become 99.
add x18, x5, x0     # x18 becomes 1
bne x18, x5, end    # Branch needs forwarded result of x18.
addi x19, x0, 99    # This instruction should execute.

# ==============================================================================
# ## End of Program ##
# ==============================================================================
end:
# Infinite loop to halt the processor
halt: beq x0, x0, halt

# Machine code instructions to generate hex file
# program_instructions = [
#         "00100293",
#         "80000337",
#         "fff30313",
#         "00028533",
#         "005305b3", # "006285b3",
#         "00628033",
#         "06400093",
#         "0c800113",
#         "002081b3",
#         "00000013",
#         "00518633",
#         "00000013",
#         "00000013",
#         "00c286b3", # "005606b3",
#         "00208233",
#         "00520233",
#         "00020733", # "00400733",
#         "06400413",
#         "4d200493",
#         "00942023",
#         "00042783",
#         "00578833",
#         "00000893",
#         "00000463",
#         "005288b3",
#         "00028933",
#         "00591463",
#         "06300993",
#         "00000063"
#     ]