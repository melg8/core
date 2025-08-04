// SPDX-FileCopyrightText: © 2004 WoWD Team
// SPDX-FileCopyrightText: © 2004 Team Python
// SPDX-FileCopyrightText: © 2005-2011 MaNGOS <http://getmangos.com/>
// SPDX-FileCopyrightText: © 2009-2011 MaNGOSZero <https://github.com/mangos/zero>
// SPDX-FileCopyrightText: © 2011-2016 Nostalrius <https://nostalrius.org>
// SPDX-FileCopyrightText: © 2016-2017 Elysium Project <https://github.com/elysium-project>
// SPDX-FileCopyrightText: © 2017-2025 Vanilla MaNGOS <https://github.com/vmangos/core>
// SPDX-FileCopyrightText: © 2025 Melg Eight <public.melg8@gmail.com>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#ifndef PLAYER_GM_SUBSYSTEM_H
#define PLAYER_GM_SUBSYSTEM_H

#include "Platform/Define.h"

#include "PlayerCheatOptions.h"

struct PlayerGmSubsystem
{
    [[nodiscard]] inline uint16 GetCheatOptions() const noexcept
    {
        return m_cheatOptions;
    }

    [[nodiscard]] inline bool HasCheatOption(PlayerCheatOptions o) const noexcept
    {
        return m_cheatOptions & o;
    }

    [[nodiscard]] inline uint32 GetGMTicketCounter() const noexcept
    {
        return m_currentTicketCounter;
    }

    [[nodiscard]] inline uint32 GetGMInvisibilityLevel() const noexcept
    {
        return m_gmInvisibilityLevel;
    }

    inline void EnableCheatOption(PlayerCheatOptions o) noexcept
    {
        m_cheatOptions |= o;
    }

    inline void RemoveCheatOption(PlayerCheatOptions o) noexcept
    {
        m_cheatOptions &= (~o);
    }

    inline void SetCheatOption(PlayerCheatOptions o, bool on) noexcept
    {
        if (on)
            EnableCheatOption(o);
        else
            RemoveCheatOption(o);
    }

    inline void SetGMTicketCounter(uint32 counter) noexcept
    {
        m_currentTicketCounter = counter;
    }

    inline void SetGMInvisibilityLevel(uint32 level) noexcept
    {
        m_gmInvisibilityLevel = level;
    }

private:
    uint32 m_gmInvisibilityLevel = 0;
    uint32 m_currentTicketCounter = 0;
    uint16 m_cheatOptions = 0;
};

#endif // PLAYER_GM_SUBSYSTEM_H
