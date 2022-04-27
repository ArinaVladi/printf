# Applicaton options
GXX_STANDARD = 17 

# valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=valgrind-out.txt ./build_debug/my_printf 

# Сompiler options
CC = g++
#CXXFLAGS = -Wall -Wextra -std=c++$(GXX_STANDARD)
#CXXFLAGS +=  -Wc++0x-compat -Wc++11-compat -Wc++14-compat -Waggressive-loop-optimizations -Walloc-zero -Walloca -Walloca-larger-than=8192 -Warray-bounds -Wcast-align -Wcast-qual -Wchar-subscripts -Wconditionally-supported -Wconversion -Wctor-dtor-privacy -Wdangling-else -Wduplicated-branches -Wempty-body -Wfloat-equal -Wformat-nonliteral -Wformat-security -Wformat-signedness -Wformat=2 -Wformat-overflow=2 -Wformat-truncation=2 -Winline -Wlarger-than=8192 -Wvla-larger-than=8192 -Wlogical-op -Wmissing-declarations -Wnon-virtual-dtor -Wopenmp-simd -Woverloaded-virtual -Wpacked -Wpointer-arith -Wredundant-decls -Wrestrict -Wshadow -Wsign-promo -Wstack-usage=8192 -Wstrict-null-sentinel -Wstrict-overflow=2 -Wstringop-overflow=4 -Wsuggest-attribute=noreturn -Wsuggest-final-types -Wsuggest-override -Wswitch-default -Wswitch-enum -Wsync-nand -Wundef -Wunreachable-code -Wunused -Wvariadic-macros -Wno-literal-suffix -Wno-missing-field-initializers -Wnarrowing -Wno-old-style-cast -Wvarargs -Waligned-new -Walloc-size-larger-than=1073741824 -Walloc-zero -Walloca -Walloca-larger-than=8192 -Wcast-align=strict -Wdangling-else -Wduplicated-branches -Wformat-overflow=2 -Wformat-truncation=2 -Wmissing-attributes -Wmultistatement-macros -Wrestrict -Wshadow=global -Wsuggest-attribute=malloc -fcheck-new -fsized-deallocation -fstack-check -fstrict-overflow -flto-odr-type-merging -fno-omit-frame-pointer
LXXFLAGS =
BUILD = Debug# Debug or Release

# Folder name setting
SRC_DIR = src
BIN_DIR = bin

# Setting build parameters
ifeq ($(BUILD), Debug)
    CXXFLAGS += -O0  -fdiagnostics-color=always
    BUILD_PATH = build_debug
else
    CXXFLAGS += -Os -s -DNDEBUG
    BUILD_PATH = build_release
endif

#LXXFLAGS += -lgtest -lgtest_main -lpthread

# Search for source files
SRC_FULL_PATH = $(shell where /r ./ *.cpp)
SRC = src
OBJ = $(addprefix $(BIN_DIR)/, $(SRC:.cpp=.o))

CFLAGS +=  -fsanitize=address 
LDFLAGS += -fsanitize=address 

# Build project

my_printf: bin/run.o bin/printf.o bin/get_descriptor.o bin/hash.o bin/testing.o Makefile
	$(CC) bin/run.o bin/printf.o bin/get_descriptor.o bin/hash.o bin/testing.o  -o build_debug/my_printf  $(LXXFLAGS)  

bin/run.o: src/run.cpp Makefile
	$(CC) $< -c -o  $@ $(CXXFLAGS) $(LXXFLAGS)  

bin/hash.o: src/hash.cpp Makefile
	$(CC) $< -c -o  $@ $(CXXFLAGS) $(LXXFLAGS)  

bin/testing.o: src/testing.cpp Makefile
	$(CC) $< -c -o  $@ $(CXXFLAGS) $(LXXFLAGS)  

bin/printf.o: src/printf.nasm Makefile
	nasm -f elf64 src/printf.nasm -o bin/printf.o 

bin/get_descriptor.o: src/get_descriptor.cpp Makefile
	$(CC) $< -c -o  $@ $(CXXFLAGS) $(LXXFLAGS)  
	

.PHONY: init clean
init:
	md bin

clean:
	rm -rf bin/*