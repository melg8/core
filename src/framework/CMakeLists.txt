# SPDX-FileCopyrightText: © 2004 WoWD Team
# SPDX-FileCopyrightText: © 2004 Team Python
# SPDX-FileCopyrightText: © 2005-2011 MaNGOS <http://getmangos.com/>
# SPDX-FileCopyrightText: © 2009-2011 MaNGOSZero <https://github.com/mangos/zero>
# SPDX-FileCopyrightText: © 2011-2016 Nostalrius <https://nostalrius.org>
# SPDX-FileCopyrightText: © 2016-2017 Elysium Project <https://github.com/elysium-project>
# SPDX-FileCopyrightText: © 2017-2025 Vanilla MaNGOS <https://github.com/vmangos/core>
# SPDX-FileCopyrightText: © 2025 Melg Eight <public.melg8@gmail.com>
#
# SPDX-License-Identifier: GPL-2.0-or-later

set(framework_SRCS 
  Dynamic/FactoryHolder.h
  Dynamic/ObjectRegistry.h
  GameSystem/Grid.h
  GameSystem/GridLoader.h
  GameSystem/GridReference.h
  GameSystem/GridRefManager.h
  GameSystem/NGrid.h
  GameSystem/TypeContainer.h
  GameSystem/TypeContainerVisitor.h
  Network/MangosSocket.h
  Network/MangosSocketImpl.h
  Network/MangosSocketMgr.h
  Network/MangosSocketMgrImpl.h
  Platform/CompilerDefs.h
  Platform/Define.h
  Policies/CreationPolicy.h
  Policies/ObjectLifeTime.h
  Policies/Singleton.h
  Policies/SingletonImp.h
  Policies/ThreadingModel.h
  Utilities/ByteConverter.h
  Utilities/EventProcessor.h
  Utilities/EventMap.h
  Utilities/LinkedList.h
  Utilities/TypeList.h
  Utilities/LinkedReference/Reference.h
  Utilities/LinkedReference/RefManager.h
  Dynamic/FactoryHolder.cpp
  Dynamic/ObjectRegistry.cpp
  GameSystem/Grid.cpp
  GameSystem/GridLoader.cpp
  GameSystem/GridReference.cpp
  GameSystem/GridRefManager.cpp
  GameSystem/NGrid.cpp
  GameSystem/TypeContainer.cpp
  GameSystem/TypeContainerVisitor.cpp
  Platform/Define.cpp
  Platform/CompilerDefs.cpp
  Network/MangosSocketMgr.cpp
  Network/MangosSocketMgrImpl.cpp
  Network/MangosSocket.cpp
  Network/MangosSocketImpl.cpp
  Policies/CreationPolicy.cpp
  Policies/MemoryManagement.cpp
  Policies/Singleton.cpp
  Policies/SingletonImp.cpp
  Policies/ThreadingModel.cpp
  Policies/ObjectLifeTime.cpp
  Utilities/ByteConverter.cpp
  Utilities/LinkedList.cpp
  Utilities/TypeList.cpp
  Utilities/LinkedReference/Reference.cpp
  Utilities/LinkedReference/RefManager.cpp
  Utilities/EventProcessor.cpp
  Utilities/EventMap.cpp
)


source_group("Other"
  REGULAR_EXPRESSION .*
)

source_group("Network"
  REGULAR_EXPRESSION Network
)

source_group("GameSystem"
  REGULAR_EXPRESSION GameSystem
)

source_group("Platform"
  REGULAR_EXPRESSION Platform
)

source_group("Policies"
  REGULAR_EXPRESSION Policies
)

source_group("Utilities"
  REGULAR_EXPRESSION Utilities
)

source_group("LinkedReference"
  REGULAR_EXPRESSION LinkedReference
)

source_group("Dynamic"
  REGULAR_EXPRESSION Dynamic
)

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_SOURCE_DIR}/src/shared
)

include_directories(
    SYSTEM
    ${TBB_INCLUDE_DIRS}
    ${ACE_INCLUDE_DIR}
)

add_library(framework STATIC
  ${framework_SRCS}
)

SET_TARGET_PROPERTIES (framework PROPERTIES FOLDER "Game Libs")

target_link_libraries(framework
  ${TBB_LIBRARIES}
  shared
)
