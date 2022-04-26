#include "hash.h"

uint32_t getHashCrc32(const unsigned char* buffer, size_t bytesCount)
{   
    assert(buffer);
    assert(bytesCount > 0);

    uint32_t hash = 0;    
    for (size_t i = 0; i < bytesCount; i++)
    {
        hash = (hash << 8) ^ CRC32_TABLE[((hash >> 24) ^ buffer[i]) & 255];
    }

    return hash;        
}