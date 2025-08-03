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

#ifndef PLAYERCHEATOPTIONS_H
#define PLAYERCHEATOPTIONS_H

#include "Platform/Define.h"

enum PlayerCheatOptions : uint16
{
    PLAYER_CHEAT_FLY = 0x001,
    PLAYER_CHEAT_NO_COOLDOWN = 0x002,
    PLAYER_CHEAT_NO_CAST_TIME = 0x004,
    PLAYER_CHEAT_NO_POWER = 0x008,
    PLAYER_CHEAT_DEBUFF_IMMUNITY = 0x010,
    PLAYER_CHEAT_ALWAYS_CRIT = 0x020,
    PLAYER_CHEAT_NO_CHECK_CAST = 0x040,
    PLAYER_CHEAT_ALWAYS_PROC = 0x080,
    PLAYER_CHEAT_TRIGGER_PASS = 0x100,
    PLAYER_CHEAT_IGNORE_TRIGGERS = 0x200,
    PLAYER_CHEAT_DEBUG_TARGET_INFO = 0x400,
    PLAYER_CHEAT_FIXED_Z = 0x800,
};


#endif // PLAYERCHEATOPTIONS_H
