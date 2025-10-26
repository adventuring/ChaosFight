# ===========================================================================
# ChaosFight - Makefile
# ===========================================================================
# This Makefile compiles the batariBASIC game to multiple TV standards
# and provides targets for building, cleaning, and running the game.
# ===========================================================================

# Tools and directories
BB = Tools/batariBASIC/2600basic.sh
DASM = Tools/dasm-binary
STELLA = stella
WASMTIME = ~/.wasmtime/bin/wasmtime
SOURCE_DIR = .
BANKS_DIR = Source/Banks
COMMON_DIR = Source/Common
GENERATED_DIR = Source/Generated
OBJECT_DIR = Object
DIST_DIR = Dist

# Source files
MAIN_SOURCE = ChaosFight.bas
BANK_SOURCES = $(BANKS_DIR)/Bank00.bas
COMMON_SOURCES = $(COMMON_DIR)/Constants.bas $(COMMON_DIR)/Macros.bas

# Output files
BASENAME = ChaosFight
NTSC_ROM = $(DIST_DIR)/$(BASENAME).NTSC.a26
PAL_ROM = $(DIST_DIR)/$(BASENAME).PAL.a26
SECAM_ROM = $(DIST_DIR)/$(BASENAME).SECAM.a26

# Assembly files
ASM_FILE = $(GENERATED_DIR)/$(BASENAME).asm
LIST_FILE = $(OBJECT_DIR)/$(BASENAME).lst
SYMBOL_FILE = $(OBJECT_DIR)/$(BASENAME).sym

# Default target
.PHONY: all clean emu game help
all: game

# Build all ROM variants
game: $(NTSC_ROM) $(PAL_ROM) $(SECAM_ROM)
	@echo "All ROM variants built successfully"

# Build NTSC version (default)
$(NTSC_ROM): $(MAIN_SOURCE) $(BANK_SOURCES) $(COMMON_SOURCES) | $(DIST_DIR) $(OBJECT_DIR) $(GENERATED_DIR)
	@echo "Building NTSC version..."
	@sed 's/set tv .*/set tv ntsc/' $(MAIN_SOURCE) > $(GENERATED_DIR)/temp_ntsc.bas
	@cp $(GENERATED_DIR)/temp_ntsc.bas $(GENERATED_DIR)/$(BASENAME).bas
	@bB=Tools/batariBASIC $(BB) $(GENERATED_DIR)/$(BASENAME).bas -O
	$(DASM) $(ASM_FILE) -f3 -o$(NTSC_ROM) -l$(LIST_FILE) -s$(SYMBOL_FILE) -M$(OBJECT_DIR)/$(BASENAME).map
	@rm -f $(GENERATED_DIR)/temp_ntsc.bas $(GENERATED_DIR)/$(BASENAME).bas
	@echo "NTSC ROM created: $(NTSC_ROM)"

# Build PAL version
$(PAL_ROM): $(MAIN_SOURCE) $(BANK_SOURCES) $(COMMON_SOURCES) | $(DIST_DIR) $(OBJECT_DIR) $(GENERATED_DIR)
	@echo "Building PAL version..."
	@sed 's/set tv .*/set tv pal/' $(MAIN_SOURCE) > $(GENERATED_DIR)/temp_pal.bas
	@cp $(GENERATED_DIR)/temp_pal.bas $(GENERATED_DIR)/$(BASENAME).bas
	@bB=Tools/batariBASIC $(BB) $(GENERATED_DIR)/$(BASENAME).bas -O
	$(DASM) $(ASM_FILE) -f3 -o$(PAL_ROM) -l$(LIST_FILE) -s$(SYMBOL_FILE) -M$(OBJECT_DIR)/$(BASENAME).map
	@rm -f $(GENERATED_DIR)/temp_pal.bas $(GENERATED_DIR)/$(BASENAME).bas
	@echo "PAL ROM created: $(PAL_ROM)"

# Build SECAM version
$(SECAM_ROM): $(MAIN_SOURCE) $(BANK_SOURCES) $(COMMON_SOURCES) | $(DIST_DIR) $(OBJECT_DIR) $(GENERATED_DIR)
	@echo "Building SECAM version..."
	@sed 's/set tv .*/set tv secam/' $(MAIN_SOURCE) > $(GENERATED_DIR)/temp_secam.bas
	@cp $(GENERATED_DIR)/temp_secam.bas $(GENERATED_DIR)/$(BASENAME).bas
	@bB=Tools/batariBASIC $(BB) $(GENERATED_DIR)/$(BASENAME).bas -O
	$(DASM) $(ASM_FILE) -f3 -o$(SECAM_ROM) -l$(LIST_FILE) -s$(SYMBOL_FILE) -M$(OBJECT_DIR)/$(BASENAME).map
	@rm -f $(GENERATED_DIR)/temp_secam.bas $(GENERATED_DIR)/$(BASENAME).bas
	@echo "SECAM ROM created: $(SECAM_ROM)"

# Run emulator with NTSC version
emu: $(NTSC_ROM)
	@echo "Running $(NTSC_ROM) in Stella emulator..."
	$(STELLA) $(NTSC_ROM)

# Clean all generated files
clean:
	@echo "Cleaning generated files..."
	@rm -rf $(DIST_DIR)/*.a26
	@rm -rf $(OBJECT_DIR)/*
	@rm -rf $(GENERATED_DIR)/*
	@rm -f bB.asm *.asm *.bin *.lst *.sym *.map
	@echo "Clean complete"

# Create necessary directories
$(DIST_DIR):
	@mkdir -p $(DIST_DIR)

$(OBJECT_DIR):
	@mkdir -p $(OBJECT_DIR)

$(GENERATED_DIR):
	@mkdir -p $(GENERATED_DIR)

# Help target
help:
	@echo "Available targets:"
	@echo "  all     - Build all ROM variants (default)"
	@echo "  game    - Build all ROM variants (NTSC, PAL, SECAM)"
	@echo "  clean   - Remove all generated files"
	@echo "  emu     - Build NTSC version and run in Stella emulator"
	@echo "  help    - Show this help message"
	@echo ""
	@echo "Output files:"
	@echo "  $(NTSC_ROM)   - NTSC version"
	@echo "  $(PAL_ROM)    - PAL version"
	@echo "  $(SECAM_ROM)  - SECAM version"
	@echo ""
	@echo "Intermediate files:"
	@echo "  $(ASM_FILE)      - Generated assembly code"
	@echo "  $(LIST_FILE)     - Assembly listing"
	@echo "  $(SYMBOL_FILE)   - Symbol table"

# Show project status
status:
	@echo "ChaosFight Project Status:"
	@echo "=========================="
	@echo "Source files: $(MAIN_SOURCE), $(BANK_SOURCES), $(COMMON_SOURCES)"
	@echo "Tools: batariBASIC ($(BB)), DASM ($(DASM)), Stella ($(STELLA))"
	@echo "Output directory: $(DIST_DIR)"
	@echo "Object directory: $(OBJECT_DIR)"
	@echo "Generated directory: $(GENERATED_DIR)"
	@ls -la $(DIST_DIR)/*.a26 2>/dev/null || echo "No ROM files built yet"

# ===========================================================================
# End of Makefile
# ===========================================================================
