#include "decode.h"
#include <stdio.h>
#include <stdlib.h>
#include <boost/thread.hpp>

boost::mutex g_mutex;

extern "C"
{
#include <zlib.h>	
}

#define BUFFER_INC_FACTOR 2

uint32_t InflateMemory( char* in, uint32_t inLength, char** out, uint32_t* outTotalBuffLength )
{
    boost::mutex::scoped_lock lock( g_mutex );      

    int err = Z_OK;
    uint32_t outLength = 0;

    *outTotalBuffLength = 256 * 1024;
    *out = (char*)malloc(sizeof(char) * (*outTotalBuffLength));

    z_stream d_stream; /* decompression stream */    
    d_stream.zalloc = (alloc_func)0;
    d_stream.zfree = (free_func)0;
    d_stream.opaque = (voidpf)0;

    d_stream.next_in  = (Bytef*)in;
    d_stream.avail_in = inLength;
    d_stream.next_out = (Bytef*)*out;
    d_stream.avail_out = *outTotalBuffLength;

    if( inflateInit2(&d_stream, -MAX_WBITS) != Z_OK )
    {
        free(*out);
        *outTotalBuffLength = 0;
        return outLength;
    }

    for( ; ; )
    {
        err = inflate(&d_stream, Z_SYNC_FLUSH);
        if( err != Z_OK )
        {
            free(*out);
            *outTotalBuffLength = 0;
            return outLength;
        }

        if( d_stream.avail_out == 0 )
        {
            *out = (char*)realloc(*out, sizeof(char) * (*outTotalBuffLength) * BUFFER_INC_FACTOR);

            d_stream.next_out = (Bytef*)*out + (*outTotalBuffLength);
            d_stream.avail_out = (*outTotalBuffLength) * (BUFFER_INC_FACTOR - 1);
            *outTotalBuffLength = (*outTotalBuffLength) * BUFFER_INC_FACTOR;
        }
        else
        {
            break;
        }
    }

    outLength = d_stream.total_out;
    inflateEnd(&d_stream);
    return outLength;
}
