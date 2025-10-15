# --- SETUP ---
addi x5, x0, 100        # Base address for memory operations
lui x6, 0x12345         # x6 = 0x12345000
addi x6, x6, 0x678      # x6 = 0x12345678

# --- TESTS ---
# Test SW: Store a full word at address 100
sw x6, 0(x5)

# Test LW: Load the full word back
lw x10, 0(x5)

# Test LB vs LBU on a byte with its sign bit set (0x_34_)
lb  x11, 2(x5)          # Signed load of 0x34
lbu x12, 2(x5)          # Unsigned load of 0x34

# Test SB: Overwrite just the LSB (0x78) with 0xAA
addi x7, x0, 0xAA       # x7 = 170
sb x7, 0(x5)

# Test that only the byte was changed
lw x13, 0(x5)

# --- HALT ---
halt: beq x0, x0, halt

# program_instructions = [
#         "06400293",
#         "12345337",
#         "67830313",
#         "0062a023",
#         "0002a503",
#         "00228583",
#         "0022c603",
#         "0aa00393",
#         "00728023",
#         "0002a683",
#         "00000063"
#     ]