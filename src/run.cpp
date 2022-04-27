#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "testing.h"

extern "C" int _my_printf(const char* format, ...);
extern "C" int printf_to_file(FILE* file, const char* format, ...);

#define do_test(format, ...)                                               \
    printf_to_file(test_info.my_printf.file_ptr, format,__VA_ARGS__);      \  
    fprintf       (test_info.c_printf.file_ptr, format, __VA_ARGS__);
/*
class PrintfTest : public ::testing::Test {

    protected:

        Test_info test_info{};
    
        void SetUp() {
        
            test_info.Ctor("tests/my_printf_result.txt", "tests/c_printf_result.txt");
        }
    
        void TearDown() {
            test_info.Dtor();
        }
};

TEST_F(PrintfTest, decimal_positive) {

    do_test("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n", 
    594953647, 409899931, 484366094, 595465611, 515476965, 82509786, 72026571, 193651465, 531105058, 330721934, 
    847800467, 992480604, 118605715, 90635096, 40028484, 747077868, 993779572, 752276419, 62592379, 766171994);

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);

}

TEST_F(PrintfTest, decimal_negative) {

    do_test("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
    -29061573, -123587082, -899798293, -945731105, -964272549, -429081624, -329148168, -764186508, -134188368, -25962877, 
    -595861602, -242935262, -706635807, -872431869, -636461382, -79564391, -482799921, -820430075, -716332378, -965150392);

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);

}

TEST_F(PrintfTest, decimal_zero) {

    do_test("%d %d %d %d %d %d %d\n", 0, 0, 0, 0, 0, 0, 0);

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);

}

TEST_F(PrintfTest, oct_positive) {

    do_test("%o %o %o %o %o %o %o %o %o %o %o %o %o %o %o %o %o %o %o %o\n", 
    594953647, 409899931, 484366094, 595465611, 515476965, 82509786, 72026571, 193651465, 531105058, 330721934, 
    847800467, 992480604, 118605715, 90635096, 40028484, 747077868, 993779572, 752276419, 62592379, 766171994);

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);

}

TEST_F(PrintfTest, oct_negative) {

    do_test("%o %o %o %o %o %o %o %o %o %o %o %o %o %o %o %o %o %o %o %o\n",
    -29061573, -123587082, -899798293, -945731105, -964272549, -429081624, -329148168, -764186508, -134188368, -25962877, 
    -595861602, -242935262, -706635807, -872431869, -636461382, -79564391, -482799921, -820430075, -716332378, -965150392);

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);

}

TEST_F(PrintfTest, oct_zero) {

    do_test("%o %o %o %o %o %o %o\n", 0, 0, 0, 0, 0, 0, 0);

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);

}

TEST_F(PrintfTest, hex_positive) {

    do_test("%x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x\n", 
    594953647, 409899931, 484366094, 595465611, 515476965, 82509786, 72026571, 193651465, 531105058, 330721934, 
    847800467, 992480604, 118605715, 90635096, 40028484, 747077868, 993779572, 752276419, 62592379, 766171994);

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);

}

TEST_F(PrintfTest, hex_negative) {

    do_test("%x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x\n",
    -29061573, -123587082, -899798293, -945731105, -964272549, -429081624, -329148168, -764186508, -134188368, -25962877, 
    -595861602, -242935262, -706635807, -872431869, -636461382, -79564391, -482799921, -820430075, -716332378, -965150392);

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);

}

TEST_F(PrintfTest, hex_zero) {

    do_test("%x %x %x %x %x %x %x\n", 0, 0, 0, 0, 0, 0, 0);

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);
}

TEST_F(PrintfTest, chars) {

    do_test("%c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c %c\n",
    'K', 'D', 'X', 'u', 'b', 'a', 'o', '2', '1', 'U', 'B', 'W', 'Z', 'k', 'V', 'r', 'j', 'O', 'f', 'm');

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);
}

TEST_F(PrintfTest, strings) {

    do_test("%s %s %s %s %s %s %s %s %s %s\n", //!
    "NvEYGJnZqXtj3EN8oo0Q", "EzJqS5B6UgLGLWHFIO92", "3l0kJ4kBNxj6jA5ix60t", 
    "VTd8qNIYPXf5PPk9pWKI", "vchY2Zz4AxQQ1MJUPkHt", "ljmT1SSQT5ec50xeRuDB", 
    "1QeEJOYEE7tVdPc9CTue", "i1DADcSk2Rydr8IXM5e7", "JqWMcMLMNO8vKOqNMHbb", 
    "PDTC5Y1Qt8pPKof2krAp");

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);
}

TEST_F(PrintfTest, only_format_string) {

    printf_to_file(test_info.my_printf.file_ptr, "just string\n");
    fprintf       (test_info.c_printf.file_ptr,  "just string\n");

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);
} 

TEST_F(PrintfTest, percent) {

    printf_to_file(test_info.my_printf.file_ptr, "%%%%%%%%%%");
    fprintf       (test_info.c_printf.file_ptr,  "%%%%%%%%%%");

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);
} 

TEST_F(PrintfTest, Ded_test) {

    do_test("%d %s %x %d%%%c%d\n", 
    -1, "love", 3802, 100, '!', 15);

    test_info.calculate_file_characteristics();
  
    EXPECT_EQ(test_info.my_printf.num_of_digits, test_info.c_printf.num_of_digits);
    EXPECT_EQ(test_info.my_printf.hash, test_info.c_printf.hash);
}
*/
int main(int argc, char *argv[]) {

   _my_printf("%d %s %x %d%%%c%b\n", -1, "love", 3802, 100, '!', 15);
//   	::testing::InitGoogleTest(&argc, argv);
//	return RUN_ALL_TESTS(); 

}
