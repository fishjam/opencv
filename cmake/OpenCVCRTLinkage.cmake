# Use statically or dynamically linked CRT?

if(NOT MSVC)
  message(FATAL_ERROR "CRT options are available only for MSVC")
endif()

if (WINRT)
  if (CMAKE_SYSTEM_VERSION MATCHES 10)
    add_definitions(/DWINVER=_WIN32_WINNT_WIN10 /DNTDDI_VERSION=NTDDI_WIN10 /D_WIN32_WINNT=_WIN32_WINNT_WIN10)
  elseif(CMAKE_SYSTEM_VERSION MATCHES 8.1)
    add_definitions(/DWINVER=_WIN32_WINNT_WINBLUE /DNTDDI_VERSION=NTDDI_WINBLUE /D_WIN32_WINNT=_WIN32_WINNT_WINBLUE)
  else()
    add_definitions(/DWINVER=_WIN32_WINNT_WIN8 /DNTDDI_VERSION=NTDDI_WIN8 /D_WIN32_WINNT=_WIN32_WINNT_WIN8)
  endif()
endif()

# Removing LNK4075 warnings for debug WinRT builds
# "LNK4075: ignoring '/INCREMENTAL' due to '/OPT:ICF' specification"
# "LNK4075: ignoring '/INCREMENTAL' due to '/OPT:REF' specification"
if(MSVC AND WINRT)
  # Optional verification checks since we don't know existing contents of variables below
  string(REPLACE "/OPT:ICF " "/OPT:NOICF " CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")
  string(REPLACE "/OPT:REF " "/OPT:NOREF " CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")
  string(REPLACE "/INCREMENTAL:YES " "/INCREMENTAL:NO " CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")
  string(REPLACE "/INCREMENTAL " "/INCREMENTAL:NO " CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")

  string(REPLACE "/OPT:ICF " "/OPT:NOICF " CMAKE_MODULE_LINKER_FLAGS_DEBUG "${CMAKE_MODULE_LINKER_FLAGS_DEBUG}")
  string(REPLACE "/OPT:REF " "/OPT:NOREF" CMAKE_MODULE_LINKER_FLAGS_DEBUG "${CMAKE_MODULE_LINKER_FLAGS_DEBUG}")
  string(REPLACE "/INCREMENTAL:YES " "/INCREMENTAL:NO " CMAKE_MODULE_LINKER_FLAGS_DEBUG "${CMAKE_MODULE_LINKER_FLAGS_DEBUG}")
  string(REPLACE "/INCREMENTAL " "/INCREMENTAL:NO " CMAKE_MODULE_LINKER_FLAGS_DEBUG "${CMAKE_MODULE_LINKER_FLAGS_DEBUG}")

  string(REPLACE "/OPT:ICF " "/OPT:NOICF " CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}")
  string(REPLACE "/OPT:REF " "/OPT:NOREF " CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}")
  string(REPLACE "/INCREMENTAL:YES " "/INCREMENTAL:NO " CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}")
  string(REPLACE "/INCREMENTAL " "/INCREMENTAL:NO " CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}")

  # Mandatory
  set(CMAKE_MODULE_LINKER_FLAGS_DEBUG  "${CMAKE_MODULE_LINKER_FLAGS_DEBUG} /INCREMENTAL:NO /OPT:NOREF /OPT:NOICF")
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG     "${CMAKE_EXE_LINKER_FLAGS_DEBUG} /INCREMENTAL:NO /OPT:NOREF /OPT:NOICF")
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUG  "${CMAKE_SHARED_LINKER_FLAGS_DEBUG} /INCREMENTAL:NO /OPT:NOREF /OPT:NOICF")
endif()

# Ignore warning: This object file does not define any previously undefined public symbols, ...
set(CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} /IGNORE:4221")

if(BUILD_WITH_STATIC_CRT)
  foreach(flag_var
          CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
          CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
          CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
          CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    if(${flag_var} MATCHES "/MD")
      string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
    endif()
    if(${flag_var} MATCHES "/MDd")
      string(REGEX REPLACE "/MDd" "/MTd" ${flag_var} "${${flag_var}}")
    endif()
  endforeach(flag_var)
else()
  foreach(flag_var
          CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
          CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
          CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
          CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    if(${flag_var} MATCHES "/MT")
      string(REGEX REPLACE "/MT" "/MD" ${flag_var} "${${flag_var}}")
    endif()
    if(${flag_var} MATCHES "/MTd")
      string(REGEX REPLACE "/MTd" "/MDd" ${flag_var} "${${flag_var}}")
    endif()
  endforeach(flag_var)
endif()

if(NOT BUILD_SHARED_LIBS)
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /NODEFAULTLIB:atlthunk.lib")
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG} /NODEFAULTLIB:libcmt.lib /NODEFAULTLIB:libcpmt.lib /NODEFAULTLIB:msvcrt.lib")
  set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /NODEFAULTLIB:libcmtd.lib /NODEFAULTLIB:libcpmtd.lib /NODEFAULTLIB:msvcrtd.lib")
endif()

if(CMAKE_VERSION VERSION_GREATER "2.8.6")
  include(ProcessorCount)
  ProcessorCount(N)
  if(NOT N EQUAL 0)
    SET(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   /MP${N} ")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP${N} ")
  endif()
endif()
