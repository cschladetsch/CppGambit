# Gambit !(Hat)[./Resources/Hat.jpg]

*Gambit* is a general-purpose interactive application framework built on SDL2, targeting Linux and Raspberry Pi. Extracted from [ChessClock](https://github.com/cschladetsch/ChessClock).

Features a sprite atlas system, JSON-driven resource loading, scene graph, font rendering via SDL_ttf, and audio support. All third-party dependencies are vendored and built statically -- no system SDL required.

## Architecture

Gambit is organised into three layers: core types, a resource system, and an application context that drives the main loop.

```mermaid
graph TD
    subgraph Application
        CTX["Context\nMain loop, event processing"]
    end

    subgraph Framework
        RM["ResourceManager\nLoads and owns all resources"]
        REN["Renderer\nSDL2 window and render target"]
        SCN["Scene\nLayer-ordered object graph"]
        ATL["Atlas\nSprite sheet + tint map"]
    end

    subgraph Resources
        TEX["Texture"]
        FNT["Font / TimerFont"]
        OBJ["Object\nPosition, sprite, layer, state"]
    end

    subgraph Data
        JSON["JSON files\nScenes, atlases, resources"]
    end

    CTX --> RM
    CTX --> REN
    RM --> SCN
    RM --> ATL
    RM --> TEX
    RM --> FNT
    SCN --> OBJ
    ATL --> TEX
    JSON --> RM
```

## Render Loop

```mermaid
sequenceDiagram
    participant App as Application
    participant Ctx as Context
    participant Ren as Renderer
    participant Scn as Scene
    participant Atl as Atlas

    App->>Ctx: Run()
    loop Each frame
        Ctx->>Ctx: Poll SDL events
        Ctx->>Ctx: Execute event processors
        Ctx->>Ren: Clear()
        Ctx->>Scn: Render(renderer)
        loop Each layer
            alt Text object
                Scn->>Ren: WriteTexture(textTexture)
            else Sprite object
                Scn->>Atl: WriteSprite(renderer, object)
                Atl->>Ren: WriteTexture(atlas, src, dest)
            end
        end
        Ctx->>Ren: Present()
    end
```

## Requirements

- CMake 3.12+
- GCC 13+ or Clang
- C++17

## Building

```bash
./b --run-tests
```

Or manually:

```bash
cmake -S . -B build
cmake --build build -j$(nproc)
ctest --test-dir build --output-on-failure
```

## Raspberry Pi

```bash
sudo apt update
sudo apt install make cmake git git-lfs
sudo apt upgrade && sudo apt autoremove
```

No additional SDL packages needed -- everything builds from vendored source in `ThirdParty/`.

## Structure

| Directory | Purpose |
|-----------|---------|
| `Include/` | Public headers |
| `Source/` | Implementation |
| `Test/` | Catch-based unit tests |
| `ThirdParty/` | Vendored dependencies (SDL2, SDL_ttf, SDL_image, freetype, nlohmann/json, crossguid) |
| `CMake/` | CMake modules and shims |
