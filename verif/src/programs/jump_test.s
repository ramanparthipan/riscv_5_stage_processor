# --- SETUP ---
nop # Start program at non-zero pc value

# --- TESTS ---
# Test JAL
jal x1, target             # Jump to 'target', store 0x8 in x1
addi x10, x0, 99           # FAIL code, should be skipped

target:
addi x10, x0, 1            # PASS code, proves jump worked

# Test JALR as a 'return'
jalr x11, x1, 0             # Jump to address in x1 (0x104)

# --- HALT (will be skipped by JALR) ---
halt: beq x0, x0, halt

# program_instructions = [
#         "00000013",
#         "008000ef",
#         "06300513",
#         "00100513",
#         "000085e7",
#         "00000063"
#     ]