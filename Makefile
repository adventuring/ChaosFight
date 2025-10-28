# Tools and directories
BB_DIR = Tools/batariBASIC
BB_MAIN = bin/2600basic
BB_PREPROCESS = bin/preprocess
BB_POSTPROCESS = bin/postprocess
BB_OPTIMIZE = bin/optimize
BB_FILTER = bin/bbfilter
DASM = bin/dasm
STELLA = stella
GIMP = gimp
SOURCE_DIR = .
OBJECT_DIR = Object
DIST_DIR = Dist

# SkylineTool build rules
SkylineTool/zx7mini/zx7mini.c:
	git submodule update --init --recursive

bin/zx7mini:	SkylineTool/zx7mini/zx7mini.c
	$(CC) SkylineTool/zx7mini/zx7mini.c -o bin/zx7mini
	chmod +x bin/zx7mini

skyline-tool:	bin/skyline-tool

SkylineTool/skyline-tool.asd:
	git submodule update --init --recursive

bin/skyline-tool:	bin/buildapp bin/zx7mini \
	SkylineTool/skyline-tool.asd \
	$(shell ls SkylineTool/*.lisp SkylineTool/src/*.lisp)
	mkdir -p bin
	@echo "Note: This may take a while if you don't have some common Quicklisp \
libraries already compiled. On subsequent runs, though, it'll be much quicker." >&2
	bin/buildapp --output bin/skyline-tool \
		--load SkylineTool/setup.lisp \
		--load-system skyline-tool \
		--entry skyline-tool::command

bin/buildapp:
	sbcl --load SkylineTool/prepare-system.lisp --eval '(cl-user::quit)'

# Output files
GAME = ChaosFight
ROM = Dist/$(GAME).NTSC.a26

# Assembly files
ALL_SOURCES = $(shell find Source -name \*.bas) Source/Generated/Playfields.bas

# Default target
.PHONY: all clean emu game help doc characters playfields fonts sprites
all: sprites game doc characters playfields fonts

# Build game
game: \
	Dist/$(GAME).NTSC.a26 \
	Dist/$(GAME).PAL.a26 \
	Dist/$(GAME).SECAM.a26 \
	Dist/$(GAME).NTSC.sym \
	Dist/$(GAME).PAL.sym \
	Dist/$(GAME).SECAM.sym \
	Dist/$(GAME).NTSC.lst \
	Dist/$(GAME).PAL.lst \
	Dist/$(GAME).SECAM.lst \
	Dist/$(GAME).NTSC.pro \
	Dist/$(GAME).PAL.pro \
	Dist/$(GAME).SECAM.pro

# Sprite conversion using skyline-tool
sprites: bin/skyline-tool special-sprites
	@echo "Converting PNG sprites to batariBASIC format..."
	@mkdir -p Source/Generated
	@for char in Bernie CurlingSweeper Dragonet EXOPilot FatTony GrizzardHandler Harpy KnightGuy MagicalFaerie MysteryMan NinjishGuy PorkChop RadishGoblin RoboTito Ursulo VegDog; do \
		echo "Converting $$char..."; \
		./bin/skyline-tool compile-2600-sprites :output Source/Generated/Art.$$char.bas :character-name $$char; \
	done

# Convert special sprites (QuestionMark, CPU, No) from XCF to binary data
special-sprites: Source/Art/QuestionMark.png Source/Art/CPU.png Source/Art/No.png
	@echo "Converting special sprites to binary data..."
	@python3 bin/convert_special_sprites.py

doc: Dist/$(GAME).pdf Dist/$(GAME).html

# Character sprite sheet names (16 characters)
CHARACTER_NAMES = Bernie CurlingSweeper Dragonet EXOPilot FatTony GrizzardHandler Harpy KnightGuy MagicalFaerie MysteryMan NinjishGuy PorkChop RadishGoblin RoboTito Ursulo VegDog
SPECIAL_SPRITES = QuestionMark CPU No

# TV architectures
TV_ARCHS = NTSC PAL SECAM

# Screen names (32×32 playfield screens)
SCREEN_NAMES = AtariAge Interworldly ChaosFight

# Font names
FONT_NAMES = Numbers

# Build character assets
characters: Source/Generated/Characters.NTSC.bas Source/Generated/Characters.PAL.bas Source/Generated/Characters.SECAM.bas

# Build playfield assets (game levels + title screens)
playfields: Source/Generated/Playfields.bas $(foreach screen,$(SCREEN_NAMES),$(foreach arch,$(TV_ARCHS),Source/Generated/Playfield.$(screen).$(arch).bas))

# Build font assets
fonts: $(foreach font,$(FONT_NAMES),$(foreach arch,$(TV_ARCHS),Source/Generated/Font.$(font).$(arch).bas))

# Generate list of character sprite files
CHARACTER_XCF = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).xcf)
CHARACTER_PNG = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).png)
CHARACTER_BAS = $(foreach char,$(CHARACTER_NAMES),Source/Generated/Art.$(char).bas)

# Convert XCF to PNG for character sprites  
Source/Art/%.png: Source/Art/%.xcf $(READYFILE)
	@echo "Converting $< to $@..."
	mkdir -p Source/Art
	xvfb-run -a $(GIMP) -b '(load "Tools/xcf-export.scm")' -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

# Convert PNG character sprite sheet to batariBASIC data for NTSC
Source/Generated/Art.%.NTSC.bas: Source/Art/%.png
	@echo "Converting character sprite $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-art "$@" "$<"

# Convert PNG character sprite sheet to batariBASIC data for PAL  
Source/Generated/Art.%.PAL.bas: Source/Art/%.png
	@echo "Converting character sprite $< to $@ for PAL..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-art "$@" "$<"

# Convert PNG character sprite sheet to batariBASIC data for SECAM
Source/Generated/Art.%.SECAM.bas: Source/Art/%.png
	@echo "Converting character sprite $< to $@ for SECAM..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-art "$@" "$<"

# Generate platform-specific character files
Source/Generated/Characters.NTSC.bas:
	@echo "Generating NTSC character data..."
	mkdir -p Source/Generated
	@echo "          rem ChaosFight - Generated Character Sprite Data (NTSC)" > $@
	@echo "          rem Copyright © 2025 Interworldly Adventuring, LLC." >> $@
	@echo "" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          rem CHARACTER SPRITE DATA - NTSC" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          rem This file includes all character sprite data compiled from XCF sources" >> $@
	@echo "          rem Each character is 64px wide (8 frames) × 256px tall (16 sequences)" >> $@
	@echo "          rem Facing right by default, use REFPn to reflect for face-left" >> $@
	@echo "          rem Duplicate frames are detected and re-used, blank frames are omitted" >> $@
	@echo "" >> $@
	@echo "          rem Character sprite data will be included from individual Art.*.bas files" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          rem CHARACTER COLORS - NTSC" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          data CharacterColors" >> $@
	@echo "          \$$0E, \$$0E  rem Bernie - White" >> $@
	@echo "          \$$0C, \$$0C  rem CurlingSweeper - Yellow" >> $@
	@echo "          \$$0A, \$$0A  rem Dragonet - Red" >> $@
	@echo "          \$$0E, \$$0E  rem EXOPilot - White" >> $@
	@echo "          \$$0C, \$$0C  rem FatTony - Yellow" >> $@
	@echo "          \$$0A, \$$0A  rem GrizzardHandler - Red" >> $@
	@echo "          \$$0E, \$$0E  rem Harpy - White" >> $@
	@echo "          \$$0C, \$$0C  rem KnightGuy - Yellow" >> $@
	@echo "          \$$0A, \$$0A  rem MagicalFaerie - Red" >> $@
	@echo "          \$$0E, \$$0E  rem MysteryMan - White" >> $@
	@echo "          \$$0C, \$$0C  rem NinjishGuy - Yellow" >> $@
	@echo "          \$$0A, \$$0A  rem PorkChop - Red" >> $@
	@echo "          \$$0E, \$$0E  rem RadishGoblin - White" >> $@
	@echo "          \$$0C, \$$0C  rem RoboTito - Yellow" >> $@
	@echo "          \$$0A, \$$0A  rem Ursulo - Red" >> $@
	@echo "          \$$0E, \$$0E  rem VegDog - White" >> $@
	@echo "          end" >> $@

Source/Generated/Characters.PAL.bas:
	@echo "Generating PAL character data..."
	mkdir -p Source/Generated
	@echo "          rem ChaosFight - Generated Character Sprite Data (PAL)" > $@
	@echo "          rem Copyright © 2025 Interworldly Adventuring, LLC." >> $@
	@echo "" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          rem CHARACTER SPRITE DATA - PAL" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          rem This file includes all character sprite data compiled from XCF sources" >> $@
	@echo "          rem Each character is 64px wide (8 frames) × 256px tall (16 sequences)" >> $@
	@echo "          rem Facing right by default, use REFPn to reflect for face-left" >> $@
	@echo "          rem Duplicate frames are detected and re-used, blank frames are omitted" >> $@
	@echo "" >> $@
	@echo "          rem Character sprite data will be included from individual Art.*.bas files" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          rem CHARACTER COLORS - PAL" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          data CharacterColors" >> $@
	@echo "          \$$0E, \$$0E  rem Bernie - White" >> $@
	@echo "          \$$0C, \$$0C  rem CurlingSweeper - Yellow" >> $@
	@echo "          \$$0A, \$$0A  rem Dragonet - Red" >> $@
	@echo "          \$$0E, \$$0E  rem EXOPilot - White" >> $@
	@echo "          \$$0C, \$$0C  rem FatTony - Yellow" >> $@
	@echo "          \$$0A, \$$0A  rem GrizzardHandler - Red" >> $@
	@echo "          \$$0E, \$$0E  rem Harpy - White" >> $@
	@echo "          \$$0C, \$$0C  rem KnightGuy - Yellow" >> $@
	@echo "          \$$0A, \$$0A  rem MagicalFaerie - Red" >> $@
	@echo "          \$$0E, \$$0E  rem MysteryMan - White" >> $@
	@echo "          \$$0C, \$$0C  rem NinjishGuy - Yellow" >> $@
	@echo "          \$$0A, \$$0A  rem PorkChop - Red" >> $@
	@echo "          \$$0E, \$$0E  rem RadishGoblin - White" >> $@
	@echo "          \$$0C, \$$0C  rem RoboTito - Yellow" >> $@
	@echo "          \$$0A, \$$0A  rem Ursulo - Red" >> $@
	@echo "          \$$0E, \$$0E  rem VegDog - White" >> $@
	@echo "          end" >> $@

Source/Generated/Characters.SECAM.bas:
	@echo "Generating SECAM character data..."
	mkdir -p Source/Generated
	@echo "          rem ChaosFight - Generated Character Sprite Data (SECAM)" > $@
	@echo "          rem Copyright © 2025 Interworldly Adventuring, LLC." >> $@
	@echo "" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          rem CHARACTER SPRITE DATA - SECAM" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          rem This file includes all character sprite data compiled from XCF sources" >> $@
	@echo "          rem Each character is 64px wide (8 frames) × 256px tall (16 sequences)" >> $@
	@echo "          rem Facing right by default, use REFPn to reflect for face-left" >> $@
	@echo "          rem Duplicate frames are detected and re-used, blank frames are omitted" >> $@
	@echo "" >> $@
	@echo "          rem Character sprite data will be included from individual Art.*.bas files" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          rem CHARACTER COLORS - SECAM (Grayscale)" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "data CharacterColors" >> $@
	@echo "          \$0E, \$0E  rem Bernie - White" >> $@
	@echo "          \$0C, \$0C  rem CurlingSweeper - Light Gray" >> $@
	@echo "          \$0A, \$0A  rem Dragonet - Medium Gray" >> $@
	@echo "          \$0E, \$0E  rem EXOPilot - White" >> $@
	@echo "          \$0C, \$0C  rem FatTony - Light Gray" >> $@
	@echo "          \$0A, \$0A  rem GrizzardHandler - Medium Gray" >> $@
	@echo "          \$0E, \$0E  rem Harpy - White" >> $@
	@echo "          \$0C, \$0C  rem KnightGuy - Light Gray" >> $@
	@echo "          \$0A, \$0A  rem MagicalFaerie - Medium Gray" >> $@
	@echo "          \$0E, \$0E  rem MysteryMan - White" >> $@
	@echo "          \$0C, \$0C  rem NinjishGuy - Light Gray" >> $@
	@echo "          \$0A, \$0A  rem PorkChop - Medium Gray" >> $@
	@echo "          \$0E, \$0E  rem RadishGoblin - White" >> $@
	@echo "          \$0C, \$0C  rem RoboTito - Light Gray" >> $@
	@echo "          \$0A, \$0A  rem Ursulo - Medium Gray" >> $@
	@echo "          \$0E, \$0E  rem VegDog - White" >> $@
	@echo "end" >> $@

# Convert XCF to PNG for screens (32×32 playfields)
Source/Art/AtariAge.png Source/Art/Interworldly.png Source/Art/ChaosFight.png: Source/Art/%.png: Source/Art/%.xcf
	@echo "Converting screen $< to $@..."
	mkdir -p Source/Art
	gimp --batch-interpreter=plug-in-script-fu-eval --batch '(load "Tools/xcf-export.scm") (xcf-export "$<" "$@") (gimp-quit 1)'

# Convert XCF to PNG for fonts (special handling for font sheets)
Source/Art/Numbers.png: Source/Art/Numbers.xcf
	@echo "Converting font $< to $@..."
	mkdir -p Source/Art
	magick "$<" -background black -flatten "$@"

# Convert PNG font to batariBASIC data for NTSC
Source/Generated/Font.%.NTSC.bas: Source/Art/%.png
	@echo "Converting font $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-font \
		:input "$<" \
		:output "$@" \
		:font-name "$*" \
		:architecture "NTSC"

# Convert PNG font to batariBASIC data for PAL
Source/Generated/Font.%.PAL.bas: Source/Art/%.png
	@echo "Converting font $< to $@ for PAL..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-font \
		:input "$<" \
		:output "$@" \
		:font-name "$*" \
		:architecture "PAL"

# Convert PNG font to batariBASIC data for SECAM
Source/Generated/Font.%.SECAM.bas: Source/Art/%.png
	@echo "Converting font $< to $@ for SECAM..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-font \
		:input "$<" \
		:output "$@" \
		:font-name "$*" \
		:architecture "SECAM"

# Convert PNG screen to batariBASIC playfield data for NTSC
Source/Generated/Playfield.%.NTSC.bas: Source/Art/%.png
	@echo "Converting playfield screen $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-playfield \
		:input "$<" \
		:output "$@" \
		:screen-name "$*" \
		:architecture "NTSC" \
		:width 32 \
		:height 32 \
		:pfres 32

# Convert PNG screen to batariBASIC playfield data for PAL
Source/Generated/Playfield.%.PAL.bas: Source/Art/%.png
	@echo "Converting playfield screen $< to $@ for PAL..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-playfield \
		:input "$<" \
		:output "$@" \
		:screen-name "$*" \
		:architecture "PAL" \
		:width 32 \
		:height 32 \
		:pfres 32

# Convert PNG screen to batariBASIC playfield data for SECAM
Source/Generated/Playfield.%.SECAM.bas: Source/Art/%.png
	@echo "Converting playfield screen $< to $@ for SECAM..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-playfield \
		:input "$<" \
		:output "$@" \
		:screen-name "$*" \
		:architecture "SECAM" \
		:width 32 \
		:height 32 \
		:pfres 32

# Convert XCF to PNG for maps
Source/Art/Map-%.png: Source/Art/Map-%.xcf
	gimp --batch-interpreter=plug-in-script-fu-eval --batch '(load "Tools/xcf-export.scm") (xcf-export "$<" "$@") (gimp-quit 1)'

# Convert PNG to batariBASIC playfield include
Source/Generated/Playfields.bas: $(wildcard Source/Art/Map-*.png)
	mkdir -p Source/Generated
	bin/skyline-tool compile-playfields Source/Generated $(wildcard Source/Art/Map-*.png)

# Convert PNG font to batariBASIC data for NTSC
Source/Generated/Font.%.NTSC.bas: Source/Art/%.png
	@echo "Converting font $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-font \
		:input "$<" \
		:output "$@" \
		:font-name "$*" \
		:architecture "NTSC" \
		:char-width 8 \
		:char-height 16 \
		:num-chars 16 \
		:format "hex-digits"

# Convert PNG font to batariBASIC data for PAL
Source/Generated/Font.%.PAL.bas: Source/Art/%.png
	@echo "Converting font $< to $@ for PAL..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-font \
		:input "$<" \
		:output "$@" \
		:font-name "$*" \
		:architecture "PAL" \
		:char-width 8 \
		:char-height 16 \
		:num-chars 16 \
		:format "hex-digits"

# Convert PNG font to batariBASIC data for SECAM
Source/Generated/Font.%.SECAM.bas: Source/Art/%.png
	@echo "Converting font $< to $@ for SECAM..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-font \
		:input "$<" \
		:output "$@" \
		:font-name "$*" \
		:architecture "SECAM" \
		:char-width 8 \
		:char-height 16 \
		:num-chars 16 \
		:format "hex-digits"

# Build game
Dist/$(GAME).NTSC.a26 Dist/$(GAME).NTSC.sym Dist/$(GAME).NTSC.lst: $(ALL_SOURCES) Source/Generated/Characters.NTSC.bas
	mkdir -p Dist Source/Generated
	cpp -P -I. Source/Platform/NTSC.bas > Source/Generated/$(GAME).NTSC.bas
	bin/preprocess < Source/Generated/$(GAME).NTSC.bas > Source/Generated/$(GAME).NTSC.preprocessed.bas
	bin/2600basic -i Tools/batariBASIC -r Source/Common/variable_redefs.h < Source/Generated/$(GAME).NTSC.preprocessed.bas > Source/Generated/$(GAME).NTSC.bB.asm
	@for f in multispriteheader.asm multisprite_kernel.asm startup.asm std_routines.asm score_graphics.asm banksw.asm 2600basicfooter.asm multisprite_bankswitch.inc; do \
		ln -sf Tools/batariBASIC/includes/$$f $$f 2>/dev/null || true; \
	done
	@cp Source/Common/includes.bB .
	bin/postprocess -i Tools/batariBASIC/includes < Source/Generated/$(GAME).NTSC.bB.asm | grep -v "^User-defined.*found in current directory" > Source/Generated/$(GAME).NTSC.tmp.s
	@echo "; Configuration symbols for batariBasic" > Source/Generated/$(GAME).NTSC.s
	@echo "multisprite = 1" >> Source/Generated/$(GAME).NTSC.s
	@echo "playercolors = 1" >> Source/Generated/$(GAME).NTSC.s
	@echo "player1colors = 1" >> Source/Generated/$(GAME).NTSC.s
	@echo "pfcolors = 1" >> Source/Generated/$(GAME).NTSC.s
	@echo "bankswitch = 64" >> Source/Generated/$(GAME).NTSC.s
	@echo "bankswitch_hotspot = \$$FFF8" >> Source/Generated/$(GAME).NTSC.s
	@echo "superchip = 1" >> Source/Generated/$(GAME).NTSC.s
	@echo "NO_ILLEGAL_OPCODES = 1" >> Source/Generated/$(GAME).NTSC.s
	@echo "noscore = 0" >> Source/Generated/$(GAME).NTSC.s
	@echo "qtcontroller = 0" >> Source/Generated/$(GAME).NTSC.s
	@echo "pfres = 12" >> Source/Generated/$(GAME).NTSC.s
	@echo "bscode_length = 32" >> Source/Generated/$(GAME).NTSC.s
	@cat Source/Generated/$(GAME).NTSC.tmp.s >> Source/Generated/$(GAME).NTSC.s
	@rm -f Source/Generated/$(GAME).NTSC.tmp.s
	bin/dasm Source/Generated/$(GAME).NTSC.s -ITools/batariBASIC/includes -f3 -lDist/$(GAME).NTSC.lst -sDist/$(GAME).NTSC.sym -oDist/$(GAME).NTSC.a26
	rm -f Source/Generated/$(GAME).NTSC.bB.asm Source/Generated/$(GAME).NTSC.s Source/Generated/$(GAME).NTSC.preprocessed.bas

Dist/$(GAME).PAL.a26 Dist/$(GAME).PAL.sym Dist/$(GAME).PAL.lst: $(ALL_SOURCES) Source/Generated/Characters.PAL.bas
	mkdir -p Dist Source/Generated
	cpp -P -I. Source/Platform/PAL.bas > Source/Generated/$(GAME).PAL.bas
	bin/preprocess < Source/Generated/$(GAME).PAL.bas > Source/Generated/$(GAME).PAL.preprocessed.bas
	bin/2600basic -i Tools/batariBASIC -r Source/Common/variable_redefs.h < Source/Generated/$(GAME).PAL.preprocessed.bas > Source/Generated/$(GAME).PAL.bB.asm
	@for f in multispriteheader.asm multisprite_kernel.asm startup.asm std_routines.asm score_graphics.asm banksw.asm 2600basicfooter.asm multisprite_bankswitch.inc; do \
		ln -sf Tools/batariBASIC/includes/$$f $$f 2>/dev/null || true; \
	done
	@cp Source/Common/includes.bB .
	bin/postprocess -i Tools/batariBASIC/includes < Source/Generated/$(GAME).PAL.bB.asm | grep -v "^User-defined.*found in current directory" > Source/Generated/$(GAME).PAL.tmp.s
	@echo "; Configuration symbols for batariBasic" > Source/Generated/$(GAME).PAL.s
	@echo "multisprite = 1" >> Source/Generated/$(GAME).PAL.s
	@echo "playercolors = 1" >> Source/Generated/$(GAME).PAL.s
	@echo "player1colors = 1" >> Source/Generated/$(GAME).PAL.s
	@echo "pfcolors = 1" >> Source/Generated/$(GAME).PAL.s
	@echo "bankswitch = 32" >> Source/Generated/$(GAME).PAL.s
	@echo "bankswitch_hotspot = \$$FFF8" >> Source/Generated/$(GAME).PAL.s
	@echo "superchip = 1" >> Source/Generated/$(GAME).PAL.s
	@echo "NO_ILLEGAL_OPCODES = 1" >> Source/Generated/$(GAME).PAL.s
	@echo "noscore = 0" >> Source/Generated/$(GAME).PAL.s
	@echo "qtcontroller = 0" >> Source/Generated/$(GAME).PAL.s
	@echo "pfres = 12" >> Source/Generated/$(GAME).PAL.s
	@echo "bscode_length = 32" >> Source/Generated/$(GAME).PAL.s
	@cat Source/Generated/$(GAME).PAL.tmp.s >> Source/Generated/$(GAME).PAL.s
	@rm -f Source/Generated/$(GAME).PAL.tmp.s
	bin/dasm Source/Generated/$(GAME).PAL.s -ITools/batariBASIC/includes -f3 -lDist/$(GAME).PAL.lst -sDist/$(GAME).PAL.sym -oDist/$(GAME).PAL.a26
	rm -f Source/Generated/$(GAME).PAL.bB.asm Source/Generated/$(GAME).PAL.s Source/Generated/$(GAME).PAL.preprocessed.bas

Dist/$(GAME).SECAM.a26 Dist/$(GAME).SECAM.sym Dist/$(GAME).SECAM.lst: $(ALL_SOURCES) Source/Generated/Characters.SECAM.bas
	mkdir -p Dist Source/Generated
	cpp -P -I. Source/Platform/SECAM.bas > Source/Generated/$(GAME).SECAM.bas
	bin/preprocess < Source/Generated/$(GAME).SECAM.bas > Source/Generated/$(GAME).SECAM.preprocessed.bas
	bin/2600basic -i Tools/batariBASIC -r Source/Common/variable_redefs.h < Source/Generated/$(GAME).SECAM.preprocessed.bas > Source/Generated/$(GAME).SECAM.bB.asm
	@for f in multispriteheader.asm multisprite_kernel.asm startup.asm std_routines.asm score_graphics.asm banksw.asm 2600basicfooter.asm multisprite_bankswitch.inc; do \
		ln -sf Tools/batariBASIC/includes/$$f $$f 2>/dev/null || true; \
	done
	@cp Source/Common/includes.bB .
	bin/postprocess -i Tools/batariBASIC/includes < Source/Generated/$(GAME).SECAM.bB.asm | grep -v "^User-defined.*found in current directory" > Source/Generated/$(GAME).SECAM.tmp.s
	@echo "; Configuration symbols for batariBasic" > Source/Generated/$(GAME).SECAM.s
	@echo "multisprite = 1" >> Source/Generated/$(GAME).SECAM.s
	@echo "playercolors = 1" >> Source/Generated/$(GAME).SECAM.s
	@echo "player1colors = 1" >> Source/Generated/$(GAME).SECAM.s
	@echo "pfcolors = 1" >> Source/Generated/$(GAME).SECAM.s
	@echo "bankswitch = 32" >> Source/Generated/$(GAME).SECAM.s
	@echo "bankswitch_hotspot = \$$FFF8" >> Source/Generated/$(GAME).SECAM.s
	@echo "superchip = 1" >> Source/Generated/$(GAME).SECAM.s
	@echo "NO_ILLEGAL_OPCODES = 1" >> Source/Generated/$(GAME).SECAM.s
	@echo "noscore = 0" >> Source/Generated/$(GAME).SECAM.s
	@echo "qtcontroller = 0" >> Source/Generated/$(GAME).SECAM.s
	@echo "pfres = 12" >> Source/Generated/$(GAME).SECAM.s
	@echo "bscode_length = 32" >> Source/Generated/$(GAME).SECAM.s
	@cat Source/Generated/$(GAME).SECAM.tmp.s >> Source/Generated/$(GAME).SECAM.s
	@rm -f Source/Generated/$(GAME).SECAM.tmp.s
	bin/dasm Source/Generated/$(GAME).SECAM.s -ITools/batariBASIC/includes -f3 -lDist/$(GAME).SECAM.lst -sDist/$(GAME).SECAM.sym -oDist/$(GAME).SECAM.a26
	rm -f Source/Generated/$(GAME).SECAM.bB.asm Source/Generated/$(GAME).SECAM.s Source/Generated/$(GAME).SECAM.preprocessed.bas

# Run emulator
emu: $(ROM)
	$(STELLA) $(ROM)

# Clean all generated files
clean:
	rm -rf Dist/*.a26
	rm -rf Object/*
	rm -f Source/Generated/*.s
	rm -f bB.s *.bin *.lst *.sym *.map

# Install GIMP export script
gimp-export:
	@for d in ~/.config/GIMP/*/scripts/; do \
		if [ -d "$$d" ]; then \
			echo "Installing xcf-export.scm to $$d"; \
			cp -f Tools/xcf-export.scm "$$d"; \
		fi; \
	done

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Build game and documentation (default)"
	@echo "  game         - Build game ROMs for all TV systems"
	@echo "  doc          - Build PDF and HTML manuals"
	@echo "  characters   - Generate character sprite data"
	@echo "  playfields   - Generate playfield/screen data"
	@echo "  fonts        - Generate font data"
	@echo "  clean        - Remove generated ROM files"
	@echo "  emu          - Build and run in Stella emulator"
	@echo "  gimp-export  - Install GIMP export script"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Output files:"
	@echo "  Dist/ChaosFight-Manual.pdf  - Game manual (PDF)"
	@echo "  Dist/ChaosFight-Manual.html - Game manual (HTML)"
	@echo "  Dist/ChaosFight.NTSC.a26    - NTSC ROM"
	@echo "  Dist/ChaosFight.PAL.a26     - PAL ROM"
	@echo "  Dist/ChaosFight.SECAM.a26   - SECAM ROM"

# Generate Stella .pro files
Dist/$(GAME).NTSC.pro: Source/$(GAME).pro Dist/$(GAME).NTSC.a26
	sed $< -e s/@@TV@@/NTSC/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME).NTSC.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME).PAL.pro: Source/$(GAME).pro Dist/$(GAME).PAL.a26
	sed $< -e s/@@TV@@/PAL/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME).PAL.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME).SECAM.pro: Source/$(GAME).pro Dist/$(GAME).SECAM.a26
	sed $< -e s/@@TV@@/SECAM/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME).SECAM.a26 | cut -d\  -f1)/g > $@

# Generate PDF manual from Texinfo source
Dist/$(GAME)-Manual.pdf: Manual/$(GAME).texi
	@echo "Building PDF manual..."
	mkdir -p Dist
	cd Manual && texi2pdf $(GAME).texi
	cp Manual/$(GAME).pdf Dist/$(GAME)-Manual.pdf

# Generate HTML manual from Texinfo source
Dist/$(GAME)-Manual.html: Manual/$(GAME).texi
	@echo "Building HTML manual..."
	mkdir -p Dist
	makeinfo --html --no-split --output=Dist/$(GAME)-Manual.html Manual/$(GAME).texi

