#include "record_msg.h"
#include "log.h"

#define LOG "RECMSG"

void record_msg_t::write(uint64_t seskey_, uint16_t cmd_, const string& body_)
{
    uint32_t uid = m_ses_uid_map[seskey_];

    static const char path[] = "/tmp/rec_msg/";
	int rc = access(path, F_OK);
	if (0 != rc)
	{	// 目录不存在,创建
		rc = mkdir(path, 0777);
		if (rc != 0)
		{
            logerror((LOG, "create %s failed!", path));
			return;
		}
	}

    static char fullpath[256];
    sprintf(fullpath, "%s/%u.rec", path, uid);
    FILE* file = fopen(fullpath, "ab");
    if (file == NULL)
    {
        logerror((LOG, "open or create rec file:%s failed!", fullpath));
        return;
    }

    uint32_t len = body_.size();
    uint16_t cmd = cmd_;
    uint16_t res = 0;
    fwrite(&len, 4, 1, file);
    fwrite(&cmd, 2, 1, file);
    fwrite(&res, 2, 1, file);
    if (body_.size() > 0)
        fwrite(body_.c_str(), body_.size(), 1, file);

    fclose(file);
}

void record_msg_t::reg(uint64_t seskey_, uint32_t uid_) 
{ 
    m_ses_uid_map[seskey_] = uid_; 
}

void record_msg_t::unreg(uint64_t seskey_)
{
    m_ses_uid_map.erase(seskey_);
}

