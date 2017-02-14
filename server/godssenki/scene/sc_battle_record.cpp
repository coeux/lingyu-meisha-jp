#include "sc_battle_record.h"
#include "log.h"
#include <sys/time.h>
#include <stdio.h>
#include <unistd.h>
#include "config.h"

#define LOG "BATTLE_REC"

sc_battle_record_t::sc_battle_record_t():
open_record(false)
{
}

void sc_battle_record_t::add_record(int frame_, record_t&& record_)
{
    if (!open_record)
        return;

    if (records.size() < (size_t)frame_)
    {
        vector<record_t> rs;
        rs.push_back(std::move(record_));
        records.push_back(std::move(rs));
    }
    else
    {
        records[frame_-1].push_back(std::move(record_));
    }
}

void sc_battle_record_t::flush()
{
    if (!open_record)
        return;

    time_t timep = time(NULL);
    struct tm *tmp = localtime(&timep);

    const char* path = config.res.bt_record_path.c_str();
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
    char full_path[256];
    sprintf(full_path, "%s/%04d%02d%02d",
            path,
            (tmp->tm_year + 1900),
            (tmp->tm_mon + 1),
            tmp->tm_mday
           );
    rc = access(full_path, F_OK);
    if (rc != 0)
    {
        rc = mkdir(full_path, 0777);
        if (rc != 0)
        {
            logerror((LOG, "create %s failed!", full_path));
            return;
        }
    }

    char bk_path[256];
    sprintf(bk_path, "%s/%uvs%u_%02d%02d%02d.bak", 
        full_path, caster->uid, target->uid, 
        tmp->tm_hour,
        tmp->tm_min,
        tmp->tm_sec);

    logname = bk_path;

    FILE* file = fopen(bk_path, "wb");
    if (file == NULL)
        return;

    string str_caster, str_target;
    *caster >> str_caster;
    size_t caster_len = str_caster.size();
    fwrite(&caster_len, 4, 1, file);
    fwrite(str_caster.c_str(), caster_len, 1, file);

    *target >> str_target;
    size_t target_len = str_caster.size();
    fwrite(&target_len, 4, 1, file);
    fwrite(str_target.c_str(), target_len, 1, file);
    
    for(size_t i=0; i<records.size(); i++)
    {
        record_head_t head;
        
        head.frame = i+1;
        head.n = records[i].size();
        fwrite(&head, sizeof(head), 1, file);

        vector<record_t>& rs = records[i];
        for(size_t j=0; j<rs.size(); j++)
        {
            record_t& rc = rs[j];
            fwrite(&rc, sizeof(rc), 1, file);
        }
    }
    fclose(file);
    records.clear();
}
