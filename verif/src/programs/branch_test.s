# --- SETUP ---
addi x5, x0, 10
addi x6, x0, 10

# --- TESTS ---
# Test BEQ (taken, forward)
beq x5, x6, forward_branch # Should be TAKEN
addi x10, x0, 99           # This is a FAIL code, should be skipped

forward_branch:
addi x10, x0, 1            # PASS code for forward branch

# Test BNE (not taken)
bne x5, x6, skip_bne       # Should NOT be taken
addi x11, x0, 2            # PASS code for BNE not taken

skip_bne:
# Test BLT (taken, backward)
addi x7, x0, 5             # x7 = 5
blt x7, x5, backward_branch # 5 < 10 is TRUE, should be TAKEN
j somewhere_else

backward_branch:
addi x12, x0, 3            # PASS code for backward branch

somewhere_else:
# --- HALT ---
halt: beq x0, x0, halt

# program_instructions = [
#         "00a00293",
#         "00a00313",
#         "00628463",
#         "06300513",
#         "00100513",
#         "00629463",
#         "00200593",
#         "00500393",
#         "0053c463",
#         "0080006f",
#         "00300613",
#         "00000063"
#     ]