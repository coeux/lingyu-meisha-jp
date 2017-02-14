
#ifndef AFC_MD5_H
#define AFC_MD5_H

class MD5_CTX 
{
private:
	unsigned int				state[4];
	unsigned int				count[2];
	unsigned char				buffer[64];  
	unsigned char				PADDING[64];

public:
	MD5_CTX();
	~MD5_CTX();
	void MD5Update ( unsigned char *input, unsigned int inputLen);
	void MD5Final (unsigned char digest[16]);

	unsigned char*	MD5(unsigned char* src, int Len);

private:
	void MD5Init();
	void MD5Transform (unsigned int state[4], unsigned char block[64]);
	void MD5_memcpy (unsigned char* output, unsigned char* input,unsigned int len);
	void Encode (unsigned char *output, unsigned int *input,unsigned int len);
	void Decode (unsigned int *output, unsigned char *input, unsigned int len);
	void MD5_memset (unsigned char* output,int value,unsigned int len);
};

#endif //! AFC_MD5_H
