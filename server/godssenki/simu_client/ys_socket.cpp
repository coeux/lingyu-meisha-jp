#include "ys_socket.h"
#include <assert.h>
#include <string.h>

ys_socket_t::ys_socket_t()
{ 
}

bool ys_socket_t::connect(const char* ip_, int port_)
{
	if(ip_ == 0 || strlen(ip_) > 15) {
		return false;
	}

#ifdef WIN32
	WSADATA wsaData;
	WORD version = MAKEWORD(2, 0);
	int ret = WSAStartup(version, &wsaData);//win sock start up
	if (ret != 0) {
		return false;
	}
#endif

	// 创建套接字
	m_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if(m_sock == INVALID_SOCKET) {
		close();
		return false;
	}

	// 设置SOCKET为KEEPALIVE
	int optval=1;
	if(setsockopt(m_sock, SOL_SOCKET, SO_KEEPALIVE, (char *) &optval, sizeof(optval)))
	{
		close();
		return false;
	}

	// 设置为非阻塞方式
#ifdef WIN32
	DWORD nMode = 1;
	int nRes = ioctlsocket(m_sock, FIONBIO, &nMode);
	if (nRes == SOCKET_ERROR) {
		close();
		return false;
	}
#else
	fcntl(m_sock, F_SETFL, O_NONBLOCK);
#endif

	unsigned long serveraddr = inet_addr(ip_);
	if(serveraddr == INADDR_NONE)	// 检查IP地址格式错误
	{
		close();
		return false;
	}

	sockaddr_in	addr_in;
	memset((void *)&addr_in, 0, sizeof(addr_in));
	addr_in.sin_family = AF_INET;
	addr_in.sin_port = htons(port_);
	addr_in.sin_addr.s_addr = serveraddr;

	m_inbuf_len = 0;
	m_outbuf_len = 0;

	struct linger so_linger;
	so_linger.l_onoff = 1;
	so_linger.l_linger = 500;
	setsockopt(m_sock, SOL_SOCKET, SO_LINGER, (const char*)&so_linger, sizeof(so_linger));

    int timeout_n = 0;
begin_connect:
	if(::connect(m_sock, (sockaddr *)&addr_in, sizeof(addr_in)) == SOCKET_ERROR) {
        int err;
		if (has_error(&err)) {
            switch(err)
            {
            case 114: 
                timeout_n++;
                if (timeout_n < 3)
                {
                    printf("timeout_n:%d\n", timeout_n);
                    sleep(1);
                    goto begin_connect;
                }
            break;
            }
            printf("has error:%d, %s\n", err, strerror(err));
			close();
			return false;
		}
		else	// WSAWOLDBLOCK
		{
            goto begin_connect;
begin_select:
			timeval timeout;
			timeout.tv_sec	= 1;
			timeout.tv_usec	= 0;
			fd_set readset, writeset, exceptset;
			FD_ZERO(&readset);
			FD_ZERO(&writeset);
			FD_ZERO(&exceptset);
			FD_SET(m_sock, &readset);
			FD_SET(m_sock, &writeset);
			FD_SET(m_sock, &exceptset);

			int ret = select(FD_SETSIZE, &readset, &writeset, &exceptset, &timeout);
            //出错
            if (ret < 0) {
				close();
				return false;
			} 
            //超时
            else if (ret == 0)
            {
                timeout_n++;
                printf("timeout....%d\n", timeout_n);
                if (timeout_n >= 3)
                {
                    close();
                    return false;
                }
                goto begin_select;
            }
            else	// ret > 0
			{
                //socket的读写未准备好
                if (!FD_ISSET(m_sock, &readset) && !FD_ISSET(m_sock, &writeset)) 
                {
                    close();
                    return false;
                }
                //存在异常数据
                else if (FD_ISSET(m_sock, &exceptset))
                {
					close();
					return false;
                }
                else
                {
                    int err = 0;
                    socklen_t len = 0;
                    //存在异常数据
                    if(getsockopt(m_sock, SOL_SOCKET, SO_ERROR, &err, &len))		// or (!FD_ISSET(m_sock, &writeset)
                    {
                        printf("connect err:%d\n", err);
                        close();
                        return false;
                    }
                }
			}
		}
	}

	return true;
}

bool ys_socket_t::send(void* buff_, int size_)
{
	if(buff_ == 0 || size_ <= 0) {
		return false;
	}

	if (m_sock == INVALID_SOCKET) {
		return false;
	}

	//每次发送都先刷新发送缓冲区
	if(m_outbuf_len + size_ > OUTBUFSIZE) {
		flush();
		if(m_outbuf_len + size_ > OUTBUFSIZE) {
			close();
			return false;
		}
	}
	// 数据添加到BUF尾
	memcpy(m_outbuf + m_outbuf_len, buff_, size_);
	m_outbuf_len += size_;
	return true;
}

bool ys_socket_t::recv(void* buf_, int& size_)
{
	//检查参数
	if(buf_ == NULL) {
		return false;
	}

	if (m_sock == INVALID_SOCKET) {
		return false;
	}

    recv_i(); 

	//尝试接收包头
	if (m_inbuf_len >= HEADLEN)
	{
        //检查包长度
        unsigned int len = 0;
        memcpy(&len, m_inbuf, sizeof(len));
        int pksize = len + HEADLEN;
        if (pksize <= m_inbuf_len)
        {
            //收到包体
            memcpy(buf_, m_inbuf, pksize);
            size_ = pksize;
            m_inbuf_len -= pksize;
            if (m_inbuf_len > 0)
            {
                memmove(m_inbuf, m_inbuf+pksize, m_inbuf_len);
            }
            return true;
        }
	}

	return	false;
}

bool ys_socket_t::has_error(int* err_/* =NULL */)
{
#ifdef WIN32
	int err = WSAGetLastError();
	if(err != WSAEWOULDBLOCK) {
#else
	int err = errno;
	if(err != EINPROGRESS && err != EAGAIN) {
#endif
		if (err_)
			*err_ = err;
		return true;
	}

	return false;
}

bool ys_socket_t::recv_i()
{
	if (m_inbuf_len >= INBUFSIZE || m_sock == INVALID_SOCKET) {
		return false;
	}

	int gotlen = ::recv(m_sock, m_inbuf + m_inbuf_len, INBUFSIZE-m_inbuf_len, 0);
	if(gotlen > 0) {
        printf("gotlen:[%d]\n", gotlen);
		m_inbuf_len += gotlen;
		assert(m_inbuf_len <= INBUFSIZE);
	} else if(gotlen == 0) {
		close();
		return false;
	} else {
		//非阻塞的情况下有可能返回小于0值，但不一定是出错
		if (has_error()) {
			close();
			return false;
		}
	}
	return true;
}

bool ys_socket_t::flush(void)
{
	if (m_sock == INVALID_SOCKET) {
		return false;
	}

	if(m_outbuf_len <= 0) {
		return false;
	}

	int outlen = ::send(m_sock, m_outbuf, m_outbuf_len, 0);
    printf("outlen:[%d]\n", outlen);
	if(outlen > 0) {
		// 删除已发送的部分
		if(m_outbuf_len - outlen > 0) {
			memcpy(m_outbuf, m_outbuf + outlen, m_outbuf_len - outlen);
		}

		m_outbuf_len -= outlen;

		if (m_outbuf_len < 0) {
			return false;
		}
	} else {
		if (has_error()) {
			close();
			return false;
		}
	}

	return true;
}

bool ys_socket_t::peek()
{
	if (m_sock == INVALID_SOCKET) {
		return false;
	}

	char buf[1];
	int	ret = ::recv(m_sock, buf, 1, MSG_PEEK);
    if (ret > 0)
        return true;
    else if (ret == -1 && !has_error())
        return true;
    else
    {
		close();
        return false;
    }
    /*
	if(ret == 0) {
		close();
		return false;
	} else if(ret < 0) {
		if (has_error()) {
			close();
			return false;
		} else {	// 阻塞
			return true;
		}
	} else {	// 有数据
		return true;
	}
	return true;
    */
}

void ys_socket_t::close(void)
{
	// 关闭
	struct linger so_linger;
	so_linger.l_onoff = 1;
	so_linger.l_linger = 500;
	setsockopt(m_sock, SOL_SOCKET, SO_LINGER, (const char*)&so_linger, sizeof(so_linger));
#ifdef WIN32
	closesocket(m_sock);
	WSACleanup();
#else
	::close(m_sock);
#endif
	m_sock = INVALID_SOCKET;
	m_inbuf_len = 0;
	m_outbuf_len = 0;
}
