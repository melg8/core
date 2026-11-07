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

set(ZLIB_PUBLIC_HDRS
    ${CMAKE_SOURCE_DIR}/dep/windows/include/zlib/zconf.h
    ${CMAKE_SOURCE_DIR}/dep/windows/include/zlib/zlib.h
)
set(ZLIB_PRIVATE_HDRS
    crc32.h
    deflate.h
    gzguts.h
    inffast.h
    inffixed.h
    inflate.h
    inftrees.h
    trees.h
    zutil.h
)
set(ZLIB_SRCS
    adler32.c
    compress.c
    crc32.c
    deflate.c
    gzclose.c
    gzlib.c
    gzread.c
    gzwrite.c
    inflate.c
    infback.c
    inftrees.c
    inffast.c
    trees.c
    uncompr.c
    zutil.c
)

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_SOURCE_DIR}/dep/windows/include/zlib
)

add_library(zlib STATIC
  ${ZLIB_SRCS} ${ZLIB_PUBLIC_HDRS} ${ZLIB_PRIVATE_HDRS}
)

if(MSVC)
    target_compile_definitions(zlib PRIVATE
      _CRT_SECURE_NO_WARNINGS
      _CRT_NONSTDC_NO_DEPRECATE
    )
    target_compile_options(zlib PRIVATE /wd4028 /wd4131)
endif()

SET_TARGET_PROPERTIES (zlib PROPERTIES FOLDER "3rd Party")
