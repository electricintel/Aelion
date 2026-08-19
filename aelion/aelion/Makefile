CC ?= gcc
WARNFLAGS := -Wall -Wextra -Wno-unused-parameter -Wno-sign-compare -Wno-unused-function
CFLAGS ?= -O2 $(WARNFLAGS) -std=c11
CPPFLAGS := -I. -Iinclude -Isrc -I../sqlite/include
LDFLAGS ?=
LDLIBS ?=

BUILD_DIR := build
BIN := $(BUILD_DIR)/aelion_binary

SRC := $(shell find src -type f -name '*.c' -print)
OBJ := $(patsubst src/%.c,$(BUILD_DIR)/%.o,$(SRC))
OBJ += $(BUILD_DIR)/sqlite3.o

TESTS := $(shell find tests -type f -name 'test_*.c' -print | sort)
TEST_BINS := $(patsubst tests/%.c,$(BUILD_DIR)/tests/%.bin,$(TESTS))

.PHONY: all clean test check run

all: $(BIN)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: src/%.c | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/sqlite3.o: ../sqlite/include/sqlite3.c | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/tests/%.bin: tests/%.c src/core/usp/usp.c src/core/bus/bus.c | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) $< src/core/usp/usp.c src/core/bus/bus.c -o $@

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o $@ $(LDFLAGS) $(LDLIBS)

test: $(TEST_BINS)
	@for t in $(TEST_BINS); do \
		echo "Running $$t"; \
		$$t || exit $$?; \
	done

check:
	@test -x $(BIN) || { echo "Missing build output: $(BIN)"; exit 1; }
	@echo "Binary is present: $(BIN)"

run: $(BIN)
	./$(BIN)

clean:
	rm -rf $(BUILD_DIR)
