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
