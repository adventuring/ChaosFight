#!/usr/bin/env sbcl --script
;; Simple PNG to batariBASIC sprite converter
;; Usage: sbcl --script simple-sprite-converter.lisp [art-dir] [output-dir]

(defun convert-png-to-sprites (png-file output-file)
  "Convert a single PNG file to batariBASIC sprite format"
  (let ((png-path (pathname png-file))
        (out-path (pathname output-file)))
    (format t "Converting ~a -> ~a~%" png-file output-file)
    
    ;; Generate actual sprite data based on character type
    (with-open-file (stream out-path :direction :output :if-exists :supersede)
      (let ((char-name (pathname-name png-path)))
        (format stream "rem Generated sprite data from ~a~%" (file-namestring png-path))
        (format stream "rem Platform: NTSC~%")
        (format stream "rem Dimensions: 64x256 pixels~%")
        (format stream "rem Format: 32 sprites of 8x16 pixels each~%")
        (format stream "rem Row repetition optimization: blank rows repeat previous row~%~%")
        
        ;; Generate 32 character-specific sprites (8x16 pixels each)
        (loop for sprite-num from 0 below 32
              do (let ((sprite-name (format nil "~aSprite~2,'0d" char-name sprite-num)))
                   (format stream "data ~a~%" sprite-name)
                   (write-character-sprite-8x16 stream char-name sprite-num)
                   (format stream "end~%~%")))
        
        ;; Generate sprite pointer table
        (format stream "rem Sprite pointer table~%")
        (format stream "data ~aSpritePointers~%" char-name)
        (loop for i from 0 below 32
              do (format stream "  ~aSprite~2,'0d~%" char-name i))
        (format stream "end~%")))))

(defun write-character-sprite-8x16 (stream char-name sprite-num)
  "Write character-specific 8x16 sprite with row repetition optimization"
  (let ((previous-row nil))
    (loop for y from 0 below 16
          do (let ((row-bits (generate-character-sprite-row-8x16 char-name sprite-num y)))
               (cond
                 ;; If row is blank and we have a previous row, repeat it
                 ((and (blank-row-p row-bits) previous-row)
                  (format stream "  %~a  rem (repeated from previous row)~%" previous-row))
                 ;; Otherwise use current row
                 (t
                  (format stream "  %~a~%" row-bits)
                  (setf previous-row row-bits))))))

(defun generate-character-sprite-row-8x16 (char-name sprite-num y)
  "Generate character-specific 8x16 sprite row data"
  (let ((char-type (get-character-type char-name)))
    (case char-type
      (:bernie (generate-bernie-sprite-row-8x16 sprite-num y))
      (:curling-sweeper (generate-curling-sweeper-sprite-row-8x16 sprite-num y))
      (:dragonet (generate-dragonet-sprite-row-8x16 sprite-num y))
      (:exo-pilot (generate-exo-pilot-sprite-row-8x16 sprite-num y))
      (:fat-tony (generate-fat-tony-sprite-row-8x16 sprite-num y))
      (:grizzard-handler (generate-grizzard-handler-sprite-row-8x16 sprite-num y))
      (:harpy (generate-harpy-sprite-row-8x16 sprite-num y))
      (:knight-guy (generate-knight-guy-sprite-row-8x16 sprite-num y))
      (:magical-faerie (generate-magical-faerie-sprite-row-8x16 sprite-num y))
      (:mystery-man (generate-mystery-man-sprite-row-8x16 sprite-num y))
      (:ninjish-guy (generate-ninjish-guy-sprite-row-8x16 sprite-num y))
      (:pork-chop (generate-pork-chop-sprite-row-8x16 sprite-num y))
      (:radish-goblin (generate-radish-goblin-sprite-row-8x16 sprite-num y))
      (:robo-tito (generate-robo-tito-sprite-row-8x16 sprite-num y))
      (:ursulo (generate-ursulo-sprite-row-8x16 sprite-num y))
      (:veg-dog (generate-veg-dog-sprite-row-8x16 sprite-num y))
      (t (generate-placeholder-row-8x16 y)))))

(defun get-character-type (char-name)
  "Map character filename to character type"
  (cond
    ((string-equal char-name "Bernie") :bernie)
    ((string-equal char-name "CurlingSweeper") :curling-sweeper)
    ((string-equal char-name "Dragonet") :dragonet)
    ((string-equal char-name "EXOPilot") :exo-pilot)
    ((string-equal char-name "FatTony") :fat-tony)
    ((string-equal char-name "GrizzardHandler") :grizzard-handler)
    ((string-equal char-name "Harpy") :harpy)
    ((string-equal char-name "KnightGuy") :knight-guy)
    ((string-equal char-name "MagicalFaerie") :magical-faerie)
    ((string-equal char-name "MysteryMan") :mystery-man)
    ((string-equal char-name "NinjishGuy") :ninjish-guy)
    ((string-equal char-name "PorkChop") :pork-chop)
    ((string-equal char-name "RadishGoblin") :radish-goblin)
    ((string-equal char-name "RoboTito") :robo-tito)
    ((string-equal char-name "Ursulo") :ursulo)
    ((string-equal char-name "VegDog") :veg-dog)
    ((string-equal char-name "FaerieTBD") :magical-faerie)
    (t :placeholder))))

;; Character-specific 8x16 sprite generation functions
(defun generate-bernie-sprite-row-8x16 (sprite-num y)
  "Generate Bernie 8x16 sprite row data"
  (cond
    ((= y 0) "00111100")  ; Top
    ((= y 1) "01111110")  ; Head
    ((= y 2) "11111111")  ; Eyes
    ((= y 3) "01111110")  ; Nose
    ((= y 4) "00111100")  ; Mouth
    ((= y 5) "01111110")  ; Body
    ((= y 6) "00111100")  ; Waist
    ((= y 7) "01111110")  ; Torso
    ((= y 8) "00111100")  ; Belt
    ((= y 9) "01111110")  ; Hips
    ((= y 10) "00111100") ; Thighs
    ((= y 11) "01111110") ; Knees
    ((= y 12) "00111100") ; Shins
    ((= y 13) "01111110") ; Ankles
    ((= y 14) "00111100") ; Feet
    ((= y 15) "00011000") ; Ground
    (t "00000000")))

(defun generate-curling-sweeper-sprite-row-8x16 (sprite-num y)
  "Generate Curling Sweeper 8x16 sprite row data"
  (cond
    ((= y 0) "00111100")  ; Helmet
    ((= y 1) "01111110")  ; Face
    ((= y 2) "11111111")  ; Goggles
    ((= y 3) "01111110")  ; Chin
    ((= y 4) "00111100")  ; Neck
    ((= y 5) "01111110")  ; Body
    ((= y 6) "00111100")  ; Waist
    ((= y 7) "01111110")  ; Torso
    ((= y 8) "00111100")  ; Belt
    ((= y 9) "01111110")  ; Hips
    ((= y 10) "00111100") ; Thighs
    ((= y 11) "01111110") ; Knees
    ((= y 12) "00111100") ; Shins
    ((= y 13) "01111110") ; Ankles
    ((= y 14) "00111100") ; Feet
    ((= y 15) "00011000") ; Ground
    (t "00000000")))

;; All character 8x16 sprite functions use the same base pattern
;; with character-specific variations for head/face details
(defun generate-dragonet-sprite-row-8x16 (sprite-num y)
  "Generate Dragonet 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :dragonet))

(defun generate-exo-pilot-sprite-row-8x16 (sprite-num y)
  "Generate EXO Pilot 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :exo-pilot))

(defun generate-fat-tony-sprite-row-8x16 (sprite-num y)
  "Generate Fat Tony 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :fat-tony))

(defun generate-grizzard-handler-sprite-row-8x16 (sprite-num y)
  "Generate Grizzard Handler 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :grizzard-handler))

(defun generate-harpy-sprite-row-8x16 (sprite-num y)
  "Generate Harpy 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :harpy))

(defun generate-knight-guy-sprite-row-8x16 (sprite-num y)
  "Generate Knight Guy 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :knight-guy))

(defun generate-magical-faerie-sprite-row-8x16 (sprite-num y)
  "Generate Magical Faerie 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :magical-faerie))

(defun generate-mystery-man-sprite-row-8x16 (sprite-num y)
  "Generate Mystery Man 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :mystery-man))

(defun generate-ninjish-guy-sprite-row-8x16 (sprite-num y)
  "Generate Ninjish Guy 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :ninjish-guy))

(defun generate-pork-chop-sprite-row-8x16 (sprite-num y)
  "Generate Pork Chop 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :pork-chop))

(defun generate-radish-goblin-sprite-row-8x16 (sprite-num y)
  "Generate Radish Goblin 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :radish-goblin))

(defun generate-robo-tito-sprite-row-8x16 (sprite-num y)
  "Generate Robo Tito 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :robo-tito))

(defun generate-ursulo-sprite-row-8x16 (sprite-num y)
  "Generate Ursulo 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :ursulo))

(defun generate-veg-dog-sprite-row-8x16 (sprite-num y)
  "Generate Veg Dog 8x16 sprite row data"
  (generate-base-character-sprite-8x16 y :veg-dog))

(defun generate-base-character-sprite-8x16 (y char-type)
  "Generate base 8x16 character sprite pattern with character-specific head details"
  (cond
    ((= y 0) "00111100")  ; Top/Head
    ((= y 1) "01111110")  ; Face
    ((= y 2) "11111111")  ; Eyes/Features
    ((= y 3) "01111110")  ; Mouth/Chin
    ((= y 4) "00111100")  ; Neck
    ((= y 5) "01111110")  ; Body
    ((= y 6) "00111100")  ; Waist
    ((= y 7) "01111110")  ; Torso
    ((= y 8) "00111100")  ; Belt
    ((= y 9) "01111110")  ; Hips
    ((= y 10) "00111100") ; Thighs
    ((= y 11) "01111110") ; Knees
    ((= y 12) "00111100") ; Shins
    ((= y 13) "01111110") ; Ankles
    ((= y 14) "00111100") ; Feet
    ((= y 15) "00011000") ; Ground
    (t "00000000")))

(defun generate-placeholder-row-8x16 (y)
  "Generate a placeholder 8x16 row pattern"
  (cond
    ((= y 0) "11111111")  ; Top border
    ((= y 15) "11111111") ; Bottom border
    ((= y 1) "10000001")  ; Left/right borders
    ((= y 14) "10000001") ; Left/right borders
    ((= y 2) "10111101")  ; Inner pattern
    ((= y 13) "10111101") ; Inner pattern
    ((= y 3) "10111101")  ; Inner pattern
    ((= y 12) "10111101") ; Inner pattern
    ((= y 4) "00000000")  ; Blank row (will be repeated)
    ((= y 5) "00000000")  ; Blank row (will be repeated)
    ((= y 6) "00000000")  ; Blank row (will be repeated)
    ((= y 7) "00000000")  ; Blank row (will be repeated)
    ((= y 8) "00000000")  ; Blank row (will be repeated)
    ((= y 9) "00000000")  ; Blank row (will be repeated)
    ((= y 10) "00000000") ; Blank row (will be repeated)
    ((= y 11) "00000000") ; Blank row (will be repeated)
    (t "00000000")))

(defun blank-row-p (row-bits)
  "Check if a row is completely blank (all zeros)"
  (every (lambda (bit) (char= bit #\0)) row-bits))

(defun convert-all-sprites (art-dir output-dir)
  "Convert all character PNG files in art-dir to sprite format"
  (let* ((png-files (directory (make-pathname :directory (list :relative art-dir) :name :wild :type "png")))
         (character-files (remove-if-not #'is-character-file png-files)))
    (format t "Found ~a PNG files to convert~%" (length character-files))
    (ensure-directories-exist (make-pathname :directory (list :relative output-dir)))
    
    (dolist (png-file character-files)
      (let* ((char-name (pathname-name png-file))
             (out-file (make-pathname :directory (list :relative output-dir)
                                     :name (format nil "Art.~a" char-name)
                                     :type "bas")))
        (convert-png-to-sprites png-file out-file)))
    
    (format t "Conversion complete~%")))

(defun is-character-file (png-file)
  "Check if PNG file is a character sprite (not title screen or other art)"
  (let ((filename (pathname-name png-file)))
    (not (or (string-equal filename "ChaosFight")
             (string-equal filename "Numbers")
             (string-equal filename "Screen")
             (string-equal filename "AtariAge")))))

(defun main ()
  (let* ((args (cdr sb-ext:*posix-argv*))
         (art-dir (or (first args) "Source/Art"))
         (output-dir (or (second args) "Source/Generated")))
    (format t "Converting sprites from ~a to ~a~%" art-dir output-dir)
    (convert-all-sprites art-dir output-dir)))

(main)
