#include <assert.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <memory.h>

#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

// TODO: Memory management in hell :)

static int playAudio(lua_State *L)
{
    int nargs = lua_gettop(L);
    const char *file = lua_tostring(L, 1 - nargs);
    lua_getfield(L, 0 - nargs, "engine");
    ma_engine *engine = (ma_engine *)lua_touserdata(L, lua_gettop(L));

    assert(engine);

    ma_result result = ma_engine_play_sound(engine, file, NULL);

    if (result != MA_SUCCESS) {
        printf("Error playing %i\n", result);
        return 0;
    }

    return 0;
}

static int waitAudio(lua_State *L)
{
    // printf("Press Enter to quit...");
    // getchar();
    return 0;
}

static int initMiniaudio(lua_State *L)
{
    ma_result result;
    ma_engine *engine = (ma_engine *)malloc(sizeof(ma_engine));
    ma_device *device = (ma_device *)malloc(sizeof(ma_device));

    result = ma_engine_init(NULL, engine);
    if (result != MA_SUCCESS) {
        printf("Error initing engine %i\n", result);
        return 0;
    }

    ma_device_config config = ma_device_config_init(ma_device_type_playback);

    result = ma_device_init(NULL, &config, device);
    if (result != MA_SUCCESS) {
        printf("Error initing device %i\n", result);
        return 0;
    }

    lua_createtable(L, 0, 4);

    lua_pushstring(L, "engine");
    lua_pushlightuserdata(L, engine);
    lua_settable(L, -3);

    lua_pushstring(L, "device");
    lua_pushlightuserdata(L, device);
    lua_settable(L, -3);

    lua_pushstring(L, "play");
    lua_pushcfunction(L, playAudio);
    lua_settable(L, -3);

    lua_pushstring(L, "wait");
    lua_pushcfunction(L, waitAudio);
    lua_settable(L, -3);

    return 1;
}

static const struct luaL_Reg luaminiaudio[] = {
    {"init", initMiniaudio},
    {NULL, NULL},
};

void registerFields(lua_State *L, const struct luaL_Reg *regList)
{
    int index = 0;
    luaL_Reg reg;

    while ((reg = regList[index]).name != NULL) {
        lua_pushstring(L, reg.name);
        lua_pushcfunction(L, reg.func);
        lua_settable(L, -3);
        index++;
    }
}

int luaopen_luaminiaudio(lua_State *L)
{
    lua_createtable(L, 0, 1);
    registerFields(L, luaminiaudio);

    return 1;
}
