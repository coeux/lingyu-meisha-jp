#ifndef __FRAME_XTEA_H__
#define __FRAME_XTEA_H__
#define ZERO_LENGTH 7
#define ENCRYPT_ROUNDS (32)
#define DECRYPT_ROUNDS (-32)
#define ENCRYPT_BLOCK_LENGTH_IN_BYTE (8)
#define MAX_ENCRYPT_KEY_LEN 16

#include <stdint.h>
#include <string.h>
#include <iostream>
using namespace std;

void frame_xtea(int32_t* v, // 64bit of data [in/out]
    int32_t* o, // 64bits of data [out]
    int32_t* k, // 128bit key [in]
    int32_t n); // Routine rounds [in]

size_t frame_xtea_encrypt(char* buf_in, size_t buf_in_len, char* buf_out, size_t buf_out_len, const char key[16]);
size_t frame_xtea_decrypt(char* buf_in, size_t buf_in_len, char* buf_out, size_t buf_out_len, const char key[16]);
#endif
