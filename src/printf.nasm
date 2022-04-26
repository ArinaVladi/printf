default rel
global _my_printf 
global printf_to_file
extern get_file_descriptor
;--------------------------------------------macros------------------------------------------------
;--------------------------------------------------------------------------------------------------
; macros to perform push and pop of several aguments
; push and pop arguments must be at the same order
;--------------------------------------------------------------------------------------------------
%macro mpush 1-*
    %rep %0
        push %1
    %rotate 1
    %endrep
%endmacro

%macro mpop 1-*
    %rep %0
    %rotate -1
        pop %1
    %endrep
%endmacro

;--------------------------------------------------------------------------------------------------
; Compares count of symbols already stored in the buffer 
; and flushes buffer if number of those symbols is greater then buffer size
;--------------------------------------------------------------------------------------------------
%macro flush_if_full 0 
        cmp     PRINT_SIZE, BUFFER_SIZE
        jb      %%skip_flush         
        call    flush_buffer     

        %%skip_flush:
%endmacro

;--------------------------------------------------------------------------------------------------
; Generates functions for jump table printing numbers of a specific radix 
; which movs given radix to required register and calls universal function (print_number)
;--------------------------------------------------------------------------------------------------
%macro print_base 1

        print_%1:

                push    rax

                mov     RADIX, %1
                mov     eax, [MODIFIABLE_BP]
                call    print_number 
                add     MODIFIABLE_BP, BITE_SIZE

                pop     rax

                ret

%endmacro

;---------------------------------------------code-------------------------------------------------

section .text

%define BUFFER_SIZE           5   
%define ITOA_TMP_STR_SIZE    64

%define BITE_SIZE             8

%define WRONG_SPECIFIER_ERNO -1

                           ;r8 - never used
                           ;r9 - never used
%define ERROR_FLAG          r10                      
%define PRINT_SIZE          r11
%define NEGATIVE_FLAG       r12
%define RETURN_ADDRESS      r13
%define RADIX               r14
%define MODIFIABLE_BP       r15

%define WRITE_NR           0x01
%define EXIT_GROUP_NR      0xE7
%define EXIT_NR            0x3C
%define STDOUT_FILE_DESCR  0x01
%define TERMINATE_CHAR     0x00

;--------------------------------------------------------------------------------------------------
; Takes file pointer as the first argument, sets file descriptor for next functions and
; tructures the stack and calls actual printf function
;
; Entry: -
; Exit:  -
; Destr: -
;--------------------------------------------------------------------------------------------------
printf_to_file:   ;                                          rsi rdi rcx r8 r9 
                
        mpop    RETURN_ADDRESS
        mpush   r9, r8, rcx, rdx, rsi
        push    rbp
        mov     rbp, rsp

        mpush rbx, rcx, r12, r13, r14, r15 

        push    rdi
        call    get_file_descriptor
        pop     rdi
        mov     [FILE_DESCR], rax
        xor     rax, rax

        call    do_printf

        mpop    rbx, rcx, r12, r13, r14, r15 

        pop     rbp
        mpop    r9, r8, rcx, rdx, rsi
        push    RETURN_ADDRESS

        ret

;--------------------------------------------------------------------------------------------------
; Structures the stack and calls actual printf function
;
; Entry: -
; Exit:  -
; Destr: -
;--------------------------------------------------------------------------------------------------
_my_printf: ;                                    rbp     rdi rsi rdx rcx r8 r9      
                
        mpop    RETURN_ADDRESS                ; save return address in register
        mpush   r9, r8, rcx, rdx, rsi, rdi    ;
        push    rbp
        mov     rbp, rsp

        mpush   rbx, rcx, r12, r13, r14, r15 

        call    do_printf

        mpop    rbx, rcx, r12, r13, r14, r15 

        pop     rbp
        mpop    r9, r8, rcx, rdx, rsi, rdi 
        push    RETURN_ADDRESS

        ret

;--------------------------------------------------------------------------------------------------
; Prossesses format string symbol by symbol
;
; Entry: arguments are in the stack
; Exit:  rax - number of symbols written to outout
; Destr: PRINT_SIZE    (r11)
;        MODIFIABLE_BP (r15)
;        rsi - current sybol in format string
;        rdi - buffer pointer
;--------------------------------------------------------------------------------------------------
do_printf:

        xor     PRINT_SIZE, PRINT_SIZE
        xor     rax, rax

        lea     rdi, [PRINTF_BUFFER]    

        mov     MODIFIABLE_BP, rbp
        add     MODIFIABLE_BP, BITE_SIZE
        mov     rsi, [MODIFIABLE_BP]
        add     MODIFIABLE_BP, 8

        .process_symbol:
                inc     rax
                cmp     byte [rsi], TERMINATE_CHAR
                je      .end

                cmp     byte [rsi], '%'
                jne     .ordinary_char
                inc     rsi

        .specifier:
                call    switch_specifier
                jmp     .process_symbol

        .ordinary_char:
                call    print_char
                jmp     .process_symbol

        .end:
                call    flush_buffer
        
        ret

;--------------------------------------------------------------------------------------------------
; Prints char and increases counter of symbols in the buffer
;
; Entry: rsi - src
;        rdi - dest
; Exit:  
; Destr: rsi, rdi
;--------------------------------------------------------------------------------------------------
print_char:

        movsb
        inc     PRINT_SIZE
        flush_if_full

        ret

;--------------------------------------------------------------------------------------------------
; Prints '%'. The only difference from print_char - does not change rsi
;
; Entry: rsi - src
;        rdi - dest
; Exit:  
; Destr: rdi
;--------------------------------------------------------------------------------------------------
print_percent:
            mov byte [rdi], '%'
            inc rdi
            inc PRINT_SIZE
            ret

;--------------------------------------------------------------------------------------------------
; (from jump table) 
; Prints current char argument from stack
; 
; Entry: MODIFIABLE_BP (r15) - current argument form stack
; Exit:  MODIFIABLE_BP (r15) - next    argument form stack
; Destr: -
;--------------------------------------------------------------------------------------------------
print_arg_char:

        push    rsi

        mov     rsi, MODIFIABLE_BP  ; Why for char no [] needed, and for string they are required
        add     MODIFIABLE_BP, BITE_SIZE
        call    print_char
        
        pop     rsi
    
        ret

;--------------------------------------------------------------------------------------------------
; Flushes buffer and set pointer to the buffer beginning
;
; Entry: -
; Exit:  PRINT_SIZE (r11) = 0
;        rdi              = buffer begining (dest ptr)
; Destr: rdi, rdx
;--------------------------------------------------------------------------------------------------
flush_buffer:

        mpush   rsi, rax

        mov     rax, WRITE_NR  
        lea     rsi, [PRINTF_BUFFER]    
        mov     rdi, [FILE_DESCR]        
        mov     rdx, PRINT_SIZE

        syscall

        lea     rdi, [PRINTF_BUFFER]
        xor     PRINT_SIZE, PRINT_SIZE

        mpop    rsi, rax
        
        ret 

;--------------------------------------------------------------------------------------------------
; Prints error message and current specifier from format string 
; sets rdi and calls syscall wrapper
;
; Entry: rsi - current specifier
; Exit:  -
; Destr: rdi
;--------------------------------------------------------------------------------------------------
wrong_specifier:

        push    rsi

        lea     rsi, [ERROR_MSG]
        call    print_string

        pop     rsi

        
        call    print_char
        call    flush_buffer

        mov     rdi, WRONG_SPECIFIER_ERNO
        call    exit

        ret

;--------------------------------------------------------------------------------------------------
; Exits program with exit() syscall
;
; Entry: rdi - exit code   
; Exit:  
; Destr: 
;--------------------------------------------------------------------------------------------------
; Expects:  
exit:
        mov     rax, EXIT_NR
        syscall
        ret

;--------------------------------------------------------------------------------------------------
; Prints string char by char in the loop
;
; Entry: rsi - string pointer
; Exit:  rdi - next buffer pointer
; Destr: rsi
;--------------------------------------------------------------------------------------------------
print_string:

        cmp     byte [rsi], TERMINATE_CHAR
        je      .end

        .begin_loop:
                movsb
                inc     PRINT_SIZE
                flush_if_full
                cmp     byte [rsi], TERMINATE_CHAR
                jne     .begin_loop

        .end:
        ret

;--------------------------------------------------------------------------------------------------
; (from jump table) 
; Prints current string argument from stack
; 
; Entry: MODIFIABLE_BP (r15) - current argument form stack
; Exit:  MODIFIABLE_BP (r15) - next    argument form stack
; Destr: -
;--------------------------------------------------------------------------------------------------
print_arg_string:

        push    rsi

        mov     rsi, [MODIFIABLE_BP]
        add     MODIFIABLE_BP, BITE_SIZE
        call    print_string

        pop     rsi

        ret

;--------------------------------------------------------------------------------------------------
; Calculates resuired function's offset at the jump table and calls this function
;
; Entry: rsi - previous symbol in the format string
; Exit:  rsi - next     symbol in the format string
; Destr: -
;--------------------------------------------------------------------------------------------------
switch_specifier:

       ; inc     rsi                  

        mpush   rax, rbx                  
        lea     rbx, [JUMP_TABLE]
        mov     al, [rsi]              
        call    [rbx + rax * BITE_SIZE]
        mpop    rax, rbx                    

        inc     rsi  

        ret

;--------------------------------------------------------------------------------------------------
; (from jump table) see print_base macro for refference
;
; Entry: MODIFIABLE_BP (r15) - current argument from the stack
; Exit:  MODIFIABLE_BP (r15) - next    argument from the stack
; Destr: RADIX (r14)
;--------------------------------------------------------------------------------------------------
print_base 2
print_base 8
print_base 10


print_base 16

;--------------------------------------------------------------------------------------------------
; Checks the NEGATIVE_FLAG and prints '-',
; calls itoa and prints number from itoa buffer
;
; Entry: MODIFIABLE_BP (r15) - current argument from the stack
;        RADIX         (r14)
;        rax - number to prints
; Exit:  -
; Destr: -
;--------------------------------------------------------------------------------------------------
print_number:

        mpush rsi, rdi

        mov  rdi, ITOA_BUFFER   

        .positive:
                call itoa
                pop rdi
        
                mov rsi, ITOA_BUFFER
                call print_string                            
        
                pop rsi

        ret 

;--------------------------------------------------------------------------------------------------
; Converts int to string with given radix and stores result string in itoa_buffer
; Convertion algoeithm in case radix is a power of 2 is different and uses bit shifts
; Handles negative decimal numbers
;
; Entry: RADIX (r14)
;        rax - number to convert
;        rdi - itoa buffer pointer
; Exit:  -
; Destr: -
;--------------------------------------------------------------------------------------------------
itoa: ;2 func с div и без и вызывать конкретные функции

        mpush   rax, rbx, rcx, rdx, rsi, rdi

        call    sign
        
        call    is_power_of_2
        cmp     rcx, 0
        jne     .not_pow_of_2                         ; base is power of 2

        .pow_of_2:
                call    log2

                xor     rdx, rdx
                xor     r8, r8
                lea     rbx, [XLA_TABLE]

                dec     RADIX
                xor     ch, ch

        .digit_by_shift:
                mov     rdx, RADIX
                and     rdx, rax                             ; last digit of shifted number
                mov     r8b, [rbx + rdx]
                push    r8
                inc     ch 

                shr     rax, cl                               ; shift original number

                cmp     rax, 0    
                jg      .digit_by_shift

                mov     cl, ch
                xor     ch, ch
                jmp     .put_in_itoa_buffer

        .not_pow_of_2:
                xor     rcx, rcx
                xor     r8, r8   ;curr result string symbol
                lea     rbx, [XLA_TABLE]

        .divide_by_base:    
                xor     rdx, rdx
                div     RADIX     ; ax by bx 
                mov     r8b, [rbx + rdx] ; !
                push    r8

                inc     rcx

                cmp     eax, 0
                jne     .divide_by_base

                cmp     NEGATIVE_FLAG, 0
                je      .skip_minus
                mov     al, '-'
                stosb  

        .skip_minus:

        .put_in_itoa_buffer:
                pop     rax
                stosb
                loop    .put_in_itoa_buffer
        
                mov     al, TERMINATE_CHAR
                stosb

        .finish:
               
        mpop    rax, rbx, rcx, rdx, rsi, rdi
        ret


;-----------------------------------------------------------------------------
; If decima number is negative - puts the sign to str and negates the number
;
; Entry: ax - number
;          bx - base
; Exit:  ax - (negated) number
; Destr: -
;-----------------------------------------------------------------------------
sign:    
        mov     NEGATIVE_FLAG, 1
        shl     NEGATIVE_FLAG, 31
        and     NEGATIVE_FLAG, rax
    
        cmp     NEGATIVE_FLAG, 0
        je      .finish
                
        cmp     RADIX, 10
        jne     .finish
        neg     eax
        
        .finish:
        ret

;-----------------------------------------------------------------------------
; If decima number is negative - puts the sign to str and negates the number
; return (x & (x - 1) == 0)
;
; Entry: bx - base
; Exit:  cx - (1 - is power of 2, 0 -is not)
; Destr: -
;-----------------------------------------------------------------------------
is_power_of_2:
        mov     rcx, RADIX
        dec     rcx
        and     rcx, RADIX

        ret

;-----------------------------------------------------------------------------
; Calculates log[2, base] where base is power-of-2
;
; Entry: RADIX - x
; Exit:  cl - log[2, x]
; Destr: -
;-----------------------------------------------------------------------------
log2:
        mpush   RADIX, rsi 
        mov     cl,  ITOA_TMP_STR_SIZE
        mov     sil, ITOA_TMP_STR_SIZE

    calc_log2:
        shr     RADIX, 1
        cmp     RADIX, 0
        loopne  calc_log2
        sub     sil, cl
        dec     sil
        mov     cl, sil
        mpop    RADIX, rsi

        ret

;--------------------------------------------------data------------------------------------------------------
section .data

ERROR_MSG db "    Error: wrong specifier %", TERMINATE_CHAR

XLA_TABLE   db   "0123456789abcdef"

FILE_DESCR dd STDOUT_FILE_DESCR

JUMP_TABLE:
times       '%'             dq wrong_specifier   ; symbols before %
                            dq print_percent            
times       'b' - '%' - 1   dq wrong_specifier                        
                            dq print_2     
                            dq print_arg_char         
                            dq print_10
times       'o' - 'd' - 1   dq wrong_specifier                        
                            dq print_8                    
times       's' - 'o' - 1   dq wrong_specifier                        
                            dq print_arg_string     
times       'x' - 's' - 1   dq wrong_specifier                        
                            dq print_16                       
times 133                   dq wrong_specifier   ; the rest of symbols  

;----------------------------------------uninitialised data--------------------------------------------------

section .bss

PRINTF_BUFFER resb BUFFER_SIZE
printf_buff_end: 
ITOA_BUFFER  resb ITOA_TMP_STR_SIZE
pow resb 32
; трамплины кладут в нужные регистры маску - насколлько