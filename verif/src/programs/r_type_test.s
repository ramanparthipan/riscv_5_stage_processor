# --- SETUP ---
addi x5, x0, 5          # x5 = 5
addi x6, x0, -5         # x6 = -5 (0xFFFFFFFB)
addi x7, x0, 0xFF       # x7 = 255
addi x8, x0, 4          # x8 = 4 (for shift amount)
addi x9, x0, 2          # x9 = 2 (for shift amount)

# --- TESTS ---
# Test SUB: 5 - 5 = 0
sub x10, x5, x5

# Test XOR: 5 ^ 5 = 0
xor x11, x5, x5

# Test AND: 255 & 5 = 5
and x12, x7, x5

# Test SLL: 5 << 2 = 20
sll x13, x5, x9

# Test SRL vs SRA on a negative number
srl x14, x6, x8         # Logical shift of -5 by 4
sra x15, x6, x9         # Arithmetic shift of -5 by 2

# Test SLT vs SLTU: -5 vs 5
slt x16, x6, x5         # Signed: -5 < 5 is TRUE
sltu x17, x6, x5        # Unsigned: (large_positive) < 5 is FALSE

# --- HALT ---
halt: beq x0, x0, halt

# program_instructions = [
#         "00500293",
#         "ffb00313",
#         "0ff00393",
#         "00400413",
#         "00200493",
#         "40528533",
#         "0052c5b3",
#         "0053f633",
#         "009296b3",
#         "00835733",
#         "409357b3",
#         "00532833",
#         "005338b3",
#         "00000063"
#     ]