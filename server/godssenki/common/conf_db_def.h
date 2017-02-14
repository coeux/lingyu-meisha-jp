#ifndef _db_def_h_
#define _db_def_h_
#include <stdint.h>
#include <sstream>
using namespace std;
#include "sql_result.h"
#include "db_helper.h"
#include "db_service.h"
#include "ystring.h"
struct db_Host_t {
    int32_t compo;
    int32_t mid;
    ystring_t<32> sername;
    int32_t id;
    int32_t recom;
    int32_t did;
    int32_t hostid;
    int32_t sertype;
    static const char* tablename(){ return "Host"; }
    int init(sql_result_row_t& row_);
    static int select(db_service_t& db_, int32_t did_, int32_t sertype_, int32_t hostid_,  sql_result_t &res_);
    static int select_hosts(db_service_t& db_, int32_t did_,  int32_t sertype_, sql_result_t &res_);
};
struct db_Machine_t {
    int32_t id;
    int32_t type;
    ystring_t<32> pubip;
    ystring_t<32> priip;
    static const char* tablename(){ return "Machine"; }
    int init(sql_result_row_t& row_);
    static int select(db_service_t& db_, int32_t id_, sql_result_t &res_);
};
struct db_Domain_t {
    int32_t id;
    ystring_t<32> name;
    int32_t rid;
    int32_t invid;
    int32_t invdbid;
    int32_t invdbport;
    ystring_t<32> invdbname;
    int32_t dbid;
    int32_t dbport;
    ystring_t<32> dbname;

    static const char* tablename(){ return "Domain"; }
    int init(sql_result_row_t& row_);
    static int select(db_service_t& db_, int32_t id_, sql_result_t &res_);
    static int select(db_service_t& db_, const string& domain_, sql_result_t &res_);
};

#endif
