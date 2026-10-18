# Discover and build every C and C++ source under src/, preserving its relative
# path in build/obj/. New source files are picked up on the next make invocation.

CC ?= cc
CXX ?= c++
SRC_DIR ?= src
BUILD_DIR ?= build
TARGET ?= $(BUILD_DIR)/pcixr

CPPFLAGS += -I$(SRC_DIR)
CFLAGS ?= -O2 -g
CFLAGS += -std=c11 -Wall -Wextra -Wpedantic
CXXFLAGS ?= -O2 -g
CXXFLAGS += -std=c++17 -Wall -Wextra -Wpedantic
LDFLAGS ?=
LDLIBS ?=

C_SOURCES := $(shell find $(SRC_DIR) -type f -name '*.c' -print 2>/dev/null | sort)
CXX_SOURCES := $(shell find $(SRC_DIR) -type f \( -name '*.cc' -o -name '*.cpp' -o -name '*.cxx' \) -print 2>/dev/null | sort)
SOURCES := $(C_SOURCES) $(CXX_SOURCES)
C_OBJECTS := $(patsubst $(SRC_DIR)/%,$(BUILD_DIR)/obj/%.o,$(C_SOURCES))
CXX_OBJECTS := $(patsubst $(SRC_DIR)/%,$(BUILD_DIR)/obj/%.o,$(CXX_SOURCES))
OBJECTS := $(C_OBJECTS) $(CXX_OBJECTS)
DEPS := $(OBJECTS:.o=.d)

.PHONY: all clean debug release run list-sources

ifeq ($(strip $(SOURCES)),)
$(error No C or C++ source files found under $(SRC_DIR)/)
endif

all: $(TARGET)

$(TARGET): $(OBJECTS)
	@mkdir -p $(dir $@)
	$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BUILD_DIR)/obj/%.c.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/obj/%.cc.o: $(SRC_DIR)/%.cc
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/obj/%.cpp.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/obj/%.cxx.o: $(SRC_DIR)/%.cxx
	@mkdir -p $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MMD -MP -c $< -o $@

debug:
	$(MAKE) BUILD_DIR='$(BUILD_DIR)/debug' CFLAGS='-O0 -g3 -std=c11 -Wall -Wextra -Wpedantic' CXXFLAGS='-O0 -g3 -std=c++17 -Wall -Wextra -Wpedantic' all

release:
	$(MAKE) BUILD_DIR='$(BUILD_DIR)/release' CFLAGS='-O2 -DNDEBUG -std=c11 -Wall -Wextra -Wpedantic' CXXFLAGS='-O2 -DNDEBUG -std=c++17 -Wall -Wextra -Wpedantic' all

run: $(TARGET)
	./$(TARGET) $(ARGS)

list-sources:
	@printf '%s\n' $(SOURCES)

clean:
	rm -rf $(BUILD_DIR)

-include $(DEPS)

