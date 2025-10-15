# --- TESTS ---
# Test max positive immediate
addi x10, x0, 2047

# Test max negative immediate
addi x11, x0, -2048

# Test zero immediate
addi x12, x10, 0

# Test max shift immediate
slli x13, x10, 31

# Test SLTI: -2048 < -2047 is TRUE
slti x14, x11, -2047

# --- HALT ---
halt: beq x0, x0, halt

# program_instructions = [
#         "7ff00513",
#         "80000593",
#         "00050613",
#         "01f51693",
#         "8015a713",
#         "00000063"
#     ]