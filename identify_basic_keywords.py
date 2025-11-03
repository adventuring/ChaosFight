#!/usr/bin/env python3
"""Identify and document all batariBASIC keywords from source code."""

# Keywords extracted from Tools/batariBASIC/keywords.c

KEYWORDS = {
    # Control flow
    'if', 'then', 'else', 'goto', 'gosub', 'return', 'for', 'next', 'on',
    
    # Declarations
    'dim', 'const', 'set', 'autodim',
    
    # Code blocks
    'asm', 'end', 'rem', 'def', 'function',
    
    # Bank switching
    'bank',
    
    # Data
    'data', 'sdata',
    
    # Includes
    'includesfile', 'include', 'inline',
    
    # Playfield
    'playfield', 'pfpixel', 'pfhline', 'pfclear', 'pfvline', 'pfscroll',
    
    # Colors
    'pfcolors', 'pfheights', 'bkcolors', 'scorecolors',
    
    # Drawing/display
    'drawscreen', 'lives', 'vblank', 'reboot',
    
    # Operators
    'dec', 'let',
    
    # Increment/decrement (++ and --)
    # Note: These are operators, not keywords, but should be preserved
    
    # Macros
    'macro', 'callmacro', 'extra', 'push', 'pull', 'pop', 'stack',
    
    # System
    'rerand',
}

# System variables from Tools/batariBASIC/includes/2600basic.h
SYSTEM_VARIABLES = {
    # Player/Missile positions
    'player0x', 'player0y', 'player1x', 'player1y',
    'missile0x', 'missile0y', 'missile1x', 'missile1y',
    'ballx', 'bally', 'objecty',
    
    # Player pointers
    'player0pointer', 'player0pointerlo', 'player0pointerhi',
    'player1pointer', 'player1pointerlo', 'player1pointerhi',
    
    # Heights
    'player0height', 'player1height', 'missile0height', 'missile1height',
    'ballheight',
    
    # Colors
    'player0color', 'player1color', 'player0colorstore',
    
    # Paddle
    'currentpaddle', 'paddle',
    
    # Score
    'score', 'scorecolor', 'scorepointers',
    
    # Built-in temporaries
    'temp1', 'temp2', 'temp3', 'temp4', 'temp5', 'temp6',
    
    # System
    'rand', 'frame', 'qtcontroller',
    
    # Variables (var0-var95)
    # Note: var0-var95 are system variables
    # Note: a-z, A-Z single letters are system variables
    
    # TIA registers (all caps patterns)
    # COLUP0-COLUPF, COLUBK, NUSIZ0-NUSIZF, etc.
    # These are matched by pattern, not explicit list
}

# TIA register patterns (for matching)
TIA_REGISTER_PATTERNS = [
    'COLUP[0-9A-F]', 'COLUPF', 'COLUBK',
    'NUSIZ[0-9A-F]', 'NUSIZF',
    'RESP[0-9A-F]', 'RESMP[0-9A-F]',
    'HMOVE', 'HMM[0-9A-F]',
    'VDEL[0-9A-F]',
    'GRP[0-9A-F]',
    'ENAM[0-9A-F]', 'ENABL',
    'PF[0-2]', 'CTRLPF',
    'REFP[0-9A-F]',
    'AUDF[0-9A-F]', 'AUDC[0-9A-F]', 'AUDV[0-9A-F]',
]

# Player declarations (player0:, player1:, etc. through player16:)
PLAYER_DECLARATIONS = [f'player{i}:' for i in range(17)]
PLAYER_COLOR_DECLARATIONS = [f'player{i}color:' for i in range(17)]

def main():
    print("batariBASIC Keywords and System Variables")
    print("=" * 50)
    print()
    
    print("KEYWORDS:")
    print("-" * 50)
    print("Control Flow:")
    print("  if, then, else, goto, gosub, return, for, next, on")
    print()
    print("Declarations:")
    print("  dim, const, set, autodim")
    print()
    print("Code Blocks:")
    print("  asm, end, rem, def, function")
    print()
    print("Bank Switching:")
    print("  bank")
    print()
    print("Data:")
    print("  data, sdata")
    print()
    print("Includes:")
    print("  includesfile, include, inline")
    print()
    print("Playfield:")
    print("  playfield, pfpixel, pfhline, pfclear, pfvline, pfscroll")
    print()
    print("Colors:")
    print("  pfcolors, pfheights, bkcolors, scorecolors")
    print()
    print("Drawing/Display:")
    print("  drawscreen, lives, vblank, reboot")
    print()
    print("Operators:")
    print("  dec, let")
    print()
    print("Macros:")
    print("  macro, callmacro, extra, push, pull, pop, stack")
    print()
    print("System:")
    print("  rerand")
    print()
    
    print("SYSTEM VARIABLES:")
    print("-" * 50)
    print("Player/Missile Positions:")
    print("  player0x, player0y, player1x, player1y")
    print("  missile0x, missile0y, missile1x, missile1y")
    print("  ballx, bally, objecty")
    print()
    print("Player Pointers:")
    print("  player0pointer, player0pointerlo, player0pointerhi")
    print("  player1pointer, player1pointerlo, player1pointerhi")
    print()
    print("Heights:")
    print("  player0height, player1height, missile0height, missile1height, ballheight")
    print()
    print("Colors:")
    print("  player0color, player1color, player0colorstore")
    print()
    print("Paddle:")
    print("  currentpaddle, paddle")
    print()
    print("Score:")
    print("  score, scorecolor, scorepointers")
    print()
    print("Built-in Temporaries:")
    print("  temp1, temp2, temp3, temp4, temp5, temp6")
    print()
    print("System:")
    print("  rand, frame, qtcontroller")
    print()
    print("Standard Variables:")
    print("  var0-var95 (48 bytes)")
    print("  a-z, A-Z (single letters, 26 bytes)")
    print()
    print("TIA Registers (all caps patterns):")
    print("  " + ", ".join(TIA_REGISTER_PATTERNS[:10]))
    print("  (and more... see includes/2600basic.h)")
    print()
    print("Player Declarations:")
    print("  player0: through player16:")
    print("  player0color: through player16color:")
    print()
    
    print("SUMMARY:")
    print("-" * 50)
    print(f"Total Keywords: {len(KEYWORDS)}")
    print(f"Total System Variables (explicit): {len(SYSTEM_VARIABLES)}")
    print()
    print("These keywords and system variables should be preserved")
    print("when converting labels to PascalCase (lowercase preserved).")

if __name__ == '__main__':
    main()

