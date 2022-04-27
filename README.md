# printf
![example workflow](https://github.com/ArinaVladi/printf/actions/workflows/main.yml/badge.svg)

## Running from C and testing printf function written in NASM 
Realisation of printf function in accordance with System V call convention and its call from C.

## Requirements
* NASM
* Google Tessts
## Build and run
### Launch
To run with tests and strict compiler options:
```
make debug [or just make]
./debug/my_printf
```
To run my_printf as the standart printf function:
```
make release
./release/my_printf
```
### Control
Results of launching with or without tests cpuld be tracked in  [Actions section]. in `debug` and `release` jobs respectively.

## Code
- `printf.nasm` - NASM printf realisation
- `testing.cpp` and `testing.h` - code to organise testing process
- `get_descriptor.cpp` - function returning file descriptor
- `hash.cpp` and `hash.h` - hash function crc32
- `run.cpp` - to run programm


[Actions section]: https://github.com/ArinaVladi/printf/actions
