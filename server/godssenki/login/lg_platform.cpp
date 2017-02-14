#include "lg_platform.h"
#include "http_curl.h"
#include "91msg_def.h"
#include "91Hash2MD5Hex.h"
#include "code_def.h"
#include "log.h"
#include "config.h"
#include "md5.h"

#define md5 (singleton_t<MD5_CTX>::instance())

lg_platform_t::lg_platform_t()
{
}

int lg_platform_t::verify(const string& domain_, const string& jinfo_)
{
    if (domain_ == "Joyyou")
    {
        return SUCCESS;
    }
    else if (domain_ == "91")
    {
        return verify91(jinfo_);
    }

    return ERROR_LG_EXCEPTION;
}

int lg_platform_t::verify91(const string& jinfo_)
{
    login91_info_t info;
    try
    {
        info << jinfo_;
    }
    catch(std::exception& ex)
    {
        logerror(("91LOGIN", "json decode jinfo failed! exception<:%s>", ex.what()));
        return ERROR_LG_EXCEPTION;
    }

    auto it = config.appinfo.appids.find(info.AppID);
    if (it == config.appinfo.appids.end())
    {
        logerror(("91LOGIN", "no appids!,appid:%s", info.AppID.c_str()));
        return ERROR_LG_EXCEPTION;
    }

    string sign;
    sign.append(info.AppID); 
    sign.append("4"); 
    sign.append(info.Uin); 
    sign.append(info.SessionID); 
    sign.append(config.appinfo.appids[info.AppID].appkey);
    sign = gen_sign_91(sign);

    http_curl_t hcurl;
    if (hcurl.start())
    {
        logerror(("91LOGIN", "init curl failed!" ));
        return ERROR_LG_EXCEPTION;
    }

    hcurl.add_packet("AppID", info.AppID);
    hcurl.add_packet("Act", "4");
    hcurl.add_packet("Uin", info.Uin);
    hcurl.add_packet("Sign", sign);
    hcurl.add_packet("SessionID", info.SessionID);
    if (hcurl.sync_get(config.appinfo.url, config.appinfo.timeout))
    {
        logerror(("91LOGIN", "url<%s> timeout:%d", 
                config.appinfo.url.c_str(), config.appinfo.timeout));
        return ERROR_LG_EXCEPTION;
    }

    string str_ret;
    hcurl.get_result(str_ret);
    hcurl.stop();

    verfiy91_ret_t ret;
    try
    {
        ret << str_ret;
    }
    catch(std::exception& ex)
    {
        logerror(("91LOGIN", "json decode verify ret<%s> failed! exception<:%s>", str_ret.c_str(), ex.what()));
        return ERROR_LG_EXCEPTION;
    }

    int code = std::atoi(ret.ErrorCode.c_str());
    if (code == 1)
        return SUCCESS;
    else 
    {
        logerror(("91LOGIN", "verify failed! desc:i%s",ret.ErrorDesc.c_str())); 
        return ERROR_LG_VERIFY;
    }
}
string lg_platform_t::gen_sign_91(const string& str_)
{
    lock_t lock(m_mutex);
    unsigned char* bytes = md5.MD5((unsigned char*)str_.c_str(), str_.size());
    return MD5Hex.encode(bytes, 16);
}
