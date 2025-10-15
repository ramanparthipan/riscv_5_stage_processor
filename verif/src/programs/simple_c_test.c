// A minimal C program to test basic CPU functionality.

// The memory address where the final result will be stored for verification.
#define VERIFICATION_ADDRESS ((volatile int*)0x200)

int main() {
    int x = 10;
    
    // Store the value of x to the known memory address.
    // This will generate load/store instructions for the CPU to execute.
    *VERIFICATION_ADDRESS = x;

    // Infinite loop to halt the processor at the end.
    while(1);

    return 0; // Unreachable
}