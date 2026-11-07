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

#include "GridStates.h"

#include "Log.h"
#include "ObjectGridLoader.h"

void InvalidState::Update(Map&, NGridType&, GridInfo&,
                          uint32 const& /*x*/, uint32 const& /*y*/,
                          uint32 const&)
{
}

void ActiveState::Update(Map& m, NGridType& grid, GridInfo& info,
                         uint32 const& x, uint32 const& y,
                         uint32 const& t_diff)
{
    // Only check grid activity every (grid_expiry/10) ms, because it's really useless to do it every cycle
    info.UpdateTimeTracker(t_diff);
    if (info.getTimeTracker().Passed())
    {
        if (grid.ActiveObjectsInGrid() == 0 && !m.ActiveObjectsNearGrid(x, y))
        {
            ObjectGridStoper stoper(grid);
            stoper.StopN();
            grid.SetGridState(GRID_STATE_IDLE);
        }
        else
            m.ResetGridExpiry(grid, 0.1f);
    }
}

void IdleState::Update(Map& m, NGridType& grid, GridInfo&,
                       uint32 const& x, uint32 const& y,
                       uint32 const&)
{
    m.ResetGridExpiry(grid);
    grid.SetGridState(GRID_STATE_REMOVAL);
    sLog.Out(LOG_BASIC, LOG_LVL_DEBUG, "Grid[%u,%u] on map %u moved to IDLE state", x, y, m.GetId());
}

void RemovalState::Update(Map& m, NGridType& grid, GridInfo& info,
                          uint32 const& x, uint32 const& y,
                          uint32 const& t_diff)
{
    if (!info.getUnloadLock())
    {
        info.UpdateTimeTracker(t_diff);
        if (info.getTimeTracker().Passed())
        {
            if (!m.UnloadGrid(x, y, false))
            {
                sLog.Out(LOG_BASIC, LOG_LVL_DEBUG, "Grid[%u,%u] for map %u differed unloading due to players or active objects nearby", x, y, m.GetId());
                m.ResetGridExpiry(grid);
            }
        }
    }
}
