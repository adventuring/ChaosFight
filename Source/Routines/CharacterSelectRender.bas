          rem ChaosFight - Source/Routines/CharacterSelectRender.bas
          rem Copyright © 2025 Bruce-Robert Pocock.

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
          rem Returns: Far (return otherbank)
          asm
SelectDrawScreen
end
          rem Character Select drawing (sprites and HUD)
          rem Returns: Far (return otherbank)
          rem Shared preview renderer used by Character Select and Arena Select flows
          rem Playfield layout is static; no runtime register writes
          let temp6 = 2
          if controllerStatus & SetQuadtariDetected then let temp6 = 4
          let temp1 = 0
SelectDrawScreenLoop
          gosub SelectRenderPlayerPreview
          let temp1 = temp1 + 1
          if temp1 < temp6 then goto SelectDrawScreenLoop
          if temp6 = 4 then return otherbank
          gosub SelectHideLowerPlayerPreviews bank6
          return otherbank

SelectRenderPlayerPreview
          rem Returns: Far (return thisbank)
          asm
SelectRenderPlayerPreview
end
          rem Draw character preview for the specified player and apply lock tinting
          rem Returns: Near (return thisbank)
          rem Called same-bank from SelectDrawScreenLoop, so use return thisbank
          rem Optimized: Combined duplicate conditionals, early return thisbank for common case
          gosub PlayerPreviewSetPosition bank6
          gosub RenderPlayerPreview bank6
          let temp1 = currentPlayer
          gosub GetPlayerLocked bank6
          let temp5 = temp2
          rem Unlocked state (most common) - set color and return otherbank early
          if !temp5 then gosub SelectSetPlayerColorUnlocked : return otherbank
          rem Handicap state - set dimmed color and return otherbank
          if temp5 = PlayerHandicapped then gosub SelectSetPlayerColorHandicap : return otherbank
          rem Normal locked state - color already set by RenderPlayerPreview
          return otherbank
PlayerPreviewSetPosition
          rem Returns: Far (return otherbank)
          asm
PlayerPreviewSetPosition
end
          rem Position player preview sprites in the four select quadrants
          rem Returns: Far (return otherbank)
          let temp2 = SelectPreviewX[temp1]
          let temp3 = SelectPreviewY[temp1]
          gosub SelectApplyPreviewPosition
          return otherbank

SelectApplyPreviewPosition
          rem Returns: Far (return thisbank)
          asm
SelectApplyPreviewPosition
end
          rem Input: temp1 = player index, temp2 = x position, temp3 = y position
          rem Returns: Near (return thisbank)
          rem Called same-bank from SelectRenderPlayerPreview, so use return thisbank
          rem Optimized: Use on...goto jump table for O(1) dispatch
          on temp1 goto SelectApplyPreviewPositionP0 SelectApplyPreviewPositionP1 SelectApplyPreviewPositionP2 SelectApplyPreviewPositionP3
SelectApplyPreviewPositionP0
          player0x = temp2
          player0y = temp3
          return otherbank
SelectApplyPreviewPositionP1
          player1x = temp2
          player1y = temp3
          return otherbank
SelectApplyPreviewPositionP2
          player2x = temp2
          player2y = temp3
          return otherbank
SelectApplyPreviewPositionP3
          player3x = temp2
          player3y = temp3
          return otherbank

SelectHideLowerPlayerPreviews
          rem Returns: Far (return otherbank)
          asm
SelectHideLowerPlayerPreviews
end
          rem Move lower-player previews off-screen when Quadtari is absent
          rem Returns: Far (return otherbank)
          player2y = 200
          player3y = 200
          return otherbank

RenderPlayerPreview
          rem Returns: Far (return otherbank)
          asm
RenderPlayerPreview
end
          rem Load preview sprite and base color for admin screens
          rem Returns: Far (return otherbank)
          let currentPlayer = temp1
          let currentCharacter = playerCharacter[currentPlayer]
          if currentCharacter >= RandomCharacter then goto RenderPlayerPreviewDefault
          let temp4 = characterSelectPlayerAnimationFrame_R[currentPlayer]
          let temp1 = currentPlayer
          gosub GetPlayerLocked bank6
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
          return otherbank

SelectApplyPlayerColor
          rem Returns: Far (return thisbank)
          asm
SelectApplyPlayerColor
end
          rem Input: currentPlayer selects target register, temp2 = color value
          rem Returns: Near (return thisbank)
          rem Called same-bank from SelectSetPlayerColorUnlocked/Handicap, so use return thisbank
          rem Optimized: Use on...goto jump table for O(1) dispatch
          on currentPlayer goto SelectApplyPlayerColorP0 SelectApplyPlayerColorP1 SelectApplyPlayerColorP2 SelectApplyPlayerColorP3
SelectApplyPlayerColorP0
          COLUP0 = temp2
          return thisbank
SelectApplyPlayerColorP1
          _COLUP1 = temp2
          return thisbank
SelectApplyPlayerColorP2
          COLUP2 = temp2
          return thisbank
SelectApplyPlayerColorP3
          COLUP3 = temp2
          return thisbank

SelectSetPlayerColorUnlocked
          rem Returns: Far (return thisbank)
          asm
SelectSetPlayerColorUnlocked
end
          rem Override sprite color to indicate unlocked state (white)
          rem Returns: Near (return thisbank)
          rem Called same-bank from SelectRenderPlayerPreview, so use return thisbank
          let temp2 = ColGrey(14)
          gosub SelectApplyPlayerColor
          return otherbank

SelectSetPlayerColorHandicap
          rem Returns: Far (return thisbank)
          asm
SelectSetPlayerColorHandicap

end
          rem Override sprite color to indicate handicap lock (dim player color)
          rem Returns: Far (return otherbank)
          let temp2 = SelectPlayerColorHandicap[currentPlayer]
          gosub SelectApplyPlayerColor
          return otherbank

SelectUpdateAnimations
          rem Returns: Far (return otherbank)
          asm
SelectUpdateAnimations
end
          rem Update character select animations for all players
          rem Returns: Far (return otherbank)
          rem Optimized: Compact inline version to reduce code size
          let temp6 = 2
          if controllerStatus & SetQuadtariDetected then let temp6 = 4
          let temp1 = 0
SelectUpdateAnimationLoop
          gosub GetPlayerLocked bank6
          if temp2 then goto SelectUpdateAnimationNext
          if playerCharacter[temp1] >= RandomCharacter then goto SelectUpdateAnimationNext
          gosub SelectUpdatePlayerAnimation
SelectUpdateAnimationNext
          let temp1 = temp1 + 1
          if temp1 < temp6 then goto SelectUpdateAnimationLoop
          return thisbank

SelectUpdatePlayerAnimation
          rem Returns: Far (return thisbank)
          asm
SelectUpdatePlayerAnimation

end
          rem Update character select animation counters for one player
          rem Returns: Near (return thisbank)
          rem Called same-bank from SelectUpdateAnimations, so use return thisbank
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
          if temp2 < AnimationFrameDelay then return otherbank
          let characterSelectPlayerAnimationTimer_W[temp1] = 0
          let temp3 = (characterSelectPlayerAnimationFrame_R[temp1] + 1) & 7
          let characterSelectPlayerAnimationFrame_W[temp1] = temp3
          return otherbank
CharacterSelectCheckControllerRescan
          rem Returns: Far (return otherbank)
          asm
CharacterSelectCheckControllerRescan
end
          rem Re-detect controllers on Select/Pause/ColorB&W toggle
          rem Returns: Far (return otherbank)
          if switchselect then goto CharacterSelectDoRescan
          let temp6 = switchbw
          if temp6 = colorBWPrevious_R then goto CharacterSelectRescanDone
          gosub DetectPads bank13
          let colorBWPrevious_W = switchbw
          goto CharacterSelectRescanDone
CharacterSelectDoRescan
          gosub DetectPads bank13
CharacterSelectRescanDone
          return thisbank


