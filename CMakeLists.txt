cmake_minimum_required(VERSION 3.12)

set(PROJECT_NAME Gambit)
project(${PROJECT_NAME})

include(GNUInstallDirs)

set(PROJECT_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/Include)
set(RUNTIME_OUTPUT_DIR "${PROJECT_SOURCE_DIR}/Bin")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${RUNTIME_OUTPUT_DIR}")
foreach(output_config DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${output_config} "${RUNTIME_OUTPUT_DIR}")
endforeach()

set(BuildTests OFF CACHE BOOL "" FORCE)
set(SDL_SHARED OFF CACHE BOOL "" FORCE)
set(SDL_STATIC ON CACHE BOOL "" FORCE)
set(ALSA OFF CACHE BOOL "" FORCE)
set(OSS OFF CACHE BOOL "" FORCE)
set(PULSEAUDIO OFF CACHE BOOL "" FORCE)
set(SDL_DLOPEN OFF CACHE BOOL "" FORCE)
set(SDL_LOADSO OFF CACHE BOOL "" FORCE)
set(VIDEO_WAYLAND OFF CACHE BOOL "" FORCE)
set(VIDEO_X11 OFF CACHE BOOL "" FORCE)
set(ALSA_SHARED OFF CACHE BOOL "" FORCE)
set(PULSEAUDIO_SHARED OFF CACHE BOOL "" FORCE)
set(X11_SHARED OFF CACHE BOOL "" FORCE)
set(WAYLAND_SHARED OFF CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(SKIP_INSTALL_ALL ON CACHE BOOL "" FORCE)
option(BUILD_TESTS "Build tests in the Test directory" ON)

add_subdirectory(ThirdParty/crossguid)
add_subdirectory(ThirdParty/SDL)
if (TARGET SDL2-static AND CMAKE_C_COMPILER_ID STREQUAL "GNU")
    target_compile_options(SDL2-static PRIVATE -Wno-maybe-uninitialized)
endif()
add_subdirectory(ThirdParty/freetype2)
if (NOT TARGET Freetype::Freetype)
    add_library(Freetype::Freetype ALIAS freetype-interface)
endif()
# SDL_ttf exports its link interface, so the real Freetype targets behind the
# alias must be present in the same export set.
install(
    TARGETS freetype freetype-interface
    EXPORT SDL2_ttfTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
set(SDL2_DIR "${CMAKE_BINARY_DIR}/ThirdParty/SDL" CACHE PATH "" FORCE)
add_subdirectory(ThirdParty/SDL_ttf)
target_compile_definitions(SDL2_ttf PRIVATE FT_PIXEL_MODE_GRAY16=FT_PIXEL_MODE_GRAY4)
target_include_directories(SDL2_ttf PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/ThirdParty/SDL_ttf>"
)
add_subdirectory(ThirdParty/SDL2_image-2.0.5)
add_subdirectory(${CMAKE_SOURCE_DIR}/ThirdParty/json)

file(GLOB ALL_SOURCES 
    "${PROJECT_SOURCE_DIR}/Source/*.cpp"
) 

file(GLOB_RECURSE ALL_HEADERS
	"${PROJECT_INCLUDE_DIR}/${PROJECT_NAME}/*.hpp"
	"${PROJECT_INCLUDE_DIR}/${PROJECT_NAME}/*.h"
)

add_library(${PROJECT_NAME}
    ${ALL_SOURCES}
    ${ALL_HEADERS}
)
target_include_directories(${PROJECT_NAME} PUBLIC
    ${PROJECT_INCLUDE_DIR}
)
set_target_properties(${PROJECT_NAME} PROPERTIES
    CXX_STANDARD 20
    CXX_EXTENSIONS OFF
)

if (BUILD_TESTS)
    enable_testing()
    add_subdirectory(Test)
endif()

target_link_libraries(${PROJECT_NAME} SDL2::SDL2-static SDL2_ttf SDL2_image nlohmann_json crossguid)
