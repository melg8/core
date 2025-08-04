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
set(EXECUTABLE_NAME realmd)
set(EXECUTABLE_SRCS
  AuthCodes.h
  AuthSocket.h
  BufferedSocket.h
  PatchHandler.h
  RealmList.h
  AuthSocket.cpp
  BufferedSocket.cpp
  Main.cpp
  PatchHandler.cpp
  RealmList.cpp
)

include_directories(
    SYSTEM
    ${ACE_INCLUDE_DIR}
)

if(WIN32)
  list(APPEND EXECUTABLE_SRCS
    realmd.rc
  )

  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /D__ACE_INLINE__")
endif()

add_executable(${EXECUTABLE_NAME}
  ${EXECUTABLE_SRCS}
)

target_link_libraries(${EXECUTABLE_NAME}
  shared
  framework
  ${ACE_LIBRARIES}
)

if(WIN32)
  target_link_libraries(${EXECUTABLE_NAME}
    optimized ${MYSQL_LIBRARY}
    optimized ${OPENSSL_LIBRARIES}
    debug ${MYSQL_DEBUG_LIBRARY}
    debug ${OPENSSL_DEBUG_LIBRARIES}
  )
  if(MINGW)
    target_link_libraries(${EXECUTABLE_NAME}
      -lws2_32
    )
  endif()
  if(PLATFORM MATCHES X86)
    target_link_libraries(${EXECUTABLE_NAME})
  endif()
endif()

if(UNIX)
  target_link_libraries(${EXECUTABLE_NAME}
    ${MYSQL_LIBRARY}
    ${OPENSSL_LIBRARIES}
    ${OPENSSL_EXTRA_LIBRARIES}
  )
endif()

set(EXECUTABLE_LINK_FLAGS "")

if(UNIX)
  set(EXECUTABLE_LINK_FLAGS "-pthread ${EXECUTABLE_LINK_FLAGS}")
endif()

if(APPLE)
  set(EXECUTABLE_LINK_FLAGS "-framework Carbon ${EXECUTABLE_LINK_FLAGS}")
endif()

set_target_properties(${EXECUTABLE_NAME} PROPERTIES LINK_FLAGS
  "${EXECUTABLE_LINK_FLAGS}"
)

install(TARGETS ${EXECUTABLE_NAME} DESTINATION ${BIN_DIR})
install(FILES realmd.conf.dist.in DESTINATION ${CONF_DIR} RENAME realmd.conf.dist)

if(WIN32 AND MSVC)
  install(FILES $<TARGET_PDB_FILE:${EXECUTABLE_NAME}> DESTINATION ${BIN_DIR} OPTIONAL)
endif()
