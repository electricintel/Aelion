# Aelion build and verification entry point

CC      ?= gcc
CFLAGS  ?= -std=c11 -Wall -Wextra -Wpedantic -O2
CPPFLAGS ?= -Isrc
BUILD   ?= build

CORE_SRC = \
	src/core/usp/usp.c \
	src/core/bus/bus.c \
	src/core/registry/registry.c \
	src/core/security/security.c \
	src/core/common/sentence.c \
	src/core/common/utils.c

ENGINE_SRC = \
	src/engines/justice/justice.c \
	src/engines/recall/recall.c \
	src/engines/emotional/emotional.c \
	src/engines/home/home.c \
	src/engines/community/community.c \
	src/engines/governance/governance.c \
	src/engines/mining/mining.c

SERVICES_SRC = \
	src/services/api/api.c \
	src/services/api/api_server.c \
	src/services/api/routes.c \
	src/services/scheduler/scheduler.c \
	src/services/scheduler/tasks.c \
	src/services/supervisor/supervisor.c \
	src/services/supervisor/monitor.c

STORAGE_SRC = \
	src/storage/kv.c \
	src/storage/timeline_store.c \
	src/storage/logs.c

APP_SRC = src/main.c
ALL_SRC = $(CORE_SRC) $(ENGINE_SRC) $(SERVICES_SRC) $(STORAGE_SRC) $(APP_SRC)

OBJS = $(ALL_SRC:%.c=$(BUILD)/%.o)
DEPS = $(OBJS:.o=.d)

BIN  = aelion_binary
TEST_BIN = $(BUILD)/test_end_to_end
TEST_SRC = tests/integration/test_end_to_end.c
USP_TEST_BIN = $(BUILD)/test_usp
USP_TEST_SRC = tests/core/test_usp.c

.PHONY: all clean check test test-usp engines core services storage run

all: $(BUILD)/$(BIN)

ifeq ($(OS),Windows_NT)
LDLIBS += -lws2_32
endif

$(BUILD)/$(BIN): $(OBJS)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

$(BUILD)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

$(TEST_BIN): $(TEST_SRC) $(filter-out $(BUILD)/src/main.o,$(OBJS)) ; @mkdir -p $(dir $@); $(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $(TEST_SRC) $(filter-out $(BUILD)/src/main.o,$(OBJS)) $(LDLIBS)

$(USP_TEST_BIN): $(USP_TEST_SRC) $(BUILD)/src/core/usp/usp.o
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $(USP_TEST_SRC) $(BUILD)/src/core/usp/usp.o

check: all
	@./$(BUILD)/$(BIN) "system.check"

test: $(TEST_BIN) $(USP_TEST_BIN)
	@./$(TEST_BIN); ./$(USP_TEST_BIN)

test-usp: test

core:
	$(MAKE) $(CORE_SRC:%.c=$(BUILD)/%.o)

engines:
	$(MAKE) $(ENGINE_SRC:%.c=$(BUILD)/%.o)

services:
	$(MAKE) $(SERVICES_SRC:%.c=$(BUILD)/%.o)

storage:
	$(MAKE) $(STORAGE_SRC:%.c=$(BUILD)/%.o)

run: all
	./$(BUILD)/$(BIN)

clean:
	rm -rf $(BUILD)

-include $(DEPS)
