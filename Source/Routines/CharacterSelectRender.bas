          rem ChaosFight - Source/Routines/CharacterSelectRender.bas
          rem Copyright © 2025 Interworldly Adventuring, LLC.

          rem Player preview coordinate tables
          data SelectPreviewX
            56, 104, 56, 104
end

          data SelectPreviewY
            40, 40, 80, 80
end

          rem Player color tables for normal and handicap lock states
          data SelectPlayerColorNormal
            ColIndigo(12), ColRed(12), ColYellow(12), ColTurquoise(12)
end

          data SelectPlayerColorHandicap
            ColIndigo(6), ColRed(6), ColYellow(6), ColTurquoise(6)
end

SelectDrawScreen
          asm
SelectDrawScreen

end
          rem Character Select drawing (sprites and HUD)
          rem Shared preview renderer used by Character Select and Arena Select flows
          rem Playfield layout is static; no runtime register writes
          let temp1 = 0
          gosub SelectRenderPlayerPreview
          let temp1 = 1
          gosub SelectRenderPlayerPreview
          if controllerStatus & SetQuadtariDetected then goto SelectDrawLowerPlayers
          gosub SelectHideLowerPlayerPreviews
          goto SelectDrawScreenDone
SelectDrawLowerPlayers
          let temp1 = 2
          gosub SelectRenderPlayerPreview
          let temp1 = 3
          gosub SelectRenderPlayerPreview
SelectDrawScreenDone
          return

SelectRenderPlayerPreview
          asm
SelectRenderPlayerPreview

end
          rem Draw character preview for the specified player and apply lock tinting
          rem Optimized: Combined duplicate conditionals, early return for common case
          gosub PlayerPreviewSetPosition
          gosub RenderPlayerPreview
          let temp1 = currentPlayer
          gosub GetPlayerLocked
          let temp5 = temp2
          if !temp5 then gosub SelectSetPlayerColorUnlocked : return
          rem Unlocked state (most common) - set color and return early
          if temp5 = PlayerHandicapped then gosub SelectSetPlayerColorHandicap : return
          rem Handicap state - set dimmed color and return
          rem Normal locked state - color already set by RenderPlayerPreview
          return

PlayerPreviewSetPosition
          asm
PlayerPreviewSetPosition
end
          rem Position player preview sprites in the four select quadrants
          let temp2 = SelectPreviewX[temp1]
          let temp3 = SelectPreviewY[temp1]
          gosub SelectApplyPreviewPosition
          return

SelectApplyPreviewPosition
          asm
SelectApplyPreviewPosition
end
          rem Input: temp1 = player index, temp2 = x position, temp3 = y position
          rem Optimized: Use on...goto jump table for O(1) dispatch
          on temp1 goto SelectApplyPreviewPositionP0 SelectApplyPreviewPositionP1 SelectApplyPreviewPositionP2 SelectApplyPreviewPositionP3
SelectApplyPreviewPositionP0
          player0x = temp2
          player0y = temp3
          return
SelectApplyPreviewPositionP1
          player1x = temp2
          player1y = temp3
          return
SelectApplyPreviewPositionP2
          player2x = temp2
          player2y = temp3
          return
SelectApplyPreviewPositionP3
          player3x = temp2
          player3y = temp3
          return

SelectHideLowerPlayerPreviews
          asm
SelectHideLowerPlayerPreviews
end
          rem Move lower-player previews off-screen when Quadtari is absent
          player2y = 200
          player3y = 200
          return

RenderPlayerPreview
          asm
RenderPlayerPreview
end
          rem Load preview sprite and base color for admin screens
          let currentPlayer = temp1
          let currentCharacter = playerCharacter[currentPlayer]
          if currentCharacter >= RandomCharacter then goto RenderPlayerPreviewDefault
          let temp4 = characterSelectPlayerAnimationFrame_R[currentPlayer]
          let temp1 = currentPlayer
          gosub GetPlayerLocked
          let temp5 = temp2
          let temp2 = temp4
          let temp3 = ActionIdle
          if temp5 = PlayerHandicapped then temp3 = ActionFallen
          goto RenderPlayerPreviewInvoke
RenderPlayerPreviewDefault
          let temp2 = 0
          let temp3 = ActionIdle
RenderPlayerPreviewInvoke
          gosub LoadCharacterSprite bank16
          let temp2 = SelectPlayerColorNormal[currentPlayer]
          gosub SelectApplyPlayerColor
          let temp2 = 0
          let temp3 = 0
          return

SelectApplyPlayerColor
          asm
SelectApplyPlayerColor
end
          rem Input: currentPlayer selects target register, temp2 = color value
          rem Optimized: Use on...goto jump table for O(1) dispatch
          on currentPlayer goto SelectApplyPlayerColorP0 SelectApplyPlayerColorP1 SelectApplyPlayerColorP2 SelectApplyPlayerColorP3
SelectApplyPlayerColorP0
          COLUP0 = temp2
          return
SelectApplyPlayerColorP1
          _COLUP1 = temp2
          return
SelectApplyPlayerColorP2
          COLUP2 = temp2
          return
SelectApplyPlayerColorP3
          COLUP3 = temp2
          return

SelectSetPlayerColorUnlocked
          asm
SelectSetPlayerColorUnlocked
end
          rem Override sprite color to indicate unlocked state (white)
          let temp2 = ColGrey(14)
          gosub SelectApplyPlayerColor
          return

SelectSetPlayerColorHandicap
          asm
SelectSetPlayerColorHandicap

end
          rem Override sprite color to indicate handicap lock (dim player color)
          let temp2 = SelectPlayerColorHandicap[currentPlayer]
          gosub SelectApplyPlayerColor
          return

SelectUpdateAnimations
          asm
SelectUpdateAnimations
end
          rem Update character select animations for all players
          rem Optimized: Compact inline version to reduce code size
          let temp1 = 0 : gosub GetPlayerLocked : if temp2 then goto SelectDonePlayer0Animation
          if playerCharacter[0] >= RandomCharacter then goto SelectDonePlayer0Animation
          let temp1 = 0 : gosub SelectUpdatePlayerAnimation
SelectDonePlayer0Animation
          let temp1 = 1 : gosub GetPlayerLocked : if temp2 then goto SelectDonePlayer1Animation
          if playerCharacter[1] >= RandomCharacter then goto SelectDonePlayer1Animation
          let temp1 = 1 : gosub SelectUpdatePlayerAnimation
SelectDonePlayer1Animation
          if controllerStatus & SetQuadtariDetected then goto ProcessPlayer2Animation
          goto SelectDonePlayer23Animation
ProcessPlayer2Animation
          let temp1 = 2 : gosub GetPlayerLocked : if temp2 then goto SelectDonePlayer2Animation
          if playerCharacter[2] >= RandomCharacter then goto SelectDonePlayer2Animation
          let temp1 = 2 : gosub SelectUpdatePlayerAnimation
SelectDonePlayer2Animation
          if controllerStatus & SetQuadtariDetected then goto ProcessPlayer3Animation
          goto SelectDonePlayer23Animation
ProcessPlayer3Animation
          let temp1 = 3 : gosub GetPlayerLocked : if temp2 then goto SelectDonePlayer23Animation
          if playerCharacter[3] >= RandomCharacter then goto SelectDonePlayer23Animation
          let temp1 = 3 : gosub SelectUpdatePlayerAnimation
SelectDonePlayer23Animation
          return

SelectUpdatePlayerAnimation
          asm
SelectUpdatePlayerAnimation

end
          rem Update character select animation counters for one player
          rem
          rem Input: temp1 = player index (0-3)
          rem        characterSelectPlayerAnimationTimer_R[] = accumulated
          rem        output-frame counts
          rem        characterSelectPlayerAnimationFrame_R[] = sprite
          rem        frame index (0-7)
          rem
          rem Output: characterSelectPlayerAnimationFrame_W[temp1] advanced
          rem        when timer reaches AnimationFrameDelay
          rem
          rem Mutates: temp2, temp3, characterSelectPlayerAnimationTimer_W[],
          rem        characterSelectPlayerAnimationFrame_W[]
          rem
          rem Called Routines: None
          rem Constraints: Admin-only usage sharing SCRAM with game mode
          let temp2 = characterSelectPlayerAnimationTimer_R[temp1] + 1
          let characterSelectPlayerAnimationTimer_W[temp1] = temp2
          if temp2 < AnimationFrameDelay then return
          let characterSelectPlayerAnimationTimer_W[temp1] = 0
          let temp3 = (characterSelectPlayerAnimationFrame_R[temp1] + 1) & 7
          let characterSelectPlayerAnimationFrame_W[temp1] = temp3
          return

CharacterSelectCheckControllerRescan
          asm
CharacterSelectCheckControllerRescan
end
          rem Re-detect controllers on Select/Pause/ColorB&W toggle
          if switchselect then goto CharacterSelectDoRescan
          let temp6 = switchbw
          if temp6 = colorBWPrevious_R then goto CharacterSelectRescanDone
          gosub DetectPads bank13
          let colorBWPrevious_W = switchbw
          goto CharacterSelectRescanDone
CharacterSelectDoRescan
          gosub DetectPads bank13
CharacterSelectRescanDone
          return


