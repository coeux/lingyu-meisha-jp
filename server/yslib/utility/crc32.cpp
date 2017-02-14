#include "crc32.h"

crc32_t::crc32_t()
{
	init_i();
}

crc32_t::~crc32_t()
{
}

void crc32_t::init_i()
{
	// This is the official polynomial used by CRC32 in PKZip.
	// Often times the polynomial shown reversed as 0x04C11DB7.
	uint32_t polynomial = 0xEDB88320;
	int i, j;

	uint32_t crc;
	for (i = 0; i < CRC32_TABLE_SIZE; i++)
	{
		crc = i;
		for (j = 8; j > 0; j--)
		{
			if (crc & 1)
				crc = (crc >> 1) ^ polynomial;
			else
				crc >>= 1;
		}
		m_crc32_table[i] = crc;
	}
}

inline void crc32_t::calc_crc32_i(const char byte_, uint32_t &crc32_) const
{
    crc32_ = ((crc32_) >> 8) ^ m_crc32_table[(unsigned char)((byte_) ^ ((crc32_) & 0x000000FF))];
}

int crc32_t::memory_crc32(const char* data_, uint32_t size_, uint32_t &crc32_) const
{
	int ret = NO_ERROR;

	crc32_ = 0xFFFFFFFF;

	try
	{
		for (uint32_t loop = 0; loop < size_; loop++)
		{
		    calc_crc32_i(data_[loop], crc32_);
		}
	}
	catch (...)
	{
		// An unknown exception happened, or the table isn't initialized
		ret = ERROR_CRC;
	}

	crc32_ = ~crc32_;

	return ret;
}

