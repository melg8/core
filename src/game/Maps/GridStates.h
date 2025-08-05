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

#ifndef MANGOS_GRIDSTATES_H
#define MANGOS_GRIDSTATES_H

#include "Map.h"

struct InvalidState
{
    static void Update(Map&, NGridType&, GridInfo&,
                       uint32 const& x, uint32 const& y,
                       uint32 const& t_diff);
};

struct ActiveState
{
    static void Update(Map&, NGridType&, GridInfo&,
                       uint32 const& x, uint32 const& y,
                       uint32 const& t_diff);
};

struct IdleState
{
    static void Update(Map&, NGridType&, GridInfo&,
                       uint32 const& x, uint32 const& y,
                       uint32 const& t_diff);
};

struct RemovalState
{
    static void Update(Map&, NGridType&, GridInfo&,
                       uint32 const& x, uint32 const& y,
                       uint32 const& t_diff);
};

#endif  // MANGOS_GRIDSTATES_H
