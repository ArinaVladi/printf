#include "testing.h"

const int TEST_FILE_BUFFER_SIZE = 65536;

void Test_file::Ctor(char* str) {
    file_name = str;
}


void Test_file::calculate_characteristics(char* buffer) {

    fclose(file_ptr);

    file_ptr  = fopen(file_name,  "r");
    num_of_digits = fread(buffer, 1, get_file_size_fstat(), file_ptr);
    hash = getHashCrc32((unsigned char*)buffer, get_file_size_fstat());
}

void Test_info::Ctor(char* name_my, char* name_c) {

    my_printf.Ctor(name_my);
    c_printf.Ctor(name_c);

    test_file_buffer = (char*) calloc(TEST_FILE_BUFFER_SIZE, sizeof(char));
    assert(test_file_buffer);

    my_printf.file_ptr  = fopen(my_printf.file_name,  "w");
    assert(my_printf.file_ptr);
    c_printf.file_ptr = fopen(c_printf.file_name, "w");
    assert(c_printf.file_ptr);

}

void Test_info::Dtor() {
    free(test_file_buffer);
}

uint32_t Test_file::get_file_size_fstat () {

    struct stat file_stat;
    assert (stat (file_name, &file_stat) != -1);

    return file_stat.st_size;
}

void Test_info::calculate_file_characteristics() {
    my_printf.calculate_characteristics(test_file_buffer);
    c_printf.calculate_characteristics(test_file_buffer);
}