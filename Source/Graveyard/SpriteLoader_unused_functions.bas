          rem ChaosFight - Source/Graveyard/SpriteLoader_unused_functions.bas
          rem MOVED FROM: Source/Routines/SpriteLoader.bas
          rem DATE: 2025-01-XX
          rem REASON: Unused legacy functions, replaced by LoadPlayerSprite dispatcher
          
          rem =================================================================
          rem LOAD PLAYER SPRITES (legacy player-specific functions)
          rem =================================================================
          rem Load sprite data into specific player registers
          rem These functions contain the actual player graphics commands
          rem NOTE: Superseded by LoadPlayerSprite dispatcher with LoadPlayerSpriteDispatch
          
LoadPlayer0Sprite
          rem Use art location system for Participant 1 sprite loading (array [0] → P0 sprite)
          rem temp1 = character index, temp2 = animation frame already set
          let temp4 = 0 
          rem Participant 1 (array [0]) → P0 sprite (player0x/player0y)
          
          rem TODO: Replace with actual assembly when LocateCharacterArt and SetPlayer0CharacterArt are implemented
          rem For now, use placeholder sprite data
          return
          
LoadPlayer1Sprite
          rem Use art location system for Participant 2 sprite loading (array [1] → P1 sprite)
          rem temp1 = character index, temp2 = animation frame already set
          let temp4 = 1 
          rem Participant 2 (array [1]) → P1 sprite (player1x/player1y, virtual _P1)
          
          rem TODO: Replace with actual assembly when LocateCharacterArt and SetPlayer1CharacterArt are implemented
          rem For now, use placeholder sprite data
          return
          
LoadPlayer2Sprite
          rem Use art location system for Participant 3 sprite loading (array [2] → P2 sprite)
          rem temp1 = character index, temp2 = animation frame already set
          let temp4 = 2 
          rem Participant 3 (array [2]) → P2 sprite (player2x/player2y)
          
          rem TODO: Replace with actual assembly when LocateCharacterArt and SetPlayer2CharacterArt are implemented
          rem For now, use placeholder sprite data
          return
          
LoadPlayer3Sprite
          rem Use art location system for Participant 4 sprite loading (array [3] → P3 sprite)
          rem temp1 = character index, temp2 = animation frame already set
          let temp4 = 3 
          rem Participant 4 (array [3]) → P3 sprite (player3x/player3y)
          
          rem TODO: Replace with actual assembly when LocateCharacterArt and SetPlayer3CharacterArt are implemented
          rem For now, use placeholder sprite data
          return

