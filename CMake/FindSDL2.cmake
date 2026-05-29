# Shim to redirect SDL2 find_package to vendored source build
set(SDL2_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/ThirdParty/SDL/include")
set(SDL2_LIBRARIES SDL2::SDL2-static)
set(SDL2_FOUND TRUE)
