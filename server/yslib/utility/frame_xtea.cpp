#include "frame_xtea.h"

void frame_xtea(int32_t* v, int32_t* o, int32_t* k, int32_t n)
{
    uint32_t y = v[0];
    uint32_t z = v[1];
    uint32_t delta = 0x9e3779b9; // 0x00000000 - 0x61C88647 == 0x9e3779b9

    if (n > 0)
    {
        // Encoding
        uint32_t limit = delta * n;
        uint32_t sum = 0;
        while (sum != limit)
        {
            y += (((z << 4) ^ (z >> 5)) + z) ^ (sum + k[sum & 3]);
            sum += delta;
            z += (((y << 4) ^ (y >> 5)) + y) ^ (sum + k[(sum>>11) & 3]);
        }
    }
    else
    {
        // Decoding
        uint32_t sum = delta * (-n);
        while (sum)
        {
            z -= (((y << 4) ^ (y >> 5)) + y) ^ (sum + k[(sum>>11) & 3]);
            sum -= delta;
            y -= (((z << 4) ^ (z >> 5)) + z) ^ (sum + k[sum & 3]);
        }
    }

    o[0] = y;
    o[1] = z;
}

/*****************************************************************************
//	加密后的Buffer结构
//  ┌──-----────┬──────────--------─┬---────┬─---───┐
//  │ PadLength   │  Padded Random BYTEs │  Data  │ Zero s │
//  ├──────-----┼───────--------────┼─---───┼───---─┤
//  │    1Byte    │    PadLength Bytes   │ N Bytes│ 7Bytes │
//  └─────-----─┴───────--------────┴───---─┴────---┘
// Pad部分用于将整个Buffer补齐到8字节对齐
******************************************************************************/
size_t frame_xtea_encrypt(char* buf_in, size_t buf_in_len, char* buf_out, size_t buf_out_len, const char key[16])
{
    if (buf_in == NULL || buf_in_len <= 0)
    {
        return 0;
    }
    //计算需要输出的buffer大小
    size_t zero = 1 + buf_in_len + ZERO_LENGTH;
    size_t pad_len = zero % ENCRYPT_BLOCK_LENGTH_IN_BYTE;
    size_t i;

    if (pad_len != 0)
    {
        pad_len = ENCRYPT_BLOCK_LENGTH_IN_BYTE - pad_len;
    }
    size_t total_len = zero + pad_len;

    if (total_len > buf_out_len || buf_out == NULL)
    {
        return -1;
    }

    char* ptmp_in = buf_in;
    char* ptmp_out = buf_out;
    memset(buf_out, 0, buf_out_len);

    char first[ENCRYPT_BLOCK_LENGTH_IN_BYTE] = {0};
    //第一个元素，只使用最低3位，其他用随机数填充
    first[0] = (((char)rand()) & 0xf8) | (char)pad_len;
    //用随机数填充余下的pad区域
    for (i=1; i <= pad_len; ++i)
    {
        first[i] = (char)rand();
    }
    //用待加密数据补充第一块明文
    for (i = 1+pad_len; i < ENCRYPT_BLOCK_LENGTH_IN_BYTE; ++i)
    {
        first[i] = *ptmp_in++;
    }
    // 上一个加密块的明文与密文，用于后面的异或操作
    char* plast_encrypt = buf_out;
    char* plast_plain = first;

    // 第一段Buffer，不需要异或操作
    frame_xtea((int32_t*) first, (int32_t*)ptmp_out, (int32_t*)key, ENCRYPT_ROUNDS);
    ptmp_out += ENCRYPT_BLOCK_LENGTH_IN_BYTE;

    // 下面这段是是用于不更改InBuffer的加密过程
    char src_buf[ENCRYPT_BLOCK_LENGTH_IN_BYTE] = {0};
    while ((ptmp_in - buf_in) < (buf_in_len - 1))
    {
        memcpy(src_buf, ptmp_in, ENCRYPT_BLOCK_LENGTH_IN_BYTE);
        //和上一块密文异或
        int32_t n ;
        for (n = 0; n < ENCRYPT_BLOCK_LENGTH_IN_BYTE; ++n)
        {
            src_buf[n] ^= plast_encrypt[n];
        }
        frame_xtea((int32_t*)src_buf, (int32_t*)ptmp_out, (int32_t*)key, ENCRYPT_ROUNDS);
        //和上一块明文异或
        for (n = 0; n < ENCRYPT_BLOCK_LENGTH_IN_BYTE; ++n)
        {
            ptmp_out[n] ^= plast_plain[n];
        }
        plast_encrypt = ptmp_out;
        plast_plain = ptmp_in;

        ptmp_in += ENCRYPT_BLOCK_LENGTH_IN_BYTE;
        ptmp_out += ENCRYPT_BLOCK_LENGTH_IN_BYTE;
    }

    // 结尾的 1Byte数据 + 7Byte 校验
    char last[ENCRYPT_BLOCK_LENGTH_IN_BYTE] = {0};
    memset(&last[0], 0, ENCRYPT_BLOCK_LENGTH_IN_BYTE);
    last[0] = *ptmp_in;

    //和上一块密文异或
    for (i=0; i < ENCRYPT_BLOCK_LENGTH_IN_BYTE; ++i)
    {
        last[i] ^= plast_encrypt[i];
    }
    frame_xtea((int32_t*)last, (int32_t*)ptmp_out, (int32_t*)key, ENCRYPT_ROUNDS);
    //和上一块明文异或
    for (i=0; i < ENCRYPT_BLOCK_LENGTH_IN_BYTE; ++i)
    {
        ptmp_out[i] ^= plast_plain[i];
    }

    return total_len;
}

size_t frame_xtea_decrypt(char* buf_in, size_t buf_in_len, char* buf_out, size_t buf_out_len, const char key[16])
{
    if (buf_in == NULL || buf_in_len <= 0)
    {
        return 0;
    }
    // Buffer长度应该是能被 ENCRYPT_BLOCK_LENGTH_IN_BYTE 整除的
    if (buf_in_len % ENCRYPT_BLOCK_LENGTH_IN_BYTE || buf_in_len <= 8)
    {
        return -1;
    }

    char* ptmp_in = buf_in;
    char* ptmp_out = buf_out;
    size_t i;

    // 先解出最前面包含Pad的ENCRYPT_BLOCK_LENGTH_IN_BYTE个Byte
    char first[ENCRYPT_BLOCK_LENGTH_IN_BYTE] = {0};
    frame_xtea((int32_t*)ptmp_in, (int32_t*)first, (int32_t*)key, DECRYPT_ROUNDS);
    ptmp_in += ENCRYPT_BLOCK_LENGTH_IN_BYTE;

    // Pad长度只是用了第一个字节的最低3bit，高5bit是随机数
    int32_t pad_len = first[0] & 0x07;
    // 计算原始数据的长度
    size_t plain_len = buf_in_len - 1/*PadLength Length*/ - pad_len - ZERO_LENGTH;
    if (plain_len <= 0 || buf_out == NULL)
    {
        return -2;
    }
    //out buffer 不够
    if (plain_len > buf_out_len)
    {
        return -3;
    }
    //前一块的明文和密文，用于后面的异或操作
    char* plast_encrypt = buf_in;
    char* plast_plain = first;

    //将第一块里Pad信息之后的数据移到输出Buffer
    for ( i=0; i < 7/*ENCRYPT_BLOCK_LENGTH_IN_BYTE - 1*/ - pad_len; ++i)
    {
        *ptmp_out++ = first[1 + pad_len + i];
    }
    //解密除了最后一块以外的所有块
    char src_buf[ENCRYPT_BLOCK_LENGTH_IN_BYTE] = {0};

    while ((ptmp_in - buf_in) < (buf_in_len - ENCRYPT_BLOCK_LENGTH_IN_BYTE))
    {
        int32_t n;
        memcpy(src_buf, ptmp_in, ENCRYPT_BLOCK_LENGTH_IN_BYTE);
        //和上一块明文异或
        for (n=0; n < ENCRYPT_BLOCK_LENGTH_IN_BYTE; ++n)
        {
            src_buf[n] ^= plast_plain[n];
        }
        frame_xtea((int32_t*)src_buf, (int32_t*)ptmp_out, (int32_t*)key, DECRYPT_ROUNDS);
        //和上一块密文异或
        for (n=0; n < ENCRYPT_BLOCK_LENGTH_IN_BYTE; ++n)
        {
            ptmp_out[n] ^= plast_encrypt[n];
        }
        plast_encrypt = ptmp_in;
        plast_plain = ptmp_out;

        ptmp_in += ENCRYPT_BLOCK_LENGTH_IN_BYTE;
        ptmp_out += ENCRYPT_BLOCK_LENGTH_IN_BYTE;
    }

    //最后8Byte， 最后有7Byte的校验
    char last[ENCRYPT_BLOCK_LENGTH_IN_BYTE] = {0};
    //和上一个8Byte明文异或
    memcpy(src_buf, ptmp_in, ENCRYPT_BLOCK_LENGTH_IN_BYTE);
    for (i=0; i < ENCRYPT_BLOCK_LENGTH_IN_BYTE; ++i)
    {
        src_buf[i] ^= plast_plain[i];
    }
    frame_xtea((int32_t*)src_buf, (int32_t*)last, (int32_t*)key, DECRYPT_ROUNDS);
    //和上一个8Byte密文异或
    for (i=0; i < ENCRYPT_BLOCK_LENGTH_IN_BYTE; ++i)
    {
        last[i] ^= plast_encrypt[i];
    }
    //校验最后的0
    for (i=1; i < ENCRYPT_BLOCK_LENGTH_IN_BYTE; ++i)
    {
        if (last[i] != 0)
        {
            return -4;
        }
    }
    *ptmp_out = last[0];

    return plain_len;
}
