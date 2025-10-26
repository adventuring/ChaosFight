rem ===========================================================================
rem ChaosFight - Main Program
rem ===========================================================================
rem This is the main batariBASIC source file that compiles to the final ROM
rem
rem Target platforms: NTSC, PAL, SECAM
rem Output: ChaosFight.NTSC.a26, ChaosFight.PAL.a26, ChaosFight.SECAM.a26
rem ===========================================================================

rem Set compilation options
set tv ntsc
set romsize 4k
set optimization speed

rem Include the main bank
include "Source/Banks/Bank00.bas"

rem Main program entry point
rem The main game loop is defined in Bank00.bas

rem ===========================================================================
rem Compilation directives
rem ===========================================================================
rem These settings optimize for different TV standards

rem NTSC (default)
set tv ntsc
set romsize 4k

rem PAL
rem set tv pal
rem set romsize 4k

rem SECAM
rem set tv secam
rem set romsize 4k

rem ===========================================================================
rem Memory layout
rem ===========================================================================
rem Current: Bank 0 (4KB): Complete game logic
rem
rem Future expansion (F4 bank switching):
rem Bank 0 (4KB): Main game loop, title screen, game over
rem Bank 1 (4KB): Game playfield and collision detection
rem Bank 2 (4KB): Enemy AI and movement
rem Bank 3 (4KB): Player controls and physics
rem Bank 4 (4KB): Sound effects and music
rem Bank 5 (4KB): Graphics and sprite data
rem
rem Total: 4KB used, up to 32KB available with F4 bank switching
rem ===========================================================================

rem End of main program
