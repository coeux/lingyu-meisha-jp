#ifndef _CRC32_H_
#define _CRC32_H_

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include <iostream>
using namespace std;

#define NO_ERROR (0)
#define ERROR_CRC (-1)

class crc32_t
{
    enum
    {
        CRC32_TABLE_SIZE = 256
    };

public:
	crc32_t();
	~crc32_t();

	int memory_crc32(const char* data_, uint32_t size_, uint32_t &crc32_) const;

private:
    void init_i();
	void calc_crc32_i(const char byte_, uint32_t &crc32_) const;

private:
	uint32_t m_crc32_table[CRC32_TABLE_SIZE];
};

//! Usage:
//! singleton_t<crc32_t>::instance().memory_crc32();

#endif
