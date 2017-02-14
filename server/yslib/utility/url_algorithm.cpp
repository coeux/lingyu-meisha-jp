#include "url_algorithm.h"

int url_algorithm_t::url_encode(const string& input_, string& output_)
{
    char hex[] = "0123456789ABCDEF";
    output_.clear();
    char* in = (char*)input_.data();

    for (size_t i = 0; i < input_.size(); i++)
    {
        unsigned char ch = in[i];
        if (isalnum(ch))
        {
            output_ += ch;
        }
        else if (ch == '_' || ch == '-' || ch == '.')
	    {
	       output_ += ch;
	    }
        else
        {
            if (in[i] == ' ')
            {
                output_ += '+';
            }
            else
            {
                unsigned char c = static_cast<unsigned char>(in[i]);
                output_ += '%';
                output_ += hex[c / 16];
                output_ += hex[c % 16];
            }
        }
    }

    return 0;
}

int url_algorithm_t::url_decode(const string& input_, string& output_)
{
	output_.clear();
    string dst;

    size_t srclen = input_.size();

    for (size_t i = 0; i < srclen; i++)
    {
        if (input_[i] == '%')
        {
            if (isxdigit(input_[i + 1]) && isxdigit(input_[i + 2]))
            {
                char c1 = input_[++i];
                char c2 = input_[++i];
                c1 = c1 - 48 - ((c1 >= 'A') ? 7 : 0) - ((c1 >= 'a') ? 32 : 0);
                c2 = c2 - 48 - ((c2 >= 'A') ? 7 : 0) - ((c2 >= 'a') ? 32 : 0);
                dst += (unsigned char)(c1 * 16 + c2);
            }
        }
        else
        {
            if (input_[i] == '+')
            {
                dst += ' ';
            }
            else
            {
                dst += input_[i];
            }
        }
    }

    unsigned int len = dst.size();

    for (unsigned int pos = 0; pos < len;)
    {
        unsigned int nvalue = utf8_decode((char *)dst.c_str(), &pos);
        output_ += (unsigned char)nvalue;
    }

    return 0;
}

unsigned int url_algorithm_t::utf8_decode(char *s, unsigned int *pi)
{
    unsigned int c;
    int i = *pi;
    /* one digit utf-8 */
    if ((s[i] & 128)== 0 ) {
        c = (unsigned int) s[i];
        i += 1;
    } else if ((s[i] & 224)== 192 ) { /* 110xxxxx & 111xxxxx == 110xxxxx */
        c = (( (unsigned int) s[i] & 31 ) << 6) +
            ( (unsigned int) s[i+1] & 63 );
        i += 2;
    } else if ((s[i] & 240)== 224 ) { /* 1110xxxx & 1111xxxx == 1110xxxx */
        c = ( ( (unsigned int) s[i] & 15 ) << 12 ) +
            ( ( (unsigned int) s[i+1] & 63 ) << 6 ) +
            ( (unsigned int) s[i+2] & 63 );
        i += 3;
    } else if ((s[i] & 248)== 240 ) { /* 11110xxx & 11111xxx == 11110xxx */
        c =  ( ( (unsigned int) s[i] & 7 ) << 18 ) +
            ( ( (unsigned int) s[i+1] & 63 ) << 12 ) +
            ( ( (unsigned int) s[i+2] & 63 ) << 6 ) +
            ( (unsigned int) s[i+3] & 63 );
        i+= 4;
    } else if ((s[i] & 252)== 248 ) { /* 111110xx & 111111xx == 111110xx */
        c = ( ( (unsigned int) s[i] & 3 ) << 24 ) +
            ( ( (unsigned int) s[i+1] & 63 ) << 18 ) +
            ( ( (unsigned int) s[i+2] & 63 ) << 12 ) +
            ( ( (unsigned int) s[i+3] & 63 ) << 6 ) +
            ( (unsigned int) s[i+4] & 63 );
        i += 5;
    } else if ((s[i] & 254)== 252 ) { /* 1111110x & 1111111x == 1111110x */
        c = ( ( (unsigned int) s[i] & 1 ) << 30 ) +
            ( ( (unsigned int) s[i+1] & 63 ) << 24 ) +
            ( ( (unsigned int) s[i+2] & 63 ) << 18 ) +
            ( ( (unsigned int) s[i+3] & 63 ) << 12 ) +
            ( ( (unsigned int) s[i+4] & 63 ) << 6 ) +
            ( (unsigned int) s[i+5] & 63 );
        i += 6;
    } else {
        c = '?';
        i++;
    }
    *pi = i;
    return c;
}
