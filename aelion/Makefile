CC ?= gcc
WARNFLAGS := -Wall -Wextra \
	-Wno-unused-parameter -Wno-sign-compare -Wno-unused-function \
	-Wno-format-truncation -Wno-stringop-truncation -Wno-cast-function-type
CFLAGS ?= -O0 $(WARNFLAGS) -std=c11
CPPFLAGS := -I. -Iinclude -Isrc -Iaelion/include -Iaelion/src -Isqlite/include -Ithird_party/sqlite
LDFLAGS ?=
LDLIBS ?= -lws2_32

EXE_EXT := .exe
ifeq ($(OS),Windows_NT)
EXE_EXT := .exe
endif

WINDOWS_CMD := 0
ifeq ($(OS),Windows_NT)
ifneq ($(filter sh sh.exe bash bash.exe zsh zsh.exe,$(notdir $(SHELL))),)
WINDOWS_CMD := 0
else
WINDOWS_CMD := 1
endif
endif

ifeq ($(WINDOWS_CMD),1)
define MKDIR_P
if not exist "$(subst /,\\,$1)" mkdir "$(subst /,\\,$1)"
endef
define RM_RF
if exist "$(subst /,\\,$1)" rmdir /S /Q "$(subst /,\\,$1)"
endef
define RUN_BIN
"$(subst /,\\,$1)"
endef
else
define MKDIR_P
mkdir -p "$1"
endef
define RM_RF
rm -rf "$1"
endef
define RUN_BIN
./$1
endef
endif

rwildcard = $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

BUILD_DIR := build
BIN := $(BUILD_DIR)/aelion_binary$(EXE_EXT)

SRC := $(sort $(call rwildcard,src/,*.c))
SRC := $(filter-out src/core/aelion_main.c,$(SRC))
OBJ := $(patsubst src/%.c,$(BUILD_DIR)/%.o,$(SRC))
DB_SRC := aelion/src/db/aelion_db.c
DB_OBJ := $(BUILD_DIR)/aelion_db.o
OBJ += $(DB_OBJ) $(BUILD_DIR)/sqlite3.o

TESTS := $(sort $(call rwildcard,tests/,test_*.c))
TEST_BINS := $(patsubst tests/%.c,$(BUILD_DIR)/tests/%.bin$(EXE_EXT),$(TESTS))
TEST_RUNS := $(patsubst $(BUILD_DIR)/tests/%.bin$(EXE_EXT),run-test-%,$(TEST_BINS))
CORE_TEST_SRC := src/core/usp/usp.c src/core/bus/bus.c src/core/registry/registry.c src/core/security/security.c

.PHONY: all clean test check run $(TEST_RUNS)

all: $(BIN) test

$(BUILD_DIR):
	@$(call MKDIR_P,$(BUILD_DIR))

$(BUILD_DIR)/%.o: src/%.c | $(BUILD_DIR)
	@$(call MKDIR_P,$(dir $@))
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/sqlite3.o: sqlite/include/sqlite3.c | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(DB_OBJ): $(DB_SRC) | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/tests/%.bin$(EXE_EXT): tests/%.c $(CORE_TEST_SRC) | $(BUILD_DIR)
	@$(call MKDIR_P,$(dir $@))
	$(CC) $(CPPFLAGS) $(CFLAGS) $< $(CORE_TEST_SRC) -o $@

$(BIN): $(OBJ)
	@$(call MKDIR_P,$(dir $@))
	$(CC) $(CFLAGS) $(OBJ) -o $@ $(LDFLAGS) $(LDLIBS)

test: $(TEST_RUNS)

run-test-%: $(BUILD_DIR)/tests/%.bin$(EXE_EXT)
	@echo "Running $<"
	@$(call RUN_BIN,$<)

check:
	@test -x $(BIN) || { echo "Missing build output: $(BIN)"; exit 1; }
	@echo "Binary is present: $(BIN)"

run: $(BIN)
	@$(call RUN_BIN,$(BIN))

clean:
	@$(call RM_RF,$(BUILD_DIR))
