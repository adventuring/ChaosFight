#!/usr/bin/env python3
"""
Convert special sprites (QuestionMark, CPU, No) from PNG to batariBASIC binary data
"""

from PIL import Image
import os

def convert_png_to_binary_data(png_path, sprite_name):
    """Convert PNG to 8x16 binary data for batariBASIC"""
    try:
        img = Image.open(png_path)
        
        # Convert to grayscale if needed
        if img.mode != 'L':
            img = img.convert('L')
        
        # Ensure it's 8x16
        if img.size != (8, 16):
            img = img.resize((8, 16), Image.LANCZOS)
        
        # Convert to binary data
        binary_rows = []
        for y in range(16):
            row_bits = []
            for x in range(8):
                pixel = img.getpixel((x, y))
                # Convert to binary (white=1, black=0)
                if pixel > 128:  # White pixel
                    row_bits.append('1')
                else:  # Black pixel
                    row_bits.append('0')
            binary_rows.append(''.join(row_bits))
        
        return binary_rows
    
    except Exception as e:
        print(f"Error converting {png_path}: {e}")
        return None

def generate_batari_basic_data(sprite_name, binary_rows):
    """Generate batariBASIC data statement"""
    output = []
    output.append(f"          data {sprite_name}Sprite")
    
    for row in binary_rows:
        output.append(f"            %{row}")
    
    output.append("          end")
    return output

def main():
    # Convert the three special sprites
    sprites = [
        ("Source/Art/QuestionMark.png", "QuestionMark"),
        ("Source/Art/CPU.png", "CPU"), 
        ("Source/Art/No.png", "No")
    ]
    
    all_output = []
    all_output.append("          rem ==================================================================")
    all_output.append("          rem SPECIAL SPRITES - CONVERTED FROM XCF")
    all_output.append("          rem ==================================================================")
    all_output.append("")
    
    for png_path, sprite_name in sprites:
        if os.path.exists(png_path):
            print(f"Converting {png_path}...")
            binary_rows = convert_png_to_binary_data(png_path, sprite_name)
            if binary_rows:
                sprite_data = generate_batari_basic_data(sprite_name, binary_rows)
                all_output.extend(sprite_data)
                all_output.append("")
            else:
                print(f"Failed to convert {png_path}")
        else:
            print(f"File not found: {png_path}")
    
    # Write to output file
    output_file = "Source/Generated/SpecialSprites.bas"
    with open(output_file, 'w') as f:
        f.write('\n'.join(all_output))
    
    print(f"Generated {output_file}")

if __name__ == "__main__":
    main()
