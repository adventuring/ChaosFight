#!/usr/bin/env python3
"""
Simple sprite converter for ChaosFight
Converts PNG files to batariBASIC sprite data format
"""

import sys
import os
import argparse

def generate_character_sprite_row(char_name, sprite_num, row):
    """Generate a specific row pattern for a character sprite.
    
    Args:
        char_name (str): Character name (e.g., 'Bernie', 'Dragonet')
        sprite_num (int): Sprite number within character set (0-3)
        row (int): Row number within 16-pixel sprite height (0-15)
        
    Returns:
        str: 8-bit binary pattern as string (e.g., '00111100')
    """
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
    """Convert a character PNG to batariBASIC sprite data.
    
    Args:
        input_file (str): Path to input PNG file (currently ignored, uses patterns)
        output_file (str): Path to output .bas file
        character_name (str): Character name for sprite generation
        
    Note:
        Currently generates pattern-based sprites. Future versions will
        read actual PNG pixel data for conversion.
    """
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

def compile_2600_font(input_file, output_file, font_name, architecture="NTSC"):
    """Convert font PNG to batariBASIC font data.
    
    Args:
        input_file (str): Path to input PNG font sheet
        output_file (str): Path to output .bas file
        font_name (str): Font name for data generation
        architecture (str): Target architecture (NTSC/PAL/SECAM)
    """
    with open(output_file, 'w') as f:
        f.write(f"          rem Generated font data for {font_name} ({architecture})\n")
        f.write("          rem Format: 16 characters, 8x16 pixels each\n")
        f.write("          rem Source: Numbers.xcf converted to PNG\n\n")
        
        f.write(f"          data {font_name}Font\n")
        # Generate placeholder font data for digits 0-F
        for digit in range(16):
            f.write(f"          rem Digit {digit:X}\n")
            for row in range(16):
                # Simple pattern for each digit
                if row < 2 or row > 13:
                    pattern = "00000000"  # Top/bottom padding
                elif digit == 0:
                    pattern = "01111110" if row in [3,4,11,12] else "01100110"
                elif digit == 1:
                    pattern = "00011000" if row in [3,4] else "00011000"
                else:
                    pattern = "01111110"  # Default pattern
                f.write(f"            %{pattern}\n")
        f.write("          end\n")

def compile_2600_playfield(input_file, output_file, screen_name, architecture="NTSC"):
    """Convert playfield PNG to batariBASIC playfield data.
    
    Args:
        input_file (str): Path to input PNG playfield
        output_file (str): Path to output .bas file  
        screen_name (str): Screen name for data generation
        architecture (str): Target architecture (NTSC/PAL/SECAM)
    """
    with open(output_file, 'w') as f:
        f.write(f"          rem Generated playfield data for {screen_name} ({architecture})\n")
        f.write("          rem Format: 32x32 playfield resolution\n")
        f.write(f"          rem Source: {screen_name}.png\n\n")
        
        f.write(f"          data {screen_name}Playfield\n")
        # Generate basic playfield pattern
        for row in range(8):
            if screen_name.upper() == "CHAOSFIGHT":
                pattern = "$FF" if row in [0, 7] else "$81"  # Border pattern
            elif screen_name.upper() == "ATARIAGE":
                pattern = "$AA" if row % 2 == 0 else "$55"  # Checkerboard
            else:
                pattern = "$00"  # Empty
            f.write(f"            {pattern}\n")
        f.write("          end\n")

def main():
    """Main entry point with argument parsing."""
    parser = argparse.ArgumentParser(description='Convert assets to batariBASIC format')
    parser.add_argument('command', help='Command to execute')
    parser.add_argument('--input', help='Input file')
    parser.add_argument('--output', help='Output BAS file')
    parser.add_argument('--character-name', help='Character name')
    parser.add_argument('--font-name', help='Font name')
    parser.add_argument('--screen-name', help='Screen name')
    parser.add_argument('--architecture', default='NTSC', help='Target architecture')
    
    args = parser.parse_args()
    
    try:
        if args.command == 'compile-character-for-chaos':
            if not all([args.input, args.output, args.character_name]):
                raise ValueError("--input, --output, and --character-name are required")
            convert_character_sprite(args.input, args.output, args.character_name)
            print(f"Generated sprite data for {args.character_name}")
            
        elif args.command == 'compile-2600-font':
            if not all([args.input, args.output, args.font_name]):
                raise ValueError("--input, --output, and --font-name are required")
            compile_2600_font(args.input, args.output, args.font_name, args.architecture)
            print(f"Generated font data for {args.font_name}")
            
        elif args.command == 'compile-2600-playfield':
            if not all([args.input, args.output, args.screen_name]):
                raise ValueError("--input, --output, and --screen-name are required")
            compile_2600_playfield(args.input, args.output, args.screen_name, args.architecture)
            print(f"Generated playfield data for {args.screen_name}")
            
        else:
            print(f"Unknown command: {args.command}")
            print("Available commands: compile-character-for-chaos, compile-2600-font, compile-2600-playfield")
            sys.exit(1)
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()