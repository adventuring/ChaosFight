;;; ChaosFight - Source/Routines/CharacterSelectRender.bas
;;; Copyright © 2025 Bruce-Robert Pocock.

;;; Player preview coordinate tables
SelectPreviewX:
          .byte 56, 104, 56, 104

SelectPreviewY:
          .byte 40, 40, 80, 80

          ;; Player color tables for normal and handicap lock sta

SelectPlayerColorNormal:
          .byte 12, 12, 12, 12

SelectPlayerColorHandicap_data:
          ;; TODO: #1311 ColIndigo(6), ColRed(6), ColYellow(6), ColTurquoise(6)
SelectPlayerColorHandicap_end:
SelectPlayerColorHandicap = SelectPlayerColorHandicap_data


SelectDrawScreen .proc
          ;; Character Select drawing (sprites and HUD)
          ;; Returns: Far (return otherbank)
          ;; Shared preview renderer used by Character Select and Arena Select flows
          ;; Playfield layout is static; no runtime register writes
          lda # 2
          sta temp6
          ;; If controllerStatus & SetQuadtariDetected, set temp6 = 4
          lda controllerStatus
          and # SetQuadtariDetected
          beq SetPlayerCount
          lda # 4
          sta temp6
SetPlayerCount:
          lda # 0
          sta temp1

.pend

SelectDrawScreenLoop .proc
          jsr SelectRenderPlayerPreview
          inc temp1
          ;; if temp1 < temp6 then jmp SelectDrawScreenLoop
          lda temp1
          cmp temp6
          bcs SelectDrawScreenDone

          jmp SelectDrawScreenLoop

SelectDrawScreenDone:

          jmp BS_return

          ;; Cross-bank call to SelectHideLowerPlayerPreviews in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterSelectHideLowerPlayerPreviews-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterSelectHideLowerPlayerPreviews hi (encoded)]
          lda # <(AfterSelectHideLowerPlayerPreviews-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterSelectHideLowerPlayerPreviews hi (encoded)] [SP+0: AfterSelectHideLowerPlayerPreviews lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(SelectHideLowerPlayerPreviews-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterSelectHideLowerPlayerPreviews hi (encoded)] [SP+1: AfterSelectHideLowerPlayerPreviews lo] [SP+0: SelectHideLowerPlayerPreviews hi (raw)]
          lda # <(SelectHideLowerPlayerPreviews-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterSelectHideLowerPlayerPreviews hi (encoded)] [SP+2: AfterSelectHideLowerPlayerPreviews lo] [SP+1: SelectHideLowerPlayerPreviews hi (raw)] [SP+0: SelectHideLowerPlayerPreviews lo]
          ldx # 5
          jmp BS_jsr

AfterSelectHideLowerPlayerPreviews:

.pend

SelectRenderPlayerPreview .proc
          ;; Returns: Near (return thisbank)
          ;; Draw character preview for the specified player and apply lock tinting
          ;; Called same-bank from SelectDrawScreenLoop, so use return thisbank
          ;; Optimized: Combined duplicate conditionals, early return thisbank for common case
          ;; Cross-bank call to PlayerPreviewSetPosition in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterPlayerPreviewSetPosition-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterPlayerPreviewSetPosition hi (encoded)]
          lda # <(AfterPlayerPreviewSetPosition-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterPlayerPreviewSetPosition hi (encoded)] [SP+0: AfterPlayerPreviewSetPosition lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(PlayerPreviewSetPosition-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterPlayerPreviewSetPosition hi (encoded)] [SP+1: AfterPlayerPreviewSetPosition lo] [SP+0: PlayerPreviewSetPosition hi (raw)]
          lda # <(PlayerPreviewSetPosition-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterPlayerPreviewSetPosition hi (encoded)] [SP+2: AfterPlayerPreviewSetPosition lo] [SP+1: PlayerPreviewSetPosition hi (raw)] [SP+0: PlayerPreviewSetPosition lo]
          ldx # 5
          jmp BS_jsr
AfterPlayerPreviewSetPosition:


          ;; Same-bank call to RenderPlayerPreview (defined in this file)
          ;; Cross-bank call to RenderPlayerPreview (defined later in this file, same bank)
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterRenderPlayerPreview-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterRenderPlayerPreview hi (encoded)]
          lda # <(AfterRenderPlayerPreview-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterRenderPlayerPreview hi (encoded)] [SP+0: AfterRenderPlayerPreview lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(RenderPlayerPreview-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterRenderPlayerPreview hi (encoded)] [SP+1: AfterRenderPlayerPreview lo] [SP+0: RenderPlayerPreview hi (raw)]
          lda # <(RenderPlayerPreview-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterRenderPlayerPreview hi (encoded)] [SP+2: AfterRenderPlayerPreview lo] [SP+1: RenderPlayerPreview hi (raw)] [SP+0: RenderPlayerPreview lo]
          ldx # 5
          jmp BS_jsr
AfterRenderPlayerPreview:


          lda currentPlayer
          ;; Cross-bank call to GetPlayerLocked in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterGetPlayerLockedRender-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterGetPlayerLockedRender hi (encoded)]
          lda # <(AfterGetPlayerLockedRender-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterGetPlayerLockedRender hi (encoded)] [SP+0: AfterGetPlayerLockedRender lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(GetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterGetPlayerLockedRender hi (encoded)] [SP+1: AfterGetPlayerLockedRender lo] [SP+0: GetPlayerLocked hi (raw)]
          lda # <(GetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterGetPlayerLockedRender hi (encoded)] [SP+2: AfterGetPlayerLockedRender lo] [SP+1: GetPlayerLocked hi (raw)] [SP+0: GetPlayerLocked lo]
          ldx # 5
          jmp BS_jsr
AfterGetPlayerLockedRender:


          lda temp2
          sta temp5
          ;; Unlocked state (most common) - set color and return thisbank early
          jsr SelectSetPlayerColorUnlocked

          ;; Handicap state - set dimmed color and return thisbank
          jsr SelectSetPlayerColorHandicap

          ;; Normal locked state - color already set by RenderPlayerPreview
          rts
PlayerPreviewSetPosition
          ;; Returns: Far (return otherbank)
          ;; Position player preview sprites in the four select quadrants
          ;; Set temp2 = SelectPreviewX[temp1]
          lda temp1
          asl
          tax
          lda SelectPreviewX,x
          sta temp2
          ;; Set temp3 = SelectPreviewY[temp1]
          lda temp1
          asl
          tax
          lda SelectPreviewY,x
          sta temp3
          lda temp1
          asl
          tax
          lda SelectPreviewY,x
          sta temp3
          jsr SelectApplyPreviewPosition

SelectApplyPreviewPosition
          ;; Returns: Far (return thisbank)
          ;; Input: temp1 = player index, temp2 = X position, temp3 = y position
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectRenderPlayerPreview, so use return thisbank
          ;; Optimized: Use on...jmp jump table for O(1) dispatch
          jmp SelectApplyPreviewPositionP0
SelectApplyPreviewPositionP0
          lda temp2
          sta player0x
          lda temp3
          sta player0y
          jmp BS_return
SelectApplyPreviewPositionP1
          lda temp2
          sta player1x
          lda temp3
          sta player1y
          jmp BS_return
SelectApplyPreviewPositionP2
          lda temp2
          sta player2x
          lda temp3
          sta player2y
          jmp BS_return
SelectApplyPreviewPositionP3
          lda temp2
          sta player3x
          lda temp3
          sta player3y

.pend

SelectHideLowerPlayerPreviews .proc
          ;; Move lower-player previews off-screen when Quadtari is absent
          ;; Returns: Far (return otherbank)
          lda # 200
          sta player2y
          lda # 200
          sta player3y
.pend

RenderPlayerPreview .proc
          ;; Load preview sprite and base color for admin screens
          ;; Returns: Far (return otherbank)
          lda temp1
          sta currentPlayer
          ;; Set currentCharacter = playerCharacter[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda playerCharacter,x
          sta currentCharacter
          ;; if currentCharacter >= RandomCharacter then jmp RenderPlayerPreviewDefault
          lda currentCharacter
          cmp # RandomCharacter

          bcc GetAnimationFrame

          jmp RenderPlayerPreviewDefault

GetAnimationFrame:
          ;; Set temp4 = characterSelectPlayerAnimationFrame_R[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda characterSelectPlayerAnimationFrame_R,x
          sta temp4
          lda currentPlayer
          ;; Cross-bank call to GetPlayerLocked in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterGetPlayerLockedPreview-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterGetPlayerLockedPreview hi (encoded)]
          lda # <(AfterGetPlayerLockedPreview-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterGetPlayerLockedPreview hi (encoded)] [SP+0: AfterGetPlayerLockedPreview lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(GetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterGetPlayerLockedPreview hi (encoded)] [SP+1: AfterGetPlayerLockedPreview lo] [SP+0: GetPlayerLocked hi (raw)]
          lda # <(GetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterGetPlayerLockedPreview hi (encoded)] [SP+2: AfterGetPlayerLockedPreview lo] [SP+1: GetPlayerLocked hi (raw)] [SP+0: GetPlayerLocked lo]
          ldx # 5
          jmp BS_jsr
AfterGetPlayerLockedPreview:

          lda temp2
          sta temp5
          lda temp4
          sta temp2
          lda # ActionIdle
          sta temp3
          lda temp5
          cmp PlayerHandicapped
          bne RenderPlayerPreviewInvoke
          lda # ActionFallen
          sta temp3
RenderPlayerPreviewInvoke:

          jmp RenderPlayerPreviewInvoke
RenderPlayerPreviewDefault
          lda # 0
          sta temp2
          lda # ActionIdle
          sta temp3
          ;; Cross-bank call to LoadCharacterSprite in bank 15
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterLoadCharacterSpritePreview-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterLoadCharacterSpritePreview hi (encoded)]
          lda # <(AfterLoadCharacterSpritePreview-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterLoadCharacterSpritePreview hi (encoded)] [SP+0: AfterLoadCharacterSpritePreview lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(LoadCharacterSprite-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterLoadCharacterSpritePreview hi (encoded)] [SP+1: AfterLoadCharacterSpritePreview lo] [SP+0: LoadCharacterSprite hi (raw)]
          lda # <(LoadCharacterSprite-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterLoadCharacterSpritePreview hi (encoded)] [SP+2: AfterLoadCharacterSpritePreview lo] [SP+1: LoadCharacterSprite hi (raw)] [SP+0: LoadCharacterSprite lo]
          ldx # 15
          jmp BS_jsr
AfterLoadCharacterSpritePreview:

          ;; Set temp2 = SelectPlayerColorNormal[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda SelectPlayerColorNormal,x
          sta temp2
          jsr SelectApplyPlayerColor
          lda # 0
          sta temp2
          lda # 0
          sta temp3

.pend

SelectApplyPlayerColor .proc
          ;; Input: currentPlayer selects target register, temp2 = color value
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectSetPlayerColorUnlocked/Handicap, so use return thisbank
          ;; Optimized: Use on...jmp jump table for O(1) dispatch
          jmp SelectApplyPlayerColorP0
.pend

SelectApplyPlayerColorP0 .proc
          lda temp2
          sta COLUP0
          rts
.pend

SelectApplyPlayerColorP1 .proc
          lda temp2
          sta _COLUP1
          rts
.pend

SelectApplyPlayerColorP2 .proc
          lda temp2
          sta colup2
.pend

SelectApplyPlayerColorP3 .proc
          lda temp2
          sta colup3

.pend

SelectSetPlayerColorUnlocked .proc
          ;; Override sprite color to indicate unlocked state (white)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectRenderPlayerPreview, so use return thisbank
          lda # 14
          sta temp2
          jsr SelectApplyPlayerColor


.pend

SelectSetPlayerColorHandicap .proc

          ;; Override sprite color to indicate handicap lock (dim player color)
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectRenderPlayerPreview, so use return thisbank
          ;; Set temp2 = SelectPlayerColorHandicap[currentPlayer]
          lda currentPlayer
          asl
          tax
          lda SelectPlayerColorHandicap,x
          sta temp2


          ;; Returns: Far (return otherbank)
          ;; Update character select animations for all players
          ;; Returns: Far (return otherbank)
          ;; Optimized: Compact inline version to reduce code size
          lda # 2
          sta temp6
          ;; If controllerStatus & SetQuadtariDetected, set temp6 = 4
          lda controllerStatus
          and # SetQuadtariDetected
          beq SetPlayerCountCheck
          lda # 4
          sta temp6
SetPlayerCountCheck:
          lda # 0
          sta temp1
SelectUpdateAnimationLoop
          ;; Cross-bank call to GetPlayerLocked in bank 5
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterGetPlayerLockedAnimation-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterGetPlayerLockedAnimation hi (encoded)]
          lda # <(AfterGetPlayerLockedAnimation-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterGetPlayerLockedAnimation hi (encoded)] [SP+0: AfterGetPlayerLockedAnimation lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(GetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterGetPlayerLockedAnimation hi (encoded)] [SP+1: AfterGetPlayerLockedAnimation lo] [SP+0: GetPlayerLocked hi (raw)]
          lda # <(GetPlayerLocked-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterGetPlayerLockedAnimation hi (encoded)] [SP+2: AfterGetPlayerLockedAnimation lo] [SP+1: GetPlayerLocked hi (raw)] [SP+0: GetPlayerLocked lo]
          ldx # 5
          jmp BS_jsr
AfterGetPlayerLockedAnimation:

          ;; if temp2 then jmp SelectUpdateAnimationNext
          lda temp2
          beq UpdatePlayerAnimation
          jmp SelectUpdateAnimationNext
UpdatePlayerAnimation:
          ;; if playerCharacter[temp1] >= RandomCharacter then jmp SelectUpdateAnimationNext
          jsr SelectUpdatePlayerAnimation
SelectUpdateAnimationNext
          ;; if temp1 < temp6 then jmp SelectUpdateAnimationLoop
          lda temp1
          cmp temp6
          bcs SelectUpdateAnimationsDone
          jmp SelectUpdateAnimationLoop
SelectUpdateAnimationsDone:
          

SelectUpdatePlayerAnimation
          ;; Returns: Near (return thisbank)
          ;; Update character select animation counters for one player
          ;; Returns: Near (return thisbank)
          ;; Called same-bank from SelectUpdateAnimations, so use return thisbank
          ;;
          ;; Input: temp1 = player index (0-3)
          ;; characterSelectPlayerAnimationTimer_R[] = accumulated
          ;; output-frame counts
          ;; characterSelectPlayerAnimationFrame_R[] = sprite
          ;; frame index (0-7)
          ;;
          ;; Output: characterSelectPlayerAnimationFrame_W[temp1] advanced
          ;; when timer reaches AnimationFrameDelay
          ;;
          ;; Mutates: temp2, temp3, characterSelectPlayerAnimationTimer_W[],
          ;; characterSelectPlayerAnimationFrame_W[]
          ;;
          ;; Called Routines: None
          ;; Constraints: Admin-only usage sharing SCRAM with game mode
          ;; Set temp2 = characterSelectPlayerAnimationTimer_R[temp1] + 1
          lda temp1
          asl
          tax
          lda characterSelectPlayerAnimationTimer_R,x
          sta temp2
          lda temp1
          asl
          tax
          lda temp2
          sta characterSelectPlayerAnimationTimer_W,x

          lda temp1
          asl
          tax
          lda # 0
          sta characterSelectPlayerAnimationTimer_W,x
          ;; Set temp3 = (characterSelectPlayerAnimationFrame_R[temp1] + 1) & 7
          lda temp1
          asl
          tax
          lda temp3
          sta characterSelectPlayerAnimationFrame_W,x
          rts
          ;; Returns: Far (return otherbank)
          ;; Re-detect controllers on Select/Pause/ColorB&W toggle
          ;; Returns: Far (return otherbank)
          ;; if switchselect then jmp CharacterSelectDoRescan
          lda INPT4
          beq CheckColorBWToggle
          jmp CharacterSelectDoRescan
CheckColorBWToggle:
          lda switchbw
          sta temp6
          lda temp6
          cmp colorBWPrevious_R
          bne TriggerRescan
          jmp BS_return
TriggerRescan:

          ;; Cross-bank call to DetectPads in bank 12
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterDetectPadsColorBW-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterDetectPadsColorBW hi (encoded)]
          lda # <(AfterDetectPadsColorBW-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterDetectPadsColorBW hi (encoded)] [SP+0: AfterDetectPadsColorBW lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(DetectPads-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterDetectPadsColorBW hi (encoded)] [SP+1: AfterDetectPadsColorBW lo] [SP+0: DetectPads hi (raw)]
          lda # <(DetectPads-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterDetectPadsColorBW hi (encoded)] [SP+2: AfterDetectPadsColorBW lo] [SP+1: DetectPads hi (raw)] [SP+0: DetectPads lo]
          ldx # 12
          jmp BS_jsr
AfterDetectPadsColorBW:

          lda switchbw
          sta colorBWPrevious_W
          jmp BS_return
.pend

CharacterSelectDoRescan .proc
          ;; Cross-bank call to DetectPads in bank 12
          ;; Return address: ENCODED with caller bank 5 ($50) for BS_return to decode
          lda # ((>(AfterDetectPadsRescan-1)) & $0f) | $50  ;;; Encode bank 5 in high nybble
          pha
          ;; STACK PICTURE: [SP+0: AfterDetectPadsRescan hi (encoded)]
          lda # <(AfterDetectPadsRescan-1)
          pha
          ;; STACK PICTURE: [SP+1: AfterDetectPadsRescan hi (encoded)] [SP+0: AfterDetectPadsRescan lo]
          ;; Target address: RAW (for RTS to jump to) - NOT encoded
          lda # >(DetectPads-1)
          pha
          ;; STACK PICTURE: [SP+2: AfterDetectPadsRescan hi (encoded)] [SP+1: AfterDetectPadsRescan lo] [SP+0: DetectPads hi (raw)]
          lda # <(DetectPads-1)
          pha
          ;; STACK PICTURE: [SP+3: AfterDetectPadsRescan hi (encoded)] [SP+2: AfterDetectPadsRescan lo] [SP+1: DetectPads hi (raw)] [SP+0: DetectPads lo]
          ldx # 12
          jmp BS_jsr
AfterDetectPadsRescan:

CharacterSelectRescanDone:



.pend

