          rem ChaosFight - Source/Routines/DisplayHealth.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

DisplayHealth
          rem
          rem Display Health
          rem Shows health status for all active players.
          rem Flashes sprites when health is critically low.
          rem Shows health status for all active players by flashing
          rem sprites when health is critically low
          rem
          rem Input: playerHealth[] (global array) = player health
          rem values, playerRecoveryFrames[] (global array) = recovery
          rem frame counts, controllerStatus (global) = controller
          rem state, playerCharacter[] (global array) = selections,
          rem frame (global) = frame counter
          rem
          rem Output: Sprites flashed (hidden) when health < 25 and not
          rem in recovery
          rem
          rem Mutates: player0x, player1x, player2x, player3x (TIA
          rem registers) = sprite positions (set to 200 to hide when
          rem flashing)
          rem
          rem Called Routines: None
          rem
          rem Constraints: Only flashes when health < 25 and not in
          rem recovery. Players 3/4 only checked if Quadtari detected
          rem and selected
          rem Flash Participant 1 sprite (array [0], P0) if health is
          rem   low (but not during recovery)
          rem Use skip-over pattern to avoid complex || operator
          if playerHealth[0] >= 25 then goto DoneParticipant1Flash
          if playerRecoveryFrames[0] = 0 then FlashParticipant1
          goto DoneParticipant1Flash
FlashParticipant1
          if frame & 8 then player0x = 200
DoneParticipant1Flash
          rem Hide P0 sprite

          rem Flash Participant 2 sprite (array [1], P1) if health is
          rem   low
          rem Use skip-over pattern to avoid complex || operator
          if playerHealth[1] >= 25 then goto DoneParticipant2Flash
          if playerRecoveryFrames[1] = 0 then FlashParticipant2
          goto DoneParticipant2Flash
FlashParticipant2
          if frame & 8 then player1x = 200
DoneParticipant2Flash

          rem Flash Player 3 sprite if health is low (but alive)

          if (controllerStatus & SetQuadtariDetected) = 0 then goto DonePlayer3Flash
          if playerCharacter[2] = NoCharacter then goto DonePlayer3Flash
          if ! playerHealth[2] then goto DonePlayer3Flash
          if playerHealth[2] >= 25 then goto DonePlayer3Flash
          if playerRecoveryFrames[2] = 0 then FlashPlayer3
          goto DonePlayer3Flash
FlashPlayer3
          if frame & 8 then player2x = 200
DonePlayer3Flash
          rem Player 3 uses player2 sprite

          rem Flash Player 4 sprite if health is low (but alive)

          if (controllerStatus & SetQuadtariDetected) = 0 then goto DonePlayer4Flash
          if playerCharacter[3] = NoCharacter then goto DonePlayer4Flash
          if ! playerHealth[3] then goto DonePlayer4Flash
          if playerHealth[3] >= 25 then goto DonePlayer4Flash
          if playerRecoveryFrames[3] = 0 then FlashPlayer4
          goto DonePlayer4Flash
FlashPlayer4
          if frame & 8 then player3x = 200
DonePlayer4Flash
          rem Player 4 uses player3 sprite

          return

