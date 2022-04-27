################################################################################
#
# Make all or Make debug makes the debug version
# Make release to make the release version
#
################################################################################

GXX_STANDARD = 17 
# Сompiler options
CCC = g++
CC = g++

# Standard rules and flags
CCC = g++
CXXFLAGS= -std=c++0x

# Folder name setting
SRC_DIR = src
BIN_DIR = bin

# Setup debug and release variants
RELDIR = release
DEBUGDIR = debug

ifeq "$(findstring release, $(MAKECMDGOALS))" ""
    BUILD_PATH=$(DEBUGDIR)
    CXXFLAGS += -g3 -O0 -D_DEBUG -D_GLIBCXX_DEBUG -Wc++0x-compat -Wc++11-compat -Wc++14-compat -Waggressive-loop-optimizations -Walloc-zero -Walloca -Walloca-larger-than=8192 -Warray-bounds -Wcast-align -Wcast-qual -Wchar-subscripts -Wconditionally-supported -Wconversion -Wctor-dtor-privacy -Wdangling-else -Wduplicated-branches -Wempty-body -Wfloat-equal -Wformat-nonliteral -Wformat-security -Wformat-signedness -Wformat=2 -Wformat-overflow=2 -Wformat-truncation=2 -Winline -Wlarger-than=8192 -Wvla-larger-than=8192 -Wlogical-op -Wmissing-declarations -Wnon-virtual-dtor -Wopenmp-simd -Woverloaded-virtual -Wpacked -Wpointer-arith -Wredundant-decls -Wrestrict -Wshadow -Wsign-promo -Wstack-usage=8192 -Wstrict-null-sentinel -Wstrict-overflow=2 -Wstringop-overflow=4 -Wsuggest-attribute=noreturn -Wsuggest-final-types -Wsuggest-override -Wswitch-default -Wswitch-enum -Wsync-nand -Wundef -Wunreachable-code -Wunused -Wvariadic-macros -Wno-literal-suffix -Wno-missing-field-initializers -Wnarrowing -Wno-old-style-cast -Wvarargs -Waligned-new -Walloc-size-larger-than=1073741824 -Walloc-zero -Walloca -Walloca-larger-than=8192 -Wcast-align=strict -Wdangling-else -Wduplicated-branches -Wformat-overflow=2 -Wformat-truncation=2 -Wmissing-attributes -Wmultistatement-macros -Wrestrict -Wshadow=global -Wsuggest-attribute=malloc -fcheck-new -fsized-deallocation -fstack-check -fstrict-overflow -flto-odr-type-merging -fno-omit-frame-pointer
else
    BUILD_PATH=$(RELDIR)
    CXXFLAGS += -O3 -DNDEBUG
endif

LXXFLAGS += -lgtest -lgtest_main -lpthread

VPATH = echo $(subst \,/,$(dir $(SRC_FULL_PATH)))

# Build project
my_printf: $(BUILD_PATH)/bin/run.o $(BUILD_PATH)/bin/printf.o $(BUILD_PATH)/bin/get_descriptor.o $(BUILD_PATH)/bin/hash.o $(BUILD_PATH)/bin/testing.o Makefile
	$(CC) $(BUILD_PATH)/bin/run.o $(BUILD_PATH)/bin/printf.o $(BUILD_PATH)/bin/get_descriptor.o $(BUILD_PATH)/bin/hash.o $(BUILD_PATH)/bin/testing.o  -o $(BUILD_PATH)/my_printf  $(LXXFLAGS)  

$(BUILD_PATH)/bin/run.o: src/run.cpp Makefile
	$(CC) $< -c -o  $(BUILD_PATH)/bin/run.o $(CXXFLAGS) $(LXXFLAGS)  

$(BUILD_PATH)/bin/hash.o: src/hash.cpp Makefile
	$(CC) $< -c -o  $@ $(CXXFLAGS) $(LXXFLAGS)  

$(BUILD_PATH)/bin/testing.o: src/testing.cpp Makefile
	$(CC) $< -c -o  $@ $(CXXFLAGS) $(LXXFLAGS)  

$(BUILD_PATH)/bin/printf.o: src/printf.nasm Makefile
	nasm -f elf64 src/printf.nasm -o $(BUILD_PATH)/bin/printf.o 

$(BUILD_PATH)/bin/get_descriptor.o: src/get_descriptor.cpp Makefile
	$(CC) $< -c -o  $@ $(CXXFLAGS) $(LXXFLAGS)

debug : my_printf
release : my_printf

##########################################################################

.PHONY: init clean
init:
	mkdir debug/bin
	mdkdir release/bin

clean:
	rm -rf debug/bin/*
	rm -rf release/bin/*