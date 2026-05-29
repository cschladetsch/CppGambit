# CppGambit Cleanup Plan

## Priority 1 -- Correctness

### `Rect.hpp` -- `ToSdlRect` reinterpret_cast
The `ToSdlRect` helper assumes identical memory layout between `Gambit::Rect` and `SDL_Rect`.
This is undefined behaviour. Replace with an explicit conversion function matching
what Codex already did in `Renderer.cpp`:
```cpp
inline SDL_FRect ToSdlFRect(Rect const& r)
{
    return { static_cast<float>(r.left), static_cast<float>(r.top),
             static_cast<float>(r.width), static_cast<float>(r.height) };
}
```
Remove `ToSdlRect` entirely. Update all call sites to use `ToSdlFRect`.

### `Vector2.hpp` -- float epsilon on int members
`x` and `y` are `int` but `operator==` uses `SDL_fabs` with a float epsilon.
Integer equality should use `==` directly, or `x`/`y` should be promoted to `float`.
Decide which and be consistent -- `Rect` uses `int`, `SDL_FRect` uses `float`.

---

## Priority 2 -- ChessClock Leakage

### `Context.hpp` -- hardcoded window title
`CreateRenderer()` passes `"Chess Clock"` as the window title.
Make it a constructor parameter:
```cpp
Context(const char* title, const char* resourceFolder, ContextFunction setup, ContextFunction processEvents)
```

### `Logger.cpp` -- hardcoded log filename prefix ✓ DONE
`SetAppName()` added. Logger.hpp updated.

---

## Priority 3 -- Dependencies

### `ResourceManager.hpp` -- Boost.Filesystem
Replace `#include <boost/filesystem.hpp>` and `boost::filesystem::path` with
`#include <filesystem>` and `std::filesystem::path`.
No functional change required -- the API is identical for the usage here.

### `Vector2.hpp` -- SDL include path
`#include "SDL_stdinc.h"` should be `#include <SDL2/SDL_stdinc.h>`.
Also replace `SDL_fabs`/`SDL_sqrtf` with `std::abs`/`std::sqrt` from `<cmath>` --
no reason to use SDL math wrappers in a C++ struct.

---

## Priority 4 -- Design

### `Renderer.hpp` -- Width/Height as instance members
```cpp
const int Width = 800;
const int Height = 480;
```
Should be `static constexpr`:
```cpp
static constexpr int Width = 800;
static constexpr int Height = 480;
```

### `Atlas.cpp` -- tint_list parsing ✓ DONE
Tint names are now data-driven from JSON, not hardcoded.

### `StringUtil.cpp` -- deprecated `std::codecvt` ✓ DONE
Replaced with `wcstombs`.

---

## Priority 5 -- Dead Code

| File | Action |
|------|--------|
| `Gravatar.hpp` / `Gravatar.cpp` | Delete |
| `Http.cpp` | Delete |
| `Template.hpp` | Delete |
| `AudioAtlas.cpp` / `AudioClip.cpp` | Keep headers, stub implementations acceptable for now |

---

## Priority 6 -- Minor

### `Exceptions.hpp` -- missing `#pragma once`
Add it.

### `Logger.hpp` -- `shared_ptr<std::fstream>`
Static singleton log file has no multiple-owner semantics.
Replace `static shared_ptr<std::fstream>` with `static std::fstream`.

### `NonCopyable` -- missing move semantics
`operator=(NonCopyable&&)` is not deleted. Add it for completeness.

---

## Not Changing

- `Config.hpp` namespace aliases (`Gambit::string` etc) -- pervasive, not worth the churn
- `ResourceId` GUID hash -- correct as-is
- `TeeStream.hpp` -- solid implementation, no issues
- Audio stubs -- deferred until hardware is in hand

---

## Order of Work

1. Boost -> std::filesystem (`ResourceManager.hpp` + `.cpp`)
2. `ToSdlRect` -> `ToSdlFRect` (`Rect.hpp` + all call sites)
3. `Vector2` int/float consistency decision
4. `Context.hpp` title parameter
5. `Renderer.hpp` constexpr dimensions
6. Dead code deletion
7. Minor fixes

---

## Raspberry Pi 3 Target

### Hardware Facts
- ARMv8-A CPU (4x Cortex-A53 @ 1.2GHz), 1GB RAM
- VideoCore IV GPU -- no Vulkan, limited OpenGL ES 2.0
- 7" DSI display at 800x480 (matches `Renderer::Width`/`Height`)
- Raspberry Pi OS (32-bit recommended for compatibility)

### SDL2 Build Flags for Pi
The SDL2 vendored build needs these CMake options set for Pi targets:

```cmake
set(VIDEO_RPI ON CACHE BOOL "" FORCE)      # VideoCore IV direct display
set(VIDEO_OPENGL OFF CACHE BOOL "" FORCE)  # No desktop GL on Pi 3
set(VIDEO_VULKAN OFF CACHE BOOL "" FORCE)  # No Vulkan on Pi 3
set(VIDEO_X11 OFF CACHE BOOL "" FORCE)     # Skip if running framebuffer direct
set(ALSA ON CACHE BOOL "" FORCE)           # Audio via ALSA on Pi
```

Wrap in a CMake platform guard:
```cmake
if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm|aarch64")
    # Pi-specific SDL2 options here
endif()
```

### Renderer
`SDL_RENDERER_ACCELERATED` silently falls back to software if VideoCore IV
driver is not active. Add a fallback check in `Renderer::Construct()`:

```cpp
_renderer = SDL_CreateRenderer(_window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
if (!_renderer)
{
    LOG_WARN() << "Accelerated renderer unavailable, falling back to software\n";
    _renderer = SDL_CreateRenderer(_window, -1, SDL_RENDERER_SOFTWARE);
}
```

### Compiler Flags
For native Pi builds add to CMakeLists.txt:
```cmake
if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm|aarch64")
    target_compile_options(Gambit PRIVATE -march=native -mfpu=neon-fp-armv8 -mfloat-abi=hard)
endif()
```

### Build Strategy
- **Development**: build on WSL2/Linux x86_64, validate logic and tests
- **Pi validation**: native build on device -- slow but avoids cross-compile toolchain pain
- **Cross-compilation**: optional later -- requires `arm-linux-gnueabihf` sysroot

### Memory Budget (Pi 3, 1GB)
Static link of SDL2 + SDL_ttf + SDL_image + freetype produces a large binary.
Estimate ~40-60MB RSS at runtime. Acceptable for 1GB but worth profiling on device.

### Display Setup
With the official 7" DSI display, ensure `/boot/config.txt` has:
```
dtoverlay=vc4-kms-v3d
```
for KMSDRM backend, or use the legacy framebuffer driver with `SDL_VIDEODRIVER=fbdev`.
