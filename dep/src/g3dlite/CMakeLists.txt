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

# file(GLOB g3dlite_SRCS *.cpp) # don't need all of them

set(g3dlite_SRCS
  AABox.cpp
  Any.cpp
  AnyTableReader.cpp
  BinaryFormat.cpp
  BinaryInput.cpp
  BinaryOutput.cpp
  Box.cpp
  Capsule.cpp
  CollisionDetection.cpp
  CoordinateFrame.cpp
  Crypto.cpp
  Cylinder.cpp
  debugAssert.cpp
  FileSystem.cpp
  fileutils.cpp
  format.cpp
  g3dfnmatch.cpp
  g3dmath.cpp
  GThread.cpp
  Line.cpp
  LineSegment.cpp
  Log.cpp
  Matrix3.cpp
  Matrix4.cpp
  MemoryManager.cpp
  PhysicsFrame.cpp
  Plane.cpp
  prompt.cpp
  Quat.cpp
  Random.cpp
  Ray.cpp
  RegistryUtil.cpp
  Sphere.cpp
  stringutils.cpp
  System.cpp
  TextInput.cpp
  TextOutput.cpp
  Triangle.cpp
  uint128.cpp
  UprightFrame.cpp
  Vector2.cpp
  Vector3.cpp
  Vector4.cpp
)

include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_SOURCE_DIR}/dep/include
  ${CMAKE_SOURCE_DIR}/dep/include/g3dlite
  ${CMAKE_SOURCE_DIR}/dep/src/libseh
)

add_library(g3dlite STATIC
  ${g3dlite_SRCS}
)

if(MSVC)
  target_compile_options(g3dlite PRIVATE /wd4244 /wd4838)
endif()

SET_TARGET_PROPERTIES (g3dlite PROPERTIES FOLDER "3rd Party")

if(WIN32)
  include_directories(${CMAKE_SOURCE_DIR}/dep/windows/include/zlib)
  if(MINGW)
    target_link_libraries(g3dlite zlib libseh)
  else()
    target_link_libraries(g3dlite zlib)
  endif()
else()
  find_package(ZLIB REQUIRED)
  if(ZLIB_FOUND)
    include_directories(${ZLIB_INCLUDE_DIRS})
    target_link_libraries(g3dlite ${ZLIB_LIBRARIES})
  endif(ZLIB_FOUND)
endif(WIN32)
