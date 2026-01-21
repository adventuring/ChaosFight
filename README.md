# 6502 Bank Switching System

This is a 16-bank memory management system for 6502 processors.

## Features:
- Supports 16 banks (0-15)
- Fast switching with jump table
- Cold and warm start vectors
- Stack-based bank information extraction
- Header with metadata

## Memory Map:
- $0000-$000F: Header
- $FFF0-$FF7F: Bank switching routines
- $FF80-$FF9F: Jump table
- $FFFC-$FFFE: Reset vectors
- $0000-$FFFF: Bank entry points

## Building:
1. Assemble with ca65
2. Link with ld65
3. Or use an alternative 6502 assembler

## Banks:
- Bank 12: ColdStart
- Bank 13: WarmStart
- Banks 0-15: Entry points for program code
