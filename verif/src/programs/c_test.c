// A simple C program to test a RISC-V CPU.
// It sums the elements of an array and stores the result in memory.

// Use 'volatile' to ensure the compiler does not optimize away
// the final memory store, which is needed for verification.
#define VERIFICATION_ADDRESS ((volatile int *)0x200)

// The data to be summed. The compiler will place this in the .data section.
int data_arr[] = {10, 20, 30, 40, 5};
int num_elements = 5;

int main() {
    int sum = 0;

    // Loop through the array and add each element to the sum
    for (int i = 0; i < num_elements; i++) {
        sum = sum + data_arr[i];
    }

    // Store the final result in a known memory location for verification
    *VERIFICATION_ADDRESS = sum;

    // Infinite loop to halt the processor
    while(1);

    return 0; // This part is unreachable
}