def generate_hex_file(instructions, filename):
    """
    Generates a little-endian, byte-per-line hex file from a list of 32-bit instructions.

    Args:
        instructions (list of str): A list of 8-character hex strings.
        filename (str): The name of the output hex file to create.
    """
    try:
        with open(filename, 'w') as f:
            # Write the header comment with the original instructions
            f.write("// 32-bit instructions (Big Endian):\n")
            for instr in instructions:
                f.write(f"// 0x{instr}\n")
            f.write("// Little-endian bytes\n")

            # Process each instruction and write the bytes
            for instr in instructions:
                # Ensure the instruction is 8 characters long, padding with zeros if needed
                instr = instr.zfill(8)
                
                # Extract the bytes from the 32-bit word
                byte3 = instr[0:2]  # MSB
                byte2 = instr[2:4]
                byte1 = instr[4:6]
                byte0 = instr[6:8]  # LSB

                # Write the bytes in little-endian order (LSB first), one per line
                f.write(f"{byte0}\n")
                f.write(f"{byte1}\n")
                f.write(f"{byte2}\n")
                f.write(f"{byte3}\n")
        
        print(f"Successfully generated '{filename}'.")

    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    
    # 1. Define 32-bit instructions here
    program_instructions = [
        "00000563",
        "00000013",
        "00000013",
        "00000013",
        "00000013"
    ]

    # 2. Choose output file name
    output_filename = "verif\src\programs\cpu_test_05.hex"

    # 3. Generate
    generate_hex_file(program_instructions, output_filename)