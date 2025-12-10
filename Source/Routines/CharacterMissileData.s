;;; ChaosFight - Source/Routines/CharacterMissileData.bas
;;; Copyright © 2025 Bruce-Robert Pocock.
;;; Character Missile Data Lookup Routines
;;; Provides O(1) lookups for character missile and weight properties.
          ;;
          ;; All character data is defined in CharacterMissileTables.bas and
          ;; accessed through these optimized lookup routines.


GetCharacterWeightValue .proc
          Return the character’s weight.
          ;; Input: temp1 = character index (0-MaxCharacter)
          ;; Output: temp2 = character weight
          ;; Mutates: temp2 (return value)
          ;; Constraints: None
          ;; Use direct array access for O(1) lookup
          ;; let temp2 = CharacterWeights[temp1]         
          lda temp1
          asl
          tax
          lda CharacterWeights,x
          sta temp2
          rts
.pend

GetCharacterMissileHeight .proc
          Return missile height slot (0 = none, 1-2 = height).
          ;; Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileHeights lookup)
          ;; Output: temp2 = missile height slot
          ;; Mutates: temp2 (result register - missile height slot)
          ;; Constraints: None (table lookup - missile height)
          ;; Use direct array access for O(1) lookup
          ;; let temp2 = CharacterMissileHeights[temp1]         
          lda temp1
          asl
          tax
          lda CharacterMissileHeights,x
          sta temp2
          rts
.pend

GetCharacterMissileMaxX .proc
          Return missile maximum × range.
          ;; Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileMaxX lookup)
          ;; Output: temp2 = missile max × range
          ;; Mutates: temp2 (result register - missile max X)
          ;; Constraints: None (table lookup - missile max X)
          ;; Use direct array access for O(1) lookup
          ;; let temp2 = CharacterMissileMaxX[temp1]         
          lda temp1
          asl
          tax
          lda CharacterMissileMaxX,x
          sta temp2
          rts
.pend

GetCharacterMissileMaxY .proc
          Return missile maximum Y range.
          ;; Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileMaxY lookup)
          ;; Output: temp2 = missile max Y range
          ;; Mutates: temp2 (result register - missile max Y)
          ;; Constraints: None (table lookup - missile max Y)
          ;; Use direct array access for O(1) lookup
          ;; let temp2 = CharacterMissileMaxY[temp1]         
          lda temp1
          asl
          tax
          lda CharacterMissileMaxY,x
          sta temp2
          rts
.pend

GetMissileWidth .proc
          Return missile width (stub - use CharacterMissileWidths[] directly)
          ;; Input: temp1 = character index (0-MaxCharacter)
          ;; Output: temp2 = missile width
          ;; Mutates: temp2 (return value)
          ;; Constraints: None (table lookup - missile width)
          ;; Use direct array access for O(1) lookup
          ;; let temp2 = CharacterMissileWidths[temp1]         
          lda temp1
          asl
          tax
          lda CharacterMissileWidths,x
          sta temp2
          rts
.pend

GetMissileHeight .proc
          Return missile height (stub - use CharacterMissileHeights[] directly)
          ;; Input: temp1 = character index (0-MaxCharacter)
          ;; Output: temp2 = missile height
          ;; Mutates: temp2 (return value)
          ;; Constraints: None (table lookup - missile height)
          ;; Use direct array access for O(1) lookup
          ;; let temp2 = CharacterMissileHeights[temp1]         
          lda temp1
          asl
          tax
          lda CharacterMissileHeights,x
          sta temp2
          rts
.pend

GetMissileFlags .proc
          Return missile flags (stub - use CharacterMissileFlags[] directly)
          ;; Input: temp1 = character index (0-MaxCharacter)
          ;; Output: temp2 = missile flags
          ;; Mutates: temp2 (return value)
          ;; Constraints: None (table lookup - missile flags)
          ;; Use direct array access for O(1) lookup
          ;; let temp2 = CharacterMissileFlags[temp1]         
          lda temp1
          asl
          tax
          lda CharacterMissileFlags,x
          sta temp2
          rts
.pend

GetMissileMomentumX .proc
          Return missile horizontal momentum from CharacterMissileMomentumX[temp1].
          ;; Parameters: temp1 = character index (0-MaxCharacter, CharacterMissileMomentumY lookup)
          ;; Output: temp2 = missile momentum X
          ;; Mutates: temp2 (return value - missile momentum X)
          ;; Constraints: None (table lookup - missile momentum X)
          ;; let temp2 = CharacterMissileMomentumX[temp1]         
          lda temp1
          asl
          tax
          lda CharacterMissileMomentumX,x
          sta temp2
          rts
.pend

GetMissileMomentumY .proc
          Return missile vertical momentum from CharacterMissileMomentumY[temp1].
          ;; Parameters: temp1 = character index (0-MaxCharacter)
          ;; Output: temp2 = missile momentum Y
          ;; Mutates: temp2 (return value - missile momentum Y)
          ;; Constraints: None (table lookup - missile momentum Y)
          ;; let temp2 = CharacterMissileMomentumY[temp1]         
          lda temp1
          asl
          tax
          lda CharacterMissileMomentumY,x
          sta temp2
          rts
.pend

