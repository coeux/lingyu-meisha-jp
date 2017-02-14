#ifndef _ys_socket_h_
#define _ys_socket_h_

#ifdef WIN32
#include <windows.h>
#include <WinSock.h>
#pragma comment(lib, "wsock32")  
#else
#include <sys/socket.h>
#include <fcntl.h>
#include <errno.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#define SOCKET int
#define SOCKET_ERROR -1
#define INVALID_SOCKET -1
#endif

#include <stdio.h>
#include <string.h>

//包头长8字就节
#define HEADLEN 8

#define MAX_PKSIZE (16*1024)

//接收缓冲大小
#define INBUFSIZE	(64*1024)

//发送缓冲大小
#define OUTBUFSIZE	(8*1024)

//此为非阻塞socket，在主循环里可以直接使用
class ys_socket_t {
public:
	ys_socket_t();
	//链接
	bool	connect(const char* ip_, int port_);

	//发送
	bool	send(const char* buf_, int size_);
	//每一帧都尝试更新发送缓冲
	bool	flush();

	//接收，每一帧都尝试接收数据, 如果返回true，则接收成功，进入解包流程
	bool	recv(void* buf_, int& size_);

	//查看socket连接是否正常
	bool	peek();

	//查看是否出错
	bool    has_error(int* err_=NULL);			

	//关闭当前socket，释放socket资源
	void	close();

	//获得socket句柄
	SOCKET	sock() const { return m_sock; }
private:
	bool	recv_i();		

	SOCKET	m_sock;

	char	m_outbuf[OUTBUFSIZE];
	int		m_outbuf_len;

	char	m_inbuf[INBUFSIZE];
	int		m_inbuf_len;
};

#endif
