#include "sc_user_rec.h"
#include "ticker.h"
#include "log.h"

#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/syscall.h>
#define gettid() syscall(SYS_gettid)

#define LOG "USER_REC"

int sc_user_rec_t::init(uint32_t uid_, uint32_t resid_)
{
    m_msgs.clear();

    static const char path[] = "./rec/";
	int rc = access(path, F_OK);
	if (0 != rc)
	{	// 目录不存在,创建
		rc = mkdir(path, 0777);
		if (rc != 0)
		{
            logerror((LOG, "create %s failed!", path));
			return -1;
		}
	}

    char fullpath[256];
    sprintf(fullpath, "%s/usr_%u_%u.rec", path, uid_, resid_);

    m_cur_sn = 0;
    char usr_rec_path[256];
	while (true)
	{
		sprintf(usr_rec_path, "%s.%d", 
            fullpath, m_cur_sn);

		int rc = access(usr_rec_path, F_OK);
		if (0 == rc) {
			m_cur_sn++;
			continue;
		}
		break;
	}

    m_fullpath = usr_rec_path;

    return 0;
}

void sc_user_rec_t::add_msg(uint16_t cmd_, const string& msg_)
{
    rec_t rec;
    rec.head.cmd = cmd_;
    rec.head.len = msg_.size();
    rec.head.stmp = time(NULL);
    rec.msg = msg_;
    m_msgs.push_back(std::move(rec));
}

int sc_user_rec_t::flush()
{
    FILE* file = fopen(m_fullpath.c_str(), "wb");
    if (file == NULL)
    {
        logerror((LOG, "create %s failed!", m_fullpath.c_str()));
        return -1;
    }

    for(size_t i=0; i<m_msgs.size(); i++)
    {
        rec_t& rec = m_msgs[i];
        fwrite(&rec.head, sizeof(rec.head), 1, file);
        fwrite((void*)rec.msg.c_str(), rec.msg.size(), 1, file);
    }

    fclose(file);
    return 0;
}
