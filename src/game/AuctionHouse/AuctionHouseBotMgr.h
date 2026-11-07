#pragma once

#include "AuctionHouseMgr.h"

#include "Policies/Singleton.h"

#include <vector>
#include <memory>

class Player;

struct AuctionHouseBotEntry
{
    uint32 item;
    uint32 stack;
    uint32 bid;
    uint32 buyout;
};

struct AuctionHouseBotConfig
{
    uint32 itemcount;
    uint32 ahfid;

    bool enable;
};

class AuctionHouseBotMgr
{
    public :
        AuctionHouseBotMgr() = default;
        ~AuctionHouseBotMgr();

        void Load();

        // force - put items in AH even if bot is disabled
        void Update(bool force = false);
        void AddItem(AuctionHouseBotEntry e, AuctionHouseObject *auctionHouse);

    protected:
        std::vector<AuctionHouseBotEntry> m_items;
        std::unique_ptr<AuctionHouseBotConfig> m_config;
        AuctionHouseEntry const* m_auctionHouseEntry = nullptr;

        bool m_loaded = false;
};

using AuctionHouseBotMgrSingleton = MaNGOS::Singleton<AuctionHouseBotMgr>;

#define sAuctionHouseBotMgr AuctionHouseBotMgrSingleton::Instance()
