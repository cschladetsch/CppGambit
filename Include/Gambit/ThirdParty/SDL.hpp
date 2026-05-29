#pragma once

#include "SDL.h"
#include "SDL_image.h"

#define CALL_SDL(X) \
    do { \
        _result = (X); \
        if (_result != 0 ) \
        { \
            LOG_ERROR() << #X << LOG_VALUE(SDL_GetError()) << "\n"; \
        } \
    } while (0)

