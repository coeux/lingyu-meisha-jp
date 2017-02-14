#ifndef _91Hash2MD5Hex_h_
#define _91Hash2MD5Hex_h_

#include <string>
using namespace std;

#include "singleton.h"

class  HexBin 
{
    enum
    {
        BASELENGTH   = 128,
        LOOKUPLENGTH = 16,
    };

    typedef uint8_t byte;
    uint8_t hexNumberTable[BASELENGTH]; 
    char lookUpHexAlphabet[LOOKUPLENGTH]; 
public:
    HexBin()
    {
        for (int i = 0; i < BASELENGTH; i++ ) {
            hexNumberTable[i] = -1;
        }
        for ( int i = '9'; i >= '0'; i--) {
            hexNumberTable[i] = (byte) (i-'0');
        }
        for ( int i = 'F'; i>= 'A'; i--) {
            hexNumberTable[i] = (byte) ( i-'A' + 10 );
        }
        for ( int i = 'f'; i>= 'a'; i--) {
            hexNumberTable[i] = (byte) ( i-'a' + 10 );
        }

        for(int i = 0; i<10; i++ ) {
            lookUpHexAlphabet[i] = (char)('0'+i);
        }
        for(int i = 10; i<=15; i++ ) {
            lookUpHexAlphabet[i] = (char)('A'+i -10);
        }
    }

    /***
     *      * Encode a byte array to hex string
     *           *
     *                * @param binaryData array of byte to encode
     *                     * @return return encoded string
     *                          */
    string encode(unsigned char* binaryData, size_t lengthData) {
        if (binaryData == NULL)
            return "";

        size_t lengthEncode = lengthData * 2;
        string encodedData;
        encodedData.assign(lengthEncode, 0);

        int temp;
        for (size_t i = 0; i < lengthData; i++) {
            temp = (int)binaryData[i];
            if (temp < 0)
                temp += 256;
            encodedData[i*2] = (char)(lookUpHexAlphabet[temp >> 4]);
            encodedData[i*2+1] = (char)(lookUpHexAlphabet[temp & 0xf]);
        }
        return encodedData;
    }

    /***
     *      * Decode hex string to a byte array
     *           *
     *                * @param encoded encoded string
     *                     * @return return array of byte to encode
     *                          */
    string decode(const string& encoded) {
        if (encoded.empty() )
            return "";
        size_t lengthData = encoded.size();
        if (lengthData % 2 != 0)
            return "";

        const char* binaryData = encoded.c_str();
        size_t lengthDecode = lengthData / 2;
        string decodedData;
        decodedData.assign(lengthDecode, 0);
        uint8_t temp1, temp2;
        uint8_t tempChar;
        for( size_t i = 0; i<lengthDecode; i++ ){
            tempChar = (uint8_t)binaryData[i*2];
            temp1 = (tempChar < BASELENGTH) ? hexNumberTable[tempChar] : -1;
            if (temp1 == -1)
                return "";
            tempChar = (uint8_t)binaryData[i*2+1];
            temp2 = (tempChar < BASELENGTH) ? hexNumberTable[tempChar] : -1;
            if (temp2 == -1)
                return "";
            decodedData[i] = (char)((temp1 << 4) | temp2);
        }
        return decodedData;
    }
};

#define MD5Hex (singleton_t<HexBin>::instance())

#endif
