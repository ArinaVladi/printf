#include <stdio.h>

extern "C" int get_file_descriptor(FILE* file){
    return fileno(file);
}