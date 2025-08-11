#ifndef _AUTOBROADCAST_MGR_H
#define _AUTOBROADCAST_MGR_H

#include "Policies/Singleton.h"
#include "Platform/Define.h"

#include <vector>

struct AutoBroadCastEntry
{
    int32 stringId;
};

class AutoBroadCastMgr
{
    public :
        AutoBroadCastMgr();
        ~AutoBroadCastMgr();

        void Load();
        void Update(uint32 diff);

    protected:
        std::vector<AutoBroadCastEntry> entries;
        time_t _constInterval;
        time_t _current;
};

using AutoBroadCastMgrSingleton = MaNGOS::Singleton<AutoBroadCastMgr>;

#define sAutoBroadCastMgr AutoBroadCastMgrSingleton::Instance()

#endif
