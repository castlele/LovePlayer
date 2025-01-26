#include <assert.h>
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
#include <memory.h>

#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

// TODO: Memory management in hell :)

#pragma mark - Private methods

void setTableUserDataProperty(lua_State *L, const char *key, void *value)
{
    lua_pushstring(L, key);
    lua_pushlightuserdata(L, value);
    lua_settable(L, -3);
}

void *getTableUserDataProperty(lua_State *L, const char *key) {
    int nargs = lua_gettop(L);
    lua_getfield(L, 0 - nargs, key);

    return lua_touserdata(L, lua_gettop(L));
}

void setTableFunctionProperty(lua_State *L, const char *key, void *value)
{
    lua_pushstring(L, key);
    lua_pushcfunction(L, value);
    lua_settable(L, -3);
}

#pragma mark - Public methods

static const char *MINI_ENGINE_KEY = "engine";
static const char *MINI_DECODER_KEY = "decoder";
static const char *MINI_DEVICE_CONFIG_KEY = "deviceconfig";
static const char *MINI_DEVICE_KEY = "device";
static const char *MINI_PLAY_KEY = "play";
static const char *MINI_PAUSE_KEY = "pause";
static const char *MINI_WAIT_KEY = "wait";

static int playAudio(lua_State *L)
{
    int nargs = lua_gettop(L);
    const char *file = lua_tostring(L, 1 - nargs);
    ma_engine *engine = getTableUserDataProperty(L, MINI_ENGINE_KEY);
    ma_decoder *decoder = getTableUserDataProperty(L, MINI_DECODER_KEY);

    assert(engine);
    assert(decoder);

    ma_result result;

    if (decoder == NULL) {

        if (result != MA_SUCCESS) {
            printf("Failed to initialized sound with result: %i\n", result);
            return 0;
        }
    }

    return 0;
}

static int pauseAudio(lua_State *L)
{
    ma_sound *sound = getTableUserDataProperty(L, MINI_DECODER_KEY);
    ma_sound_stop(sound);
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
    ma_decoder *decoder = (ma_decoder *)malloc(sizeof(ma_decoder));
    ma_device_config *deviceConfig = (ma_device_config *)malloc(sizeof(ma_device_config));
    ma_device *device = (ma_device *)malloc(sizeof(ma_device));

    result = ma_engine_init(NULL, engine);

    if (result != MA_SUCCESS) {
        printf("Error initing engine %i\n", result);
        return 0;
    }

    *deviceConfig = ma_device_config_init(ma_device_type_playback);

    result = ma_device_init(NULL, deviceConfig, device);

    if (result != MA_SUCCESS) {
        printf("Error initing device %i\n", result);
        return 0;
    }

    result = ma_device_start(device);

    if (result != MA_SUCCESS) {
        printf("Failed to start device %i\n", result);
        return 0;
    }

    lua_createtable(L, 0, 4);

    setTableUserDataProperty(L, MINI_ENGINE_KEY, engine);
    setTableUserDataProperty(L, MINI_DECODER_KEY, decoder);
    setTableUserDataProperty(L, MINI_DEVICE_CONFIG_KEY, deviceConfig);
    setTableUserDataProperty(L, MINI_DEVICE_KEY, device);
    setTableFunctionProperty(L, MINI_PLAY_KEY, playAudio);
    setTableFunctionProperty(L, MINI_PAUSE_KEY, pauseAudio);
    setTableFunctionProperty(L, MINI_WAIT_KEY, waitAudio);

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
        setTableFunctionProperty(L, reg.name, reg.func);
        index++;
    }
}

int luaopen_libs_luaminiaudio(lua_State *L)
{
    lua_createtable(L, 0, 1);
    registerFields(L, luaminiaudio);

    return 1;
}
