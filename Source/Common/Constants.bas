rem ===========================================================================
rem ChaosFight - Common Constants
rem ===========================================================================
rem This file contains all the constants used throughout the game
rem ===========================================================================

rem Game constants
const GAME_TITLE = "ChaosFight"
const VERSION = "1.0"

rem Screen dimensions
const ScreenWidth = 160
const ScreenHeight = 192
const PlayfieldWidth = 32

rem Player constants
const PlayerWidth = 8
const PlayerHeight = 8
const PlayerSpeed = 1

rem Enemy constants
const EnemyWidth = 8
const EnemyHeight = 8
const MaxEnemies = 4

rem Game states
const StateTitle = 0
const StatePlaying = 1
const StateGameOver = 2
const StatePaused = 3

rem Colors (NTSC)
const ColorPlayer = $1C
const ColorEnemy = $86
const ColorBackground = $00
const ColorPlayfield = $44

rem Sound constants
const SfxShoot = 0
const SfxHit = 1
const SfxExplode = 2
const SfxPickup = 3

rem Bank switching constants (F4 style, for future expansion)
const BankMain = 0
const BankGameplay = 1
const BankEnemy = 2
const BankPlayer = 3
const BankSound = 4
const BankGraphics = 5

rem Memory locations
const VarGameState = $80
const VarScore = $81
const VarLives = $82
const VarLevel = $83
const VarPlayerX = $84
const VarPlayerY = $85

rem End of constants
