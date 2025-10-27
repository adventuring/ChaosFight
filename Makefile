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
GENERATED_DIR = Source/Generated
OBJECT_DIR = Object
DIST_DIR = Dist

# Output files
GAME = ChaosFight
ROM = Dist/$(GAME).NTSC.a26

# Assembly files
ALL_SOURCES = $(shell find Source -name \*.bas) $(GENERATED_DIR)/Characters.bas $(GENERATED_DIR)/Playfields.bas $(CHARACTER_BAS)

# Default target
.PHONY: all clean emu game help doc characters playfields
all: game doc characters playfields

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

doc: Dist/$(GAME).pdf

# Character sprite sheet names (16 characters)
CHARACTER_NAMES = Bernie CurlingSweeper Dragonet EXOPilot FatTony GrizzardHandler Harpy KnightGuy MagicalFaerie MysteryMan NinjishGuy PorkChop RadishGoblin RoboTito Ursulo VegDog

# TV architectures
TV_ARCHS = NTSC PAL SECAM

# Build character assets
characters: $(GENERATED_DIR)/Characters.bas $(foreach char,$(CHARACTER_NAMES),$(foreach arch,$(TV_ARCHS),$(GENERATED_DIR)/Art.$(char).$(arch).bas))

# Build playfield assets
playfields: $(GENERATED_DIR)/Playfields.bas

# Generate list of character sprite files
CHARACTER_XCF = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).xcf)
CHARACTER_PNG = $(foreach char,$(CHARACTER_NAMES),Source/Art/$(char).png)
CHARACTER_BAS = $(foreach char,$(CHARACTER_NAMES),$(foreach arch,$(TV_ARCHS),$(GENERATED_DIR)/Art.$(char).$(arch).bas))

# Convert XCF to PNG for character sprites
Source/Art/%.png: Source/Art/%.xcf
	@echo "Converting $< to $@..."
	mkdir -p Source/Art
	magick "$<" "$@"

# Convert PNG character sprite sheet to batariBASIC data for NTSC
$(GENERATED_DIR)/Art.%.NTSC.bas: Source/Art/%.png
	@echo "Converting character sprite $< to $@ for NTSC..."
	mkdir -p $(GENERATED_DIR)
	bin/skyline-tool compile-2600-character \
		:input "$<" \
		:output "$@" \
		:character-name "$*" \
		:architecture "NTSC" \
		:width 8 \
		:height 16 \
		:frames 8 \
		:sequences 16 \
		:detect-duplicates t \
		:omit-blank-frames t \
		:refpn-left-facing t

# Convert PNG character sprite sheet to batariBASIC data for PAL
$(GENERATED_DIR)/Art.%.PAL.bas: Source/Art/%.png
	@echo "Converting character sprite $< to $@ for PAL..."
	mkdir -p $(GENERATED_DIR)
	bin/skyline-tool compile-2600-character \
		:input "$<" \
		:output "$@" \
		:character-name "$*" \
		:architecture "PAL" \
		:width 8 \
		:height 16 \
		:frames 8 \
		:sequences 16 \
		:detect-duplicates t \
		:omit-blank-frames t \
		:refpn-left-facing t

# Convert PNG character sprite sheet to batariBASIC data for SECAM
$(GENERATED_DIR)/Art.%.SECAM.bas: Source/Art/%.png
	@echo "Converting character sprite $< to $@ for SECAM..."
	mkdir -p $(GENERATED_DIR)
	bin/skyline-tool compile-2600-character \
		:input "$<" \
		:output "$@" \
		:character-name "$*" \
		:architecture "SECAM" \
		:width 8 \
		:height 16 \
		:frames 8 \
		:sequences 16 \
		:detect-duplicates t \
		:omit-blank-frames t \
		:refpn-left-facing t

# Consolidate all character sprite data (architecture-agnostic)
$(GENERATED_DIR)/Characters.bas: $(CHARACTER_BAS)
	@echo "Consolidating character data..."
	mkdir -p $(GENERATED_DIR)
	@echo "          rem ChaosFight - Generated Character Sprite Data" > $@
	@echo "          rem Copyright © 2025 Interworldly Adventuring, LLC." >> $@
	@echo "" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          rem CHARACTER SPRITE DATA" >> $@
	@echo "          rem =========================================================================" >> $@
	@echo "          rem This file includes all character sprite data compiled from XCF sources" >> $@
	@echo "          rem Each character is 64px wide (8 frames) × 256px tall (16 sequences)" >> $@
	@echo "          rem Facing right by default, use REFPn to reflect for face-left" >> $@
	@echo "          rem Duplicate frames are detected and re-used, blank frames are omitted" >> $@
	@echo "" >> $@
	@for file in $(CHARACTER_BAS); do \
		if [ -f $$file ]; then \
			echo "          rem Including $$(basename $$file)" >> $@; \
			sed 's/^/          /' $$file >> $@; \
			echo "" >> $@; \
		fi; \
	done

# Convert XCF to PNG for maps
Source/Art/Map-%.png: Source/Art/Map-%.xcf
	magick "$<" -background none -flatten "$@"

# Convert PNG to batariBASIC playfield include
$(GENERATED_DIR)/Playfields.bas: $(wildcard Source/Art/Map-*.png)
	mkdir -p $(GENERATED_DIR)
	bin/skyline-tool compile-playfields $(GENERATED_DIR) $(wildcard Source/Art/Map-*.png)

# Build game
Dist/$(GAME).NTSC.a26 Dist/$(GAME).NTSC.sym Dist/$(GAME).NTSC.lst: $(ALL_SOURCES)
	mkdir -p Dist $(GENERATED_DIR)
	cpp -P -I. Source/Platform/NTSC.bas > $(GENERATED_DIR)/$(GAME).NTSC.bas
	bin/preprocess < $(GENERATED_DIR)/$(GAME).NTSC.bas > $(GENERATED_DIR)/$(GAME).NTSC.preprocessed.bas
	bin/2600basic -i Tools/batariBASIC -r Tools/batariBASIC/includes/variable_redefs.h $(GENERATED_DIR)/$(GAME).NTSC.preprocessed.bas > $(GENERATED_DIR)/$(GAME).NTSC.bB.s
	cp $(GENERATED_DIR)/$(GAME).NTSC.bB.s $(GENERATED_DIR)/$(GAME).NTSC.bB.asm
	bin/postprocess -i Tools/batariBASIC < $(GENERATED_DIR)/$(GAME).NTSC.bB.asm > $(GENERATED_DIR)/$(GAME).NTSC.s
	bin/dasm $(GENERATED_DIR)/$(GAME).NTSC.s -ITools/batariBASIC/includes -f3 -lDist/$(GAME).NTSC.lst -sDist/$(GAME).NTSC.sym -oDist/$(GAME).NTSC.a26
	rm -f $(GENERATED_DIR)/$(GAME).NTSC.bB.s $(GENERATED_DIR)/$(GAME).NTSC.bB.asm $(GENERATED_DIR)/$(GAME).NTSC.s $(GENERATED_DIR)/$(GAME).NTSC.preprocessed.bas

Dist/$(GAME).PAL.a26 Dist/$(GAME).PAL.sym Dist/$(GAME).PAL.lst: $(ALL_SOURCES)
	mkdir -p Dist $(GENERATED_DIR)
	cpp -P -I. Source/Platform/PAL.bas > $(GENERATED_DIR)/$(GAME).PAL.bas
	bin/preprocess < $(GENERATED_DIR)/$(GAME).PAL.bas > $(GENERATED_DIR)/$(GAME).PAL.preprocessed.bas
	bin/2600basic -i Tools/batariBASIC -r Tools/batariBASIC/includes/variable_redefs.h $(GENERATED_DIR)/$(GAME).PAL.preprocessed.bas > $(GENERATED_DIR)/$(GAME).PAL.bB.s
	cp $(GENERATED_DIR)/$(GAME).PAL.bB.s $(GENERATED_DIR)/$(GAME).PAL.bB.asm
	bin/postprocess -i Tools/batariBASIC < $(GENERATED_DIR)/$(GAME).PAL.bB.asm > $(GENERATED_DIR)/$(GAME).PAL.s
	bin/dasm $(GENERATED_DIR)/$(GAME).PAL.s -ITools/batariBASIC/includes -f3 -lDist/$(GAME).PAL.lst -sDist/$(GAME).PAL.sym -oDist/$(GAME).PAL.a26
	rm -f $(GENERATED_DIR)/$(GAME).PAL.bB.s $(GENERATED_DIR)/$(GAME).PAL.bB.asm $(GENERATED_DIR)/$(GAME).PAL.s $(GENERATED_DIR)/$(GAME).PAL.preprocessed.bas

Dist/$(GAME).SECAM.a26 Dist/$(GAME).SECAM.sym Dist/$(GAME).SECAM.lst: $(ALL_SOURCES)
	mkdir -p Dist $(GENERATED_DIR)
	cpp -P -I. Source/Platform/SECAM.bas > $(GENERATED_DIR)/$(GAME).SECAM.bas
	bin/preprocess < $(GENERATED_DIR)/$(GAME).SECAM.bas > $(GENERATED_DIR)/$(GAME).SECAM.preprocessed.bas
	bin/2600basic -i Tools/batariBASIC -r Tools/batariBASIC/includes/variable_redefs.h $(GENERATED_DIR)/$(GAME).SECAM.preprocessed.bas > $(GENERATED_DIR)/$(GAME).SECAM.bB.s
	cp $(GENERATED_DIR)/$(GAME).SECAM.bB.s $(GENERATED_DIR)/$(GAME).SECAM.bB.asm
	bin/postprocess -i Tools/batariBASIC < $(GENERATED_DIR)/$(GAME).SECAM.bB.asm > $(GENERATED_DIR)/$(GAME).SECAM.s
	bin/dasm $(GENERATED_DIR)/$(GAME).SECAM.s -ITools/batariBASIC/includes -f3 -lDist/$(GAME).SECAM.lst -sDist/$(GAME).SECAM.sym -oDist/$(GAME).SECAM.a26
	rm -f $(GENERATED_DIR)/$(GAME).SECAM.bB.s $(GENERATED_DIR)/$(GAME).SECAM.bB.asm $(GENERATED_DIR)/$(GAME).SECAM.s $(GENERATED_DIR)/$(GAME).SECAM.preprocessed.bas

# Run emulator
emu: $(ROM)
	$(STELLA) $(ROM)

# Clean all generated files
clean:
	rm -rf Dist/*.a26
	rm -rf Object/*
	rm -f $(GENERATED_DIR)/*.s
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
	@echo "  all         - Build game (default)"
	@echo "  game        - Build game"
	@echo "  clean       - Remove all generated files"
	@echo "  emu         - Build and run in Stella emulator"
	@echo "  gimp-export - Install GIMP export script"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Distributable files in Dist/"

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

