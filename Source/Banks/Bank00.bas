rem ===========================================================================
rem ChaosFight - Bank 00 (Main Bank)
rem ===========================================================================
rem This is the main bank (4kiB) that contains the complete game logic
rem for the ChaosFight Atari 2600 game.
rem
rem Current game features:
rem - Two-player collision detection
rem - Boundary checking
rem - Basic movement controls
rem ===========================================================================

rem Include common constants and macros
include "Source/Common/Constants.bas"
include "Source/Common/Macros.bas"

rem Set ROM size (4k for current single-bank game)
set romsize 4k

rem Main game initialization
gosub InitializeGame

rem Main game loop
MainGameLoop

rem Game over - return to title
goto MainGameLoop

rem ===========================================================================
rem Subroutines
rem ===========================================================================

InitializeGame
rem Initialize game variables and setup
COLUP0 = ColorPlayer
COLUP1 = ColorEnemy
COLUPF = ColorPlayfield
COLUBK = ColorBackground

rem Set up player sprite
player0x = 80
player0y = 50
player1x = 20
player1y = 50

rem Initialize game state variables
lives = 3
score = 0
game_state = StatePlaying

return

rem ===========================================================================
rem Game mechanics
rem ===========================================================================

UpdateGameplay
rem Main gameplay update loop

rem Check for collisions
if collision(player0, player1) then gosub HandleCollision

rem Update player positions
gosub UpdatePlayerPositions

rem Check boundaries
gosub CheckBoundaries

return

HandleCollision
rem Handle player-enemy collisions
lives = lives - 1
if lives <= 0 then game_state = StateGameOver
return

UpdatePlayerPositions
rem Update player movement based on input
if joy0left then player0x = player0x - PlayerSpeed
if joy0right then player0x = player0x + PlayerSpeed
if joy0up then player0y = player0y - PlayerSpeed
if joy0down then player0y = player0y + PlayerSpeed
return

CheckBoundaries
rem Keep players within screen bounds
clamp player0x, 1, ScreenWidth - PlayerWidth - 1
clamp player0y, 1, ScreenHeight - PlayerHeight - 1
return

rem End of Bank 00
