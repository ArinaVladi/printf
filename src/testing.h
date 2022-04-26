#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdarg.h>
#include <sys/stat.h>
#include "hash.h"

struct Test_file {

        FILE* file_ptr     = nullptr;
        int num_of_digits  = 0;
        uint32_t hash      = 0;
        const char* file_name;

        void Ctor(char* str);
        uint32_t get_file_size_fstat();
        void calculate_characteristics(char* buffer);

};

struct Test_info {

        char* test_file_buffer;

        Test_file my_printf;
        Test_file c_printf;
 
        void Ctor(char* name_my, char* name_);
        void Dtor();
        void calculate_file_characteristics();
};