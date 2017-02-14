
#ifndef _MD5_PROCESS_H_
#define _MD5_PROCESS_H_

#include <string>
using namespace std;

#include "md5.h"

static char convert_char(const char& input_)
{
    if( input_ == 0x00 )
        return '0';

    if( input_ == 0x01 )
        return '1';

    if( input_ == 0x02 )
        return '2';

    if( input_ == 0x03 )
        return '3';

    if( input_ == 0x04 )
        return '4';

    if( input_ == 0x05 )
        return '5';

    if( input_ == 0x06 )
        return '6';

    if( input_ == 0x07 )
        return '7';

    if( input_ == 0x08 )
        return '8';

    if( input_ == 0x09 )
        return '9';

    if( input_ == 0x0a )
        return 'a';

    if( input_ == 0x0b )
        return 'b';

    if( input_ == 0x0c )

        return 'c';

    if( input_ == 0x0d )
        return 'd';

    if( input_ == 0x0e )
        return 'e';

    if( input_ == 0x0f )
        return 'f';

    return '0';
}

static void convert_bin_to_asc(const char* in_, const int in_len_, string& str_dest_)
{
    char sz_tmp[in_len_ * 2 + 1];
    memset(sz_tmp, 0, sizeof(sz_tmp));

    int k = 0;
    for(int j = 0; j < in_len_; j++)
    {
        sz_tmp[k] = convert_char((in_[j] >> 4) & 0x0F);
        sz_tmp[k + 1] = convert_char(in_[j] & 0x0F);
        k += 2;
    }

    str_dest_.append(sz_tmp, in_len_ * 2);
}

static int md5_process(const string& str_src_, string& str_dest_)
{
    MD5_CTX md5;
    char sz_md5[16] = {0};

    memcpy(sz_md5, md5.MD5((unsigned char*)str_src_.c_str(), (int)str_src_.length()), sizeof(sz_md5));

    convert_bin_to_asc(sz_md5, 16, str_dest_);

    return 0 ;
}

#endif //! _MD5_PROCESS_H_

