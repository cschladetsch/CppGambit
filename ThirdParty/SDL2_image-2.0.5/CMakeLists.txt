cmake_minimum_required(VERSION 3.12)

project(SDL2_image C)

set(SDL2_IMAGE_ZLIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/zlib-1.2.11")
set(SDL2_IMAGE_LIBPNG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/libpng-1.6.37")

set(PNG_BUILD_ZLIB ON CACHE BOOL "" FORCE)
set(PNG_SHARED OFF CACHE BOOL "" FORCE)
set(PNG_STATIC ON CACHE BOOL "" FORCE)
set(PNG_TESTS OFF CACHE BOOL "" FORCE)
set(PNG_FRAMEWORK OFF CACHE BOOL "" FORCE)
set(PNG_HARDWARE_OPTIMIZATIONS OFF CACHE BOOL "" FORCE)
set(SKIP_INSTALL_ALL ON CACHE BOOL "" FORCE)

set(ZLIB_INCLUDE_DIR "${SDL2_IMAGE_ZLIB_DIR}")
set(ZLIB_LIBRARY zlibstatic)

add_subdirectory("${SDL2_IMAGE_ZLIB_DIR}" EXCLUDE_FROM_ALL)
add_subdirectory("${SDL2_IMAGE_LIBPNG_DIR}" EXCLUDE_FROM_ALL)

add_library(SDL2_image STATIC
    IMG.c
    IMG_bmp.c
    IMG_gif.c
    IMG_jpg.c
    IMG_lbm.c
    IMG_pcx.c
    IMG_png.c
    IMG_pnm.c
    IMG_svg.c
    IMG_tga.c
    IMG_tif.c
    IMG_webp.c
    IMG_xcf.c
    IMG_xpm.c
    IMG_xv.c
    IMG_xxx.c
)

target_compile_definitions(SDL2_image PRIVATE
    LOAD_PNG
    SDL_IMAGE_USE_COMMON_BACKEND
)

target_include_directories(SDL2_image PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
)

target_include_directories(SDL2_image PRIVATE
    "${SDL2_IMAGE_ZLIB_DIR}"
    "${SDL2_IMAGE_LIBPNG_DIR}"
    "${CMAKE_CURRENT_BINARY_DIR}/external/libpng-1.6.37"
)

target_link_libraries(SDL2_image PUBLIC
    SDL2::SDL2-static
)

target_link_libraries(SDL2_image PRIVATE
    png_static
    zlibstatic
)
