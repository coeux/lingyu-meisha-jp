#ifndef _CRYPTO_H_
#define _CRYPTO_H_

#include <string>

class crypto_t {
public:

    static uint32_t crc32(const char* bytes, size_t numBytes);
    static uint16_t crc16(const char* bytes, size_t numBytes);
};


#endif
