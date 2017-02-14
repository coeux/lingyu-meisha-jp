#include "zlib_util.h"

extern "C"
{
#include <zlib.h>	
}

#define CHUNK 2048
#define BUFFER_INC_FACTOR 2

#ifdef USE_TBB_MALLOC

#include <tbb/scalable_allocator.h>

#endif

int zlib_util_t::compress( char* in, uint32_t inLength, char** out)
{
    int err = Z_OK;
    int outLength = 0;
    int bufferSize = inLength;
#ifdef USE_TBB_MALLOC
    *out = (char*)scalable_malloc(sizeof(char) * bufferSize);
#else
    *out = (char*)malloc(sizeof(char) * bufferSize);
#endif

    z_stream d_stream; /* decompression stream */    
    d_stream.zalloc = (alloc_func)0;
    d_stream.zfree = (free_func)0;
    d_stream.opaque = (voidpf)0;

    d_stream.next_in  = (Bytef*)in;
    d_stream.avail_in = inLength;
    d_stream.next_out = (Bytef*)*out;
    d_stream.avail_out = bufferSize;

    if( deflateInit2(&d_stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, -MAX_WBITS, 8, Z_DEFAULT_STRATEGY) != Z_OK )
    {
        free(*out);
        return -1;
    }

    for( ; ; )
    {
        err = deflate(&d_stream, Z_SYNC_FLUSH);
        if( err != Z_OK )
        {
            free(*out);
            return -1;
        }

        if( d_stream.avail_out == 0 )
        {
#ifdef USE_TBB_MALLOC
            *out = (char*)scalable_realloc(*out, sizeof(char) * bufferSize * BUFFER_INC_FACTOR);
#else
            *out = (char*)realloc(*out, sizeof(char) * bufferSize * BUFFER_INC_FACTOR);
#endif
            d_stream.next_out = (Bytef*)(*out + bufferSize);
            d_stream.avail_out = bufferSize;
            bufferSize = bufferSize * BUFFER_INC_FACTOR;
        }
        else
        {
            break;
        }
    }

    outLength = d_stream.total_out;
    deflateEnd(&d_stream);
    return outLength;
}

int zlib_util_t::compress(const string& input, string& output)
{
    int ret, flush;
    unsigned have;
    z_stream strm;
    char in[CHUNK];
    char out[CHUNK];

    output.clear();        
    // allocate deflate state
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    //ret = deflateInit(&strm, Z_DEFAULT_COMPRESSION);
    ret = deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, -MAX_WBITS, 8, Z_DEFAULT_STRATEGY);
    if (ret != Z_OK)
        return -1;

    int length = input.size();
    int copied = 0;
    // compress until end of file
    do {
        strm.avail_in = (int)input.copy(in, CHUNK, copied);
        copied += strm.avail_in;
        flush = (length == copied) ? Z_FINISH : Z_SYNC_FLUSH;//Z_NO_FLUSH;
        strm.next_in = (Bytef*)in;

        // run deflate() on input until output buffer not full, finish compression if all of source has been read in
        do {
            strm.avail_out = CHUNK;
            strm.next_out = (Bytef*)out;
            ret = deflate(&strm, flush);    // no bad return value
            if(ret == Z_STREAM_ERROR)
            {
                return -1;
            }
            have = CHUNK - strm.avail_out;
            output.append(out, have);
        } while (strm.avail_out == 0);
        // assert(strm.avail_in == 0);     // all input will be used

        // done when last data in file processed
    } while (flush != Z_FINISH);
    //assert(ret == Z_STREAM_END);        // stream will be complete

    // clean up and return
    (void)deflateEnd(&strm);
    return 0;
}

int zlib_util_t::uncompress(const string& input, string& output)
{
    int ret;
    unsigned have;
    z_stream strm;
    char in[CHUNK];
    char out[CHUNK];
    output.clear();

    /* allocate inflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = 0;
    strm.next_in = Z_NULL;
    ret = inflateInit2(&strm, -MAX_WBITS);
    if (ret != Z_OK)
        return ret;

    int copied = 0;
    /* decompress until deflate stream ends or end of file */
    do {
        strm.avail_in = (int)input.copy(in, CHUNK, copied);
        copied += strm.avail_in;    
        if (strm.avail_in == 0)
            break;
        strm.next_in = (Bytef*)in;

        /* run inflate() on input until output buffer not full */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = (Bytef*)out;
            ret = inflate(&strm, Z_NO_FLUSH);
            //assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            if(ret == Z_STREAM_ERROR) return -1;
            switch (ret) {
                case Z_NEED_DICT:
                    ret = Z_DATA_ERROR;     /* and fall through */
                case Z_DATA_ERROR:
                case Z_MEM_ERROR:
                    (void)inflateEnd(&strm);
                    return ret;
            }
            have = CHUNK - strm.avail_out;
            output.append(out, have);
        } while (strm.avail_out == 0);

        /* done when inflate() says it's done */
    } while (ret != Z_STREAM_END);

    /* clean up and return */
    (void)inflateEnd(&strm);
    return (ret == Z_STREAM_END) ? 0 : (-1);
}
