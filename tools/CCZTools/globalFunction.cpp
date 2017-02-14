#include "stdafx.h"
#include "globalFunction.h"

#include "CCZHeader.h"


void globalInit( void )
{
	Phoenix::Init();
	Eidolon::Init();
}

void globalExit( void )
{
	Eidolon::Exist();
	Phoenix::Exist();
}

void converter2CCZ( const std::string& SrcFileName )
{
	bool dither = true;

	Phoenix::String imageName;
	Phoenix::OperationSystem::GetFileWithoutExtensionName(SrcFileName, imageName);

	Phoenix::String oldExtName;
	Phoenix::OperationSystem::GetFileExtensionName(SrcFileName, oldExtName);

	//加载到内存
	FILEOPENINFO info = FileSystem::GetSingleton().OpenFile(SrcFileName, FileSystem::READONLY);
	if( info.m_FileHandle == 0 )
	{
		String err = _T("读取文件时");
		err +=  SrcFileName;
		err += _T("文件不存在！");

		PHOENIX_EXCEPT(err);
	}

	Codec* pCodec = Codec::GetCodec(oldExtName);
	Codec::DecodeResult dr = pCodec->Decode(info.m_DataStreamPtr);
	ImageCodec::ImageData* pData = static_cast<ImageCodec::ImageData*>( dr.second.get() );

	FileSystem::GetSingleton().CloseFile(info);

	char* pSrcBuffer;
	long srcLen;
	dr.first->GetBufferData(pSrcBuffer, srcLen);

	PixelBox srcBox(pData->m_Width, pData->m_Height, pData->m_Depth, pData->m_Format, pSrcBuffer);

	Phoenix::uint64 u64PixelFormat;
	if( pData->m_Format == PF_BYTE_RGB )
	{
		u64PixelFormat = kPVR3TexturePixelFormat_RGB_888;
	}
	else if( pData->m_Format == PF_BYTE_RGBA )
	{
		u64PixelFormat = kPVR3TexturePixelFormat_RGBA_8888;
	}
	
	CPVRTextureHeader header(u64PixelFormat, pData->m_Height, pData->m_Width);
	CPVRTexture texture(header, pSrcBuffer);

	if( oldExtName == "jpg" )
	{
		Transcode(texture, kPVR3TexturePixelFormat_RGB_565, ePVRTVarTypeUnsignedByteNorm, ePVRTCSpacelRGB, ePVRTCBest, dither);
	}
	else if( oldExtName == "png" )
	{
		Transcode(texture, kPVR3TexturePixelFormat_RGBA_4444, ePVRTVarTypeUnsignedByteNorm, ePVRTCSpacelRGB, ePVRTCBest, dither);
	}

	Phoenix::String tmpName = imageName;
	tmpName += ".pvr";

	CPVRTString str( tmpName.c_str(), tmpName.length() );
	texture.saveFile(str);

	//读取文件
	info = FileSystem::GetSingleton().OpenFile(tmpName, FileSystem::READONLY);
	ulong srcLength = info.m_DataStreamPtr->Length();
	uchar* pSrc = (uchar*)PMalloc(srcLength);
	info.m_DataStreamPtr->Read((char*)pSrc, srcLength);
	FileSystem::GetSingleton().CloseFile(info);

	//删除文件
	Phoenix::OperationSystem::DeleteFile(tmpName);

	//压缩文件
	ulong outLength = srcLength;
	uchar* pDst = (uchar*)PMalloc(outLength);

	while( !Phoenix::ZipUtils::DeflateCCZMemory(pSrc, srcLength, &pDst, &outLength) )
	{
		//没有成功分配更大的空间
		outLength *= 2;
		pDst = (uchar*)PRealloc(pDst, outLength);
	}

	PFree(pSrc);

	//保存文件
	imageName += ".ccz";
	FILE* fp;
	if( fopen_s( &fp, imageName.c_str(), _T("w+b") ) != 0 )
	{
		PFree(pDst);
		PHOENIX_EXCEPT( _T("创建") + imageName + _T("文件时出错！") );
	}

	CCZHeader h;
	h.sig[0] = 'C';
	h.sig[1] = 'C';
	h.sig[2] = 'Z';
	h.sig[3] = '!';
	h.reserved = 0;
	h.len = CC_SWAP_INT32_BIG_TO_HOST(srcLength);
	h.version = CC_SWAP_INT16_BIG_TO_HOST(1);
	h.compression_type = CC_SWAP_INT16_BIG_TO_HOST(0);

	if( fwrite(&h, sizeof(CCZHeader), 1, fp) != 1 )
	{
		PFree(pDst);
		PHOENIX_EXCEPT( _T("写文件失败！") );
	}

	if( fwrite(pDst, outLength, 1, fp) != 1 )
	{
		PFree(pDst);
		PHOENIX_EXCEPT( _T("写文件失败！") );
	}

	fclose(fp);
	PFree(pDst);

}
