#ifndef _decode_h_
#define _decode_h_

#include <stdint.h>

uint32_t InflateMemory( char* in, uint32_t inLength, char** out, uint32_t* outTotalBuffLength );

#endif
