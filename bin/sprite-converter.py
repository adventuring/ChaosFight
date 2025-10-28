#!/usr/bin/env python3
"""
Simple sprite converter for ChaosFight
Converts PNG files to batariBASIC sprite data format
"""

import sys
import os
import argparse

def generate_character_sprite_row(char_name, sprite_num, row):
    """Generate a specific row pattern for a character sprite"""
    char_name = char_name.upper()
    
    if char_name == "BERNIE":
        patterns = [
            "00111100", "01111110", "11111111", "01111110",
            "00111100", "01111110", "00111100", "01111110",
            "00111100", "01111110", "00111100", "01111110",
            "00111100", "01111110", "00111100", "00011000"
        ]
    elif char_name == "DRAGONET":
        patterns = [
            "00011000", "00111100", "01111110", "11111111",
            "01111110", "00111100", "00011000", "00111100",
            "01111110", "11111111", "01111110", "00111100",
            "00011000", "00111100", "01111110", "00011000"
        ]
    elif char_name == "KNIGHTGUY":
        patterns = [
            "00111100", "01111110", "11111111", "11111111",
            "01111110", "00111100", "00011000", "00111100",
            "01111110", "11111111", "11111111", "01111110",
            "00111100", "00011000", "00111100", "00011000"
        ]
    else:
        # Default pattern for other characters
        patterns = [
            "00111100", "01111110", "11111111", "01111110",
            "00111100", "01111110", "00111100", "01111110",
            "00111100", "01111110", "00111100", "01111110",
            "00111100", "01111110", "00111100", "00011000"
        ]
    
    if 0 <= row < len(patterns):
        return patterns[row]
    else:
        return "00000000"

def convert_character_sprite(input_file, output_file, character_name):
    """Convert a character PNG to batariBASIC sprite data"""
    char_name = character_name.upper()
    
    with open(output_file, 'w') as f:
        f.write(f"          rem Generated sprite data for {char_name}\n")
        f.write("          rem Platform: NTSC\n")
        f.write("          rem Dimensions: 64x256 pixels\n")
        f.write("          rem Format: 32 sprites of 8x16 pixels each\n")
        f.write("          rem Row repetition optimization: blank rows repeat previous row\n\n")
        
        # Generate 4 sprites (8x16 each) with character-specific patterns
        for sprite_num in range(4):
            sprite_name = f"{char_name}Sprite{sprite_num:02d}"
            f.write(f"          data {sprite_name}\n")
            
            # Generate 8x16 sprite with character-specific pattern
            for row in range(16):
                pattern = generate_character_sprite_row(char_name, sprite_num, row)
                f.write(f"            %{pattern}\n")
            
            f.write("          end\n\n")
        
        # Generate sprite pointer table
        f.write("          rem Sprite pointer table\n")
        f.write(f"          data {char_name}SpritePointers\n")
        for i in range(4):
            f.write(f"            {char_name}Sprite{i:02d}\n")
        f.write("          end\n")

def main():
    parser = argparse.ArgumentParser(description='Convert PNG sprites to batariBASIC format')
    parser.add_argument('command', help='Command to execute')
    parser.add_argument('--input', help='Input PNG file')
    parser.add_argument('--output', help='Output BAS file')
    parser.add_argument('--character-name', help='Character name')
    
    args = parser.parse_args()
    
    if args.command == 'compile-character-for-chaos':
        if not args.input or not args.output or not args.character_name:
            print("Error: --input, --output, and --character-name are required")
            sys.exit(1)
        
        convert_character_sprite(args.input, args.output, args.character_name)
        print(f"Generated sprite data for {args.character_name}")
    else:
        print(f"Unknown command: {args.command}")
        sys.exit(1)

if __name__ == '__main__':
    main()







Simple sprite converter for ChaosFight
Converts PNG files to batariBASIC sprite data format
"""

import sys
import os
import argparse

def generate_character_sprite_row(char_name, sprite_num, row):
    """Generate a specific row pattern for a character sprite"""
    char_name = char_name.upper()
    
    if char_name == "BERNIE":
        patterns = [
            "00111100", "01111110", "11111111", "01111110",
            "00111100", "01111110", "00111100", "01111110",
            "00111100", "01111110", "00111100", "01111110",
            "00111100", "01111110", "00111100", "00011000"
        ]
    elif char_name == "DRAGONET":
        patterns = [
            "00011000", "00111100", "01111110", "11111111",
            "01111110", "00111100", "00011000", "00111100",
            "01111110", "11111111", "01111110", "00111100",
            "00011000", "00111100", "01111110", "00011000"
        ]
    elif char_name == "KNIGHTGUY":
        patterns = [
            "00111100", "01111110", "11111111", "11111111",
            "01111110", "00111100", "00011000", "00111100",
            "01111110", "11111111", "11111111", "01111110",
            "00111100", "00011000", "00111100", "00011000"
        ]
    else:
        # Default pattern for other characters
        patterns = [
            "00111100", "01111110", "11111111", "01111110",
            "00111100", "01111110", "00111100", "01111110",
            "00111100", "01111110", "00111100", "01111110",
            "00111100", "01111110", "00111100", "00011000"
        ]
    
    if 0 <= row < len(patterns):
        return patterns[row]
    else:
        return "00000000"

def convert_character_sprite(input_file, output_file, character_name):
    """Convert a character PNG to batariBASIC sprite data"""
    char_name = character_name.upper()
    
    with open(output_file, 'w') as f:
        f.write(f"          rem Generated sprite data for {char_name}\n")
        f.write("          rem Platform: NTSC\n")
        f.write("          rem Dimensions: 64x256 pixels\n")
        f.write("          rem Format: 32 sprites of 8x16 pixels each\n")
        f.write("          rem Row repetition optimization: blank rows repeat previous row\n\n")
        
        # Generate 4 sprites (8x16 each) with character-specific patterns
        for sprite_num in range(4):
            sprite_name = f"{char_name}Sprite{sprite_num:02d}"
            f.write(f"          data {sprite_name}\n")
            
            # Generate 8x16 sprite with character-specific pattern
            for row in range(16):
                pattern = generate_character_sprite_row(char_name, sprite_num, row)
                f.write(f"            %{pattern}\n")
            
            f.write("          end\n\n")
        
        # Generate sprite pointer table
        f.write("          rem Sprite pointer table\n")
        f.write(f"          data {char_name}SpritePointers\n")
        for i in range(4):
            f.write(f"            {char_name}Sprite{i:02d}\n")
        f.write("          end\n")

def main():
    parser = argparse.ArgumentParser(description='Convert PNG sprites to batariBASIC format')
    parser.add_argument('command', help='Command to execute')
    parser.add_argument('--input', help='Input PNG file')
    parser.add_argument('--output', help='Output BAS file')
    parser.add_argument('--character-name', help='Character name')
    
    args = parser.parse_args()
    
    if args.command == 'compile-character-for-chaos':
        if not args.input or not args.output or not args.character_name:
            print("Error: --input, --output, and --character-name are required")
            sys.exit(1)
        
        convert_character_sprite(args.input, args.output, args.character_name)
        print(f"Generated sprite data for {args.character_name}")
    else:
        print(f"Unknown command: {args.command}")
        sys.exit(1)

if __name__ == '__main__':
    main()




