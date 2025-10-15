# --- SETUP ---
nop # Start program at address 0x4 to test AUIPC

# --- TESTS ---
# Test LUI
lui x10, 0xABCDE

# Test AUIPC
auipc x11, 0x11111

# --- HALT ---
halt: beq x0, x0, halt