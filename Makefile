# Default target
all: sprites game doc characters fonts music bitmaps

# Test target
test: SkylineTool/skyline-tool.asd
	@echo "Running SkylineTool fiveam tests..."
	cd SkylineTool && sbcl --script tests/run-tests.lisp || (echo "Tests failed!" && exit 1)

# Precious intermediate files
.PRECIOUS: %.s %.png %.midi Object/bB.%.s Source/Generated/$(GAME).%.preprocessed.bas

# Tools and directories
BB_DIR = Tools/batariBASIC
BB_MAIN = bin/2600basic
BB_PREPROCESS = bin/preprocess
BB_POSTPROCESS = bin/postprocess
BB_OPTIMIZE = bin/optimize
DASM = bin/dasm
BB_FILTER = bin/bbfilter
POSTINC = $(abspath Tools/batariBASIC)
DASM = bin/dasm
STELLA = stella
# -i taken out for now from gimp
GIMP = gimp --batch-interpreter plug-in-script-fu-eval -c --no-shm

# Ready system
READYDATE = 20251028
READYFILE = .#ready.$(READYDATE)

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
ALL_SOURCES = $(shell find Source -name \*.bas)

# Moved to top of file
.PHONY: all clean emu game help doc characters fonts sprites nowready ready bitmaps

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

doc: Dist/$(GAME).pdf Dist/$(GAME).html

# Character sprite sheet names (32 characters: 16 main + 16 future)
CHARACTER_NAMES = \
	Bernie Curler Dragonet ZoeRyen FatTony Megax Harpy KnightGuy \
	Frooty Nefertem NinjishGuy PorkChop RadishGoblin RoboTito Ursulo Shamone \
	Character16 Character17 Character18 Character19 Character20 Character21 Character22 Character23 \
	Character24 Character25 Character26 Character27 Character28 Character29 Character30 MethHound

# TV architectures
TV_ARCHS = NTSC PAL SECAM

# Bitmap names (48×42 bitmaps for titlescreen kernel)
BITMAP_NAMES = AtariAge Interworldly ChaosFight

# Font names
FONT_NAMES = Numbers

# Music names (MuseScore files)
MUSIC_NAMES = AtariToday Interworldly Title Victory GameOver

# Build character assets
characters: $(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas)

# Build bitmap assets (48×42 for titlescreen kernel on admin screens)
bitmaps: $(foreach bitmap,$(BITMAP_NAMES),Source/Generated/Art.$(bitmap).s)

# Build font assets (fonts are universal, not region-specific)
fonts: $(foreach font,$(FONT_NAMES),Source/Generated/$(font).bas)

# Build music assets
music: $(foreach song,$(MUSIC_NAMES),$(foreach arch,$(TV_ARCHS),Source/Generated/Song.$(song).$(arch).bas))

# Convert MuseScore to MIDI
%.midi: %.mscz
	if [ -x ~/Software/MuseScore*.AppImage ]; then \
		~/Software/MuseScore*.AppImage --export-to $@ $<; \
	elif which mscore; then \
		mscore --export-to $@ $<; \
	else \
		flatpak run org.musescore.MuseScore --export-to $@ $<; \
	fi

%.flac: %.mscz
	if [ -x ~/Software/MuseScore*.AppImage ]; then \
		
	elif which mscore; then \
		mscore --export-to $@ $<; \
	else \
		flatpak run org.musescore.MuseScore --export-to $@ $<; \
	fi

%.ogg: %.mscz
	if [ -x ~/Software/MuseScore*.AppImage ]; then \
		~/Software/MuseScore*.AppImage --export-to $@ $<; \
	elif which mscore; then \
		mscore --export-to $@ $<; \
	else \
		flatpak run org.musescore.MuseScore --export-to $@ $<; \
	fi

%.pdf: %.mscz
	if [ -x ~/Software/MuseScore*.AppImage ]; then \
		~/Software/MuseScore*.AppImage --export-to $@ $<; \
	elif which mscore; then \
		mscore --export-to $@ $<; \
	else \
		flatpak run org.musescore.MuseScore --export-to $@ $<; \
	fi

# Convert MIDI to batariBASIC music data for NTSC (60Hz)
Source/Generated/Song.%.NTSC.bas: Source/Songs/%.midi bin/skyline-tool
	@echo "Converting music $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "60" "$@"

# Convert MIDI to batariBASIC music data for PAL (50Hz)
Source/Generated/Song.%.PAL.bas: Source/Songs/%.midi bin/skyline-tool
	@echo "Converting music $< to $@ for PAL..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"

# Convert MIDI to batariBASIC music data for SECAM (50Hz)
Source/Generated/Song.%.SECAM.bas: Source/Songs/%.midi bin/skyline-tool
	@echo "Converting music $< to $@ for SECAM..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"



# Generate list of character sprite files
CHARACTER_XCF = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).xcf)
CHARACTER_PNG = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).png)
CHARACTER_BAS = $(foreach char,$(CHARACTER_NAMES),Source/Generated/Art.$(char).bas)

# Convert XCF to PNG for sprites (characters and special sprites)
%.png: %.xcf
	@echo "Converting $< to $@..."
	mkdir -p Source/Art
	$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

# Character sprites are compiled using compile-chaos-character
# Special sprites (QuestionMark, CPU, No) are hard-coded in Source/Data/SpecialSprites.bas

# Generate character sprite files from PNG using chaos character compiler
# Explicit rules for each character ensure proper PNG dependency tracking
$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas): Source/Generated/%.bas: Source/Art/%.png bin/skyline-tool
	@echo "Generating character sprite data for $*..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-chaos-character "$@" "$<"

# Convert Numbers PNG to batariBASIC data using SkylineTool
Source/Generated/Numbers.bas: Source/Art/Numbers.png bin/skyline-tool
	@echo "Converting Numbers font $< to $@..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-font-8x16 "$@" "$<"

# Convert 48×42 PNG to titlescreen kernel assembly format
# Uses compile-batari-48px with titlescreen-kernel-p flag for color-per-line + double-height
# These are bitmaps for the titlescreen kernel minikernels, not playfield data
# PNG files are built from XCF via the %.png: %.xcf pattern rule (line 180)
# Explicit PNG→XCF dependencies ensure XCF→PNG conversion happens first
Source/Art/AtariAge.png: Source/Art/AtariAge.xcf
Source/Art/Interworldly.png: Source/Art/Interworldly.xcf
Source/Art/ChaosFight.png: Source/Art/ChaosFight.xcf

# Titlescreen kernel bitmap conversion: PNG → .s (assembly format)
Source/Generated/Art.AtariAge.s: Source/Art/AtariAge.png bin/skyline-tool
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-batari-48px "$<" "$@" "t" "NTSC"

Source/Generated/Art.Interworldly.s: Source/Art/Interworldly.png bin/skyline-tool
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-batari-48px "$<" "$@" "t" "NTSC"

Source/Generated/Art.ChaosFight.s: Source/Art/ChaosFight.png bin/skyline-tool
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-batari-48px "$<" "$@" "t" "NTSC"

# Convert XCF to PNG for maps
Source/Art/Map-%.png: Source/Art/Map-%.xcf
	$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'

# Convert PNG font to batariBASIC data
Source/Generated/Font.bas: Source/Art/Font.png
	@echo "Converting font $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-8x16-font "$<" > "$@" 

# Build game - accurate dependencies based on actual includes
Source/Generated/$(GAME).NTSC.bas: Source/Platform/NTSC.bas characters bitmaps
	mkdir -p Source/Generated
	cpp -P -I. -DBUILD_DATE=$(shell date +%Y.%j) $< > $@

Source/Generated/$(GAME).PAL.bas: Source/Platform/PAL.bas characters bitmaps
	mkdir -p Source/Generated
	cpp -P -I. -DBUILD_DATE=$(shell date +%Y.%j) $< > $@

Source/Generated/$(GAME).SECAM.bas: Source/Platform/SECAM.bas characters bitmaps
	mkdir -p Source/Generated
	cpp -P -I. -DBUILD_DATE=$(shell date +%Y.%j) $< > $@

# Shared dependencies for all TV standards
BUILD_DEPS = $(ALL_SOURCES) \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	Source/Banks/Bank1.bas \
	Source/Banks/Banks.bas \
	Source/Common/Colors.h \
	Source/Common/Constants.bas \
	Source/Common/Macros.bas \
	Source/Common/Preamble.bas \
	Source/Common/Variables.bas \
	Source/Data/SpecialSprites.bas \
	Source/Routines/CharacterArt.s \
	Source/Routines/ColdStart.bas \
	Source/Routines/ControllerDetection.bas \
	Source/Routines/FallingAnimation.bas \
	Source/Routines/GameLoopInit.bas \
	Source/Routines/GameLoopMain.bas \
	Source/Routines/HealthBarSystem.bas \
	Source/Routines/LevelSelect.bas \
	Source/Routines/MainLoop.bas \
	Source/Routines/MusicSystem.bas \
	Source/Routines/ScreenLayout.bas \
	Source/Routines/SoundSystem.bas \
	Source/Routines/SpriteLoader.bas \
	Source/Routines/VisualEffects.bas \
	Source/Generated/Numbers.bas \
	$(foreach bitmap,$(BITMAP_NAMES),Source/Generated/Art.$(bitmap).s)

# Step 1: Preprocess .bas → .preprocessed.bas
Source/Generated/$(GAME).NTSC.preprocessed.bas: Source/Generated/$(GAME).NTSC.bas $(BUILD_DEPS)
	mkdir -p Source/Generated
	bin/preprocess < $< > $@

Source/Generated/$(GAME).PAL.preprocessed.bas: Source/Generated/$(GAME).PAL.bas $(BUILD_DEPS)
	mkdir -p Source/Generated
	bin/preprocess < $< > $@

Source/Generated/$(GAME).SECAM.preprocessed.bas: Source/Generated/$(GAME).SECAM.bas $(BUILD_DEPS) Source/Common/AssemblyConfig.SECAM.s
	mkdir -p Source/Generated
	bin/preprocess < $< > $@

# Step 2: Compile .preprocessed.bas → bB.ARCH.s
Object/bB.NTSC.s: Source/Generated/$(GAME).NTSC.preprocessed.bas Source/Common/variableRedefs.h
	mkdir -p Object
	cd Object && ../bin/2600basic -i $(POSTINC) -r ../Source/Common/variableRedefs.h < ../$< > $@

Object/bB.PAL.s: Source/Generated/$(GAME).PAL.preprocessed.bas Source/Common/variableRedefs.h
	mkdir -p Object
	cd Object && ../bin/2600basic -i $(POSTINC) -r ../Source/Common/variableRedefs.h < ../$< > $@

Object/bB.SECAM.s: Source/Generated/$(GAME).SECAM.preprocessed.bas Source/Common/variableRedefs.h
	mkdir -p Object
	cd Object && ../bin/2600basic -i $(POSTINC) -r ../Source/Common/variableRedefs.h < ../$< > $@

# Step 3: Postprocess bB.ARCH.s → ARCH.s (final assembly)
Source/Generated/$(GAME).NTSC.s: Object/bB.NTSC.s
	mkdir -p Source/Generated
	bin/postprocess -i $(POSTINC) < $< | bin/optimize | sed 's/\.,-1/.-1/g' > $@

Source/Generated/$(GAME).PAL.s: Object/bB.PAL.s
	mkdir -p Source/Generated
	bin/postprocess -i $(POSTINC) < $< | bin/optimize | sed 's/\.,-1/.-1/g' > $@

Source/Generated/$(GAME).SECAM.s: Object/bB.SECAM.s
	mkdir -p Source/Generated
	bin/postprocess -i $(POSTINC) < $< | bin/optimize | sed 's/\.,-1/.-1/g' > $@

# Step 4: Assemble ARCH.s → ARCH.a26 + ARCH.lst + ARCH.sym
Dist/$(GAME).NTSC.a26 Dist/$(GAME).NTSC.sym Dist/$(GAME).NTSC.lst: Source/Generated/$(GAME).NTSC.s
	mkdir -p Dist
	bin/dasm $< -ITools/batariBASIC/includes -ISource -ISource/Common -f3 -lDist/$(GAME).NTSC.lst -sDist/$(GAME).NTSC.sym -oDist/$(GAME).NTSC.a26

Dist/$(GAME).PAL.a26 Dist/$(GAME).PAL.sym Dist/$(GAME).PAL.lst: Source/Generated/$(GAME).PAL.s
	mkdir -p Dist
	bin/dasm $< -ITools/batariBASIC/includes -ISource -ISource/Common -f3 -lDist/$(GAME).PAL.lst -sDist/$(GAME).PAL.sym -oDist/$(GAME).PAL.a26

Dist/$(GAME).SECAM.a26 Dist/$(GAME).SECAM.sym Dist/$(GAME).SECAM.lst: Source/Generated/$(GAME).SECAM.s
	mkdir -p Dist
	bin/dasm $< -ITools/batariBASIC/includes -ISource -ISource/Common -f3 -lDist/$(GAME).SECAM.lst -sDist/$(GAME).SECAM.sym -oDist/$(GAME).SECAM.a26

# Run emulator
emu: $(ROM)
	$(STELLA) $(ROM)

# Clean all generated files
clean:
	rm -rf Dist/*
	rm -rf Object/*
	rm -f Source/Generated/*
	rm -f Source/Art/*.png
	rm -f bB.*.s *.bin *.lst *.sym *.map *.pro
	rm -f Source/Generated/$(GAME).*.bas Source/Generated/$(GAME).*.s
	rm -f Source/Generated/$(GAME).*.preprocessed.bas
	rm -f Object/bB.*.s Object/includes.bB
	cd Tools/batariBASIC && git clean --force

# Install GIMP export script
gimp-export:
	@for d in ~/.config/GIMP/*/scripts/; do \
		if [ -d "$$d" ]; then \
			cp Tools/xcf-export.scm "$$d"; \
			echo "Installed xcf-export.scm to $$d"; \
		fi \
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
	@echo "  ready        - Setup development environment and dependencies"
	@echo "  nowready     - Check if development environment is ready"
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

# Documentation generation
Dist/$(GAME).pdf: Manual/ChaosFight.texi
	makeinfo --pdf --output=$@ $<

Dist/$(GAME).html: Manual/ChaosFight.texi
	makeinfo --html --output=$@ $<

nowready: $(READYFILE)

$(READYFILE):
	$(MAKE) ready

ready: gimp-export bin/skyline-tool
	# Mark ready
	@echo "Development environment ready for ChaosFight build"
	touch $(READYFILE)
