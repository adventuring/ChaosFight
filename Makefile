# Default target
all: game doc

# Test target
test: SkylineTool/skyline-tool.asd
	@echo "Running SkylineTool fiveam tests..."
	cd SkylineTool && sbcl --script tests/run-tests.lisp || (echo "Tests failed!" && exit 1)

# Precious intermediate files
.PRECIOUS: %.s %.png %.midi Object/bB.%.s Source/Generated/$(GAME).%.preprocessed.bas

# Don't delete PNG files automatically - they are intermediate but should be preserved
# between builds if XCF hasn't changed
.SECONDARY: $(CHARACTER_PNG) $(foreach bitmap,$(BITMAP_NAMES),Source/Art/$(bitmap).png)

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
READYDATE = 20251104
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
GAMEYEAR = 25
ROM = Dist/$(GAME)$(GAMEYEAR).NTSC.a26

# Assembly files (exclude preprocessed and generated files)
ALL_SOURCES = $(shell find Source -name \*.bas -not -path "Source/Generated/*")

.PHONY: all clean emu game help doc characters fonts sprites nowready ready bitmaps

# Build game
game: \
	Dist/$(GAME)$(GAMEYEAR).NTSC.a26 \
	Dist/$(GAME)$(GAMEYEAR).PAL.a26 \
	Dist/$(GAME)$(GAMEYEAR).SECAM.a26 \
	Dist/$(GAME)$(GAMEYEAR).NTSC.sym \
	Dist/$(GAME)$(GAMEYEAR).PAL.sym \
	Dist/$(GAME)$(GAMEYEAR).SECAM.sym \
	Dist/$(GAME)$(GAMEYEAR).NTSC.lst \
	Dist/$(GAME)$(GAMEYEAR).PAL.lst \
	Dist/$(GAME)$(GAMEYEAR).SECAM.lst \
	Dist/$(GAME)$(GAMEYEAR).NTSC.pro \
	Dist/$(GAME)$(GAMEYEAR).PAL.pro \
	Dist/$(GAME)$(GAMEYEAR).SECAM.pro

doc: Dist/$(GAME)$(GAMEYEAR).pdf Dist/$(GAME)$(GAMEYEAR).html

# Character sprite sheet names (32 characters: 16 main + 16 future)
CHARACTER_NAMES = \
	Bernie Curler DragonOfStorms ZoeRyen FatTony Megax Harpy KnightGuy \
	Frooty Nefertem NinjishGuy PorkChop RadishGoblin RoboTito Ursulo Shamone \
	Character16 Character17 Character18 Character19 Character20 Character21 Character22 Character23 \
	Character24 Character25 Character26 Character27 Character28 Character29 Character30 MethHound

# TV architectures
TV_ARCHS = NTSC PAL SECAM

# Bitmap names (48×42 bitmaps for titlescreen kernel)
BITMAP_NAMES = AtariAge AtariAgeText Interworldly ChaosFight

# Font names
FONT_NAMES = Numbers

# Music names (MuseScore files)
MUSIC_NAMES = AtariToday Interworldly Victory GameOver

# Game-based character theme songs
# Note: Must have 32 songs (one per character) - use placeholder for missing characters
GAME_THEME_SONGS = Grizzards Phantasia EXO OCascadia MagicalFairyForce Bernie Havoc Harpy LowRes Bolero RoboTito DucksAway SongOfTheBear \
	Character16Theme Character17Theme Character18Theme Character19Theme Character20Theme Character21Theme Character22Theme Character23Theme \
	Character24Theme Character25Theme Character26Theme Character27Theme Character28Theme Character29Theme Character30Theme MethHoundTheme

# Sound effect names (MIDI files)
SOUND_NAMES = SoundAttackHit SoundGuardBlock SoundJump SoundPlayerEliminated \
	SoundMenuNavigate SoundMenuSelect SoundSpecialMove SoundPowerup \
	SoundLandingSafe SoundLandingDamage

# Build character assets
characters: $(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas)

# Build bitmap assets (48×42 for titlescreen kernel on admin screens)
bitmaps: $(foreach bitmap,$(BITMAP_NAMES),Source/Generated/Art.$(bitmap).s)

# Build font assets (fonts are universal, not region-specific)
fonts: $(foreach font,$(FONT_NAMES),Source/Generated/$(font).bas)

# Build music assets
music: $(foreach song,$(MUSIC_NAMES),$(foreach arch,$(TV_ARCHS),Source/Generated/Song.$(song).$(arch).bas)) \
       $(foreach song,$(GAME_THEME_SONGS),$(foreach arch,$(TV_ARCHS),Source/Generated/Song.$(song).$(arch).bas))

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
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
Source/Generated/Song.%.NTSC.bas: Source/Songs/%.midi bin/skyline-tool
	@echo "Converting music $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "60" "$@"

# Convert MIDI to batariBASIC music data for PAL (50Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
Source/Generated/Song.%.PAL.bas: Source/Songs/%.midi bin/skyline-tool
	@echo "Converting music $< to $@ for PAL..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"

# Convert MIDI to batariBASIC music data for SECAM (50Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
Source/Generated/Song.%.SECAM.bas: Source/Generated/Song.%.PAL.bas
	@echo "SECAM uses PAL music files (same frame rate)"
	cp "$<" "$@"

# Sound effect files use Sound. prefix instead of Song. prefix
# Convert MIDI to batariBASIC sound data for NTSC (60Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
Source/Generated/Sound.%.NTSC.bas: Source/Songs/%.midi bin/skyline-tool
	@echo "Converting sound $< to $@ for NTSC..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "60" "$@"

# Convert MIDI to batariBASIC sound data for PAL (50Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
Source/Generated/Sound.%.PAL.bas: Source/Songs/%.midi bin/skyline-tool
	@echo "Converting sound $< to $@ for PAL..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"

# Convert MIDI to batariBASIC sound data for SECAM (50Hz)
# MIDI files are generated from MSCZ via %.midi: %.mscz pattern rule
# SECAM uses same frame rate as PAL but may have different timing requirements
Source/Generated/Sound.%.SECAM.bas: Source/Songs/%.midi bin/skyline-tool
	@echo "Converting sound $< to $@ for SECAM..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-midi "$<" "batariBASIC" "50" "$@"



# Generate list of character sprite files
CHARACTER_XCF = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).xcf)
CHARACTER_PNG = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).png)
CHARACTER_BAS = $(foreach char,$(CHARACTER_NAMES),Source/Generated/Art.$(char).bas)

# Convert XCF to PNG for sprites (characters and special sprites)
# Make will only regenerate if XCF is newer than PNG (based on file timestamps)
# Touch PNG after generation to ensure it's newer than XCF (handles filesystem precision issues)
%.png: %.xcf
	@echo "Converting $< to $@..."
	@mkdir -p Source/Art
	@$(GIMP) -b '(xcf-export "$<" "$@")' -b '(gimp-quit 0)'
	@touch "$@"

# Character sprites are compiled using compile-chaos-character
# Special sprites (QuestionMark, CPU, No) are hard-coded in Source/Data/SpecialSprites.bas

# Explicit PNG dependencies for character sprites (ensures PNG generation from XCF)
$(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).png): Source/Art/%.png: Source/Art/%.xcf

# Generate character sprite files from PNG using chaos character compiler
# PNG files are generated from XCF via %.png: %.xcf pattern rule or explicit rules above
$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas): Source/Generated/%.bas: Source/Art/%.png bin/skyline-tool                                      
	@echo "Generating character sprite data for $*..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-chaos-character "$@" "$<"

# Convert Numbers PNG to batariBASIC data using SkylineTool
# PNG files are generated from XCF via %.png: %.xcf pattern rule
Source/Generated/Numbers.bas: Source/Art/Numbers.png bin/skyline-tool
	@echo "Converting Numbers font $< to $@..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-2600-font-8x16 "$@" "$<"

# Fonts are universal (not TV-specific)
# Source/Generated/Numbers.bas is used directly by FontRendering.bas

# Convert 48×42 PNG to titlescreen kernel assembly format
# Uses compile-batari-48px with titlescreen-kernel-p flag for color-per-line + double-height
# These are bitmaps for the titlescreen kernel minikernels, not playfield data
# PNG files are built from XCF via the %.png: %.xcf pattern rule (line 180)
# Explicit PNG→XCF dependencies ensure XCF→PNG conversion happens first
Source/Art/AtariAge.png: Source/Art/AtariAge.xcf
Source/Art/Interworldly.png: Source/Art/Interworldly.xcf
Source/Art/ChaosFight.png: Source/Art/ChaosFight.xcf

# Titlescreen kernel bitmap conversion: PNG → .s (assembly format)
# PNG files are generated from XCF via %.png: %.xcf pattern rule
Source/Generated/Art.AtariAge.s: Source/Art/AtariAge.png bin/skyline-tool
	@echo "Converting 48×42 bitmap $< to titlescreen kernel $@..."
	mkdir -p Source/Generated
	bin/skyline-tool compile-batari-48px "$<" "$@" "t" "NTSC"

Source/Generated/Art.AtariAgeText.s: Source/Art/AtariAgeText.png bin/skyline-tool
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
Source/Generated/$(GAME).NTSC.bas: Source/Platform/NTSC.bas \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	$(foreach bitmap,$(BITMAP_NAMES),Source/Generated/Art.$(bitmap).s) \
	$(foreach font,$(FONT_NAMES),Source/Generated/$(font).bas)
	mkdir -p Source/Generated
	cpp -P -I. -DBUILD_DATE=$(shell date +%j) -Wno-trigraphs -Wno-format $< > $@

Source/Generated/$(GAME).PAL.bas: Source/Platform/PAL.bas \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	$(foreach bitmap,$(BITMAP_NAMES),Source/Generated/Art.$(bitmap).s) \
	$(foreach font,$(FONT_NAMES),Source/Generated/$(font).bas)
	mkdir -p Source/Generated
	cpp -P -I. -DBUILD_DATE=$(shell date +%j) -Wno-trigraphs -Wno-format $< > $@

Source/Generated/$(GAME).SECAM.bas: Source/Platform/SECAM.bas \
	$(foreach char,$(CHARACTER_NAMES),Source/Generated/$(char).bas) \
	$(foreach bitmap,$(BITMAP_NAMES),Source/Generated/Art.$(bitmap).s) \
	$(foreach font,$(FONT_NAMES),Source/Generated/$(font).bas)
	mkdir -p Source/Generated
	cpp -P -I. -DBUILD_DATE=$(shell date +%j) -Wno-trigraphs -Wno-format $< > $@

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
	Source/Generated/Numbers.bas \
	$(foreach bitmap,$(BITMAP_NAMES),Source/Generated/Art.$(bitmap).s) \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).NTSC.bas) \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).PAL.bas) \
	$(foreach sound,$(SOUND_NAMES),Source/Generated/Sound.$(sound).SECAM.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).NTSC.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).PAL.bas) \
	$(foreach song,$(MUSIC_NAMES),Source/Generated/Song.$(song).SECAM.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).NTSC.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).PAL.bas) \
	$(foreach song,$(GAME_THEME_SONGS),Source/Generated/Song.$(song).SECAM.bas)

# Step 1: Preprocess .bas → .preprocessed.bas
Source/Generated/$(GAME).NTSC.preprocessed.bas: Source/Generated/$(GAME).NTSC.bas $(BUILD_DEPS)
	mkdir -p Source/Generated
	bin/preprocess < $< > $@

Source/Generated/$(GAME).PAL.preprocessed.bas: Source/Generated/$(GAME).PAL.bas $(BUILD_DEPS)
	mkdir -p Source/Generated
	bin/preprocess < $< > $@

Source/Generated/$(GAME).SECAM.preprocessed.bas: Source/Generated/$(GAME).SECAM.bas $(BUILD_DEPS)
	mkdir -p Source/Generated
	bin/preprocess < $< > $@

# Create empty variable redefs file if it doesn't exist (will be populated by batariBASIC)
Source/Common/VariableRedefinitions.h:
	@mkdir -p Source/Common
	@touch $@

# Step 2: Compile .preprocessed.bas → bB.ARCH.s
Object/bB.NTSC.s: Source/Generated/$(GAME).NTSC.preprocessed.bas Source/Common/VariableRedefinitions.h
	mkdir -p Object
	cd Object && ../bin/2600basic -i $(POSTINC) -r ../Source/Common/VariableRedefinitions.h < ../Source/Generated/$(GAME).NTSC.preprocessed.bas > bB.NTSC.s

Object/bB.PAL.s: Source/Generated/$(GAME).PAL.preprocessed.bas Source/Common/VariableRedefinitions.h
	mkdir -p Object
	cd Object && ../bin/2600basic -i $(POSTINC) -r ../Source/Common/VariableRedefinitions.h < ../Source/Generated/$(GAME).PAL.preprocessed.bas > bB.PAL.s

Object/bB.SECAM.s: Source/Generated/$(GAME).SECAM.preprocessed.bas Source/Common/VariableRedefinitions.h
	mkdir -p Object
	cd Object && ../bin/2600basic -i $(POSTINC) -r ../Source/Common/VariableRedefinitions.h < ../Source/Generated/$(GAME).SECAM.preprocessed.bas > bB.SECAM.s

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
Dist/$(GAME)$(GAMEYEAR).NTSC.a26 Dist/$(GAME)$(GAMEYEAR).NTSC.sym Dist/$(GAME)$(GAMEYEAR).NTSC.lst: Source/Generated/$(GAME).NTSC.s
	mkdir -p Dist
	bin/dasm $< -ITools/batariBASIC/includes -ISource -ISource/Common -f3 -lDist/$(GAME)$(GAMEYEAR).NTSC.lst -sDist/$(GAME)$(GAMEYEAR).NTSC.sym -oDist/$(GAME)$(GAMEYEAR).NTSC.a26

Dist/$(GAME)$(GAMEYEAR).PAL.a26 Dist/$(GAME)$(GAMEYEAR).PAL.sym Dist/$(GAME)$(GAMEYEAR).PAL.lst: Source/Generated/$(GAME).PAL.s
	mkdir -p Dist
	bin/dasm $< -ITools/batariBASIC/includes -ISource -ISource/Common -f3 -lDist/$(GAME)$(GAMEYEAR).PAL.lst -sDist/$(GAME)$(GAMEYEAR).PAL.sym -oDist/$(GAME)$(GAMEYEAR).PAL.a26

Dist/$(GAME)$(GAMEYEAR).SECAM.a26 Dist/$(GAME)$(GAMEYEAR).SECAM.sym Dist/$(GAME)$(GAMEYEAR).SECAM.lst: Source/Generated/$(GAME).SECAM.s
	mkdir -p Dist
	bin/dasm $< -ITools/batariBASIC/includes -ISource -ISource/Common -f3 -lDist/$(GAME)$(GAMEYEAR).SECAM.lst -sDist/$(GAME)$(GAMEYEAR).SECAM.sym -oDist/$(GAME)$(GAMEYEAR).SECAM.a26

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
	@echo "  Dist/ChaosFight25.pdf        - Game manual (PDF)"
	@echo "  Dist/ChaosFight25.html       - Game manual (HTML)"
	@echo "  Dist/ChaosFight25.NTSC.a26   - NTSC ROM"
	@echo "  Dist/ChaosFight25.PAL.a26    - PAL ROM"
	@echo "  Dist/ChaosFight25.SECAM.a26  - SECAM ROM"

# Generate Stella .pro files
Dist/$(GAME)$(GAMEYEAR).NTSC.pro: Source/$(GAME).pro Dist/$(GAME)$(GAMEYEAR).NTSC.a26
	sed $< -e s/@@TV@@/NTSC/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME)$(GAMEYEAR).NTSC.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME)$(GAMEYEAR).PAL.pro: Source/$(GAME).pro Dist/$(GAME)$(GAMEYEAR).PAL.a26
	sed $< -e s/@@TV@@/PAL/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME)$(GAMEYEAR).PAL.a26 | cut -d\  -f1)/g > $@

Dist/$(GAME)$(GAMEYEAR).SECAM.pro: Source/$(GAME).pro Dist/$(GAME)$(GAMEYEAR).SECAM.a26
	sed $< -e s/@@TV@@/SECAM/g \
		-e s/@@MD5@@/$$(md5sum Dist/$(GAME)$(GAMEYEAR).SECAM.a26 | cut -d\  -f1)/g > $@

# Documentation generation
# Build PDF in Object/ to contain auxiliary files (.aux, .cp, .cps, .toc)
Dist/$(GAME)$(GAMEYEAR).pdf: Manual/ChaosFight.texi
	mkdir -p Object Dist
	makeinfo --pdf --output=Object/$(GAME)$(GAMEYEAR).pdf $<
	cp Object/$(GAME)$(GAMEYEAR).pdf $@

Dist/$(GAME)$(GAMEYEAR).html: Manual/ChaosFight.texi
	mkdir -p Dist
	makeinfo --html --output=$@ $<

nowready: $(READYFILE)

$(READYFILE):
	$(MAKE) ready

ready: gimp-export bin/skyline-tool
	# Mark ready
	@echo "Development environment ready for ChaosFight build"
	touch $(READYFILE)
