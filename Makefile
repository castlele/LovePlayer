CC=clang
CFLAGS=-Wall -arch arm64
ARCHIVE_CFLAGS=$(CFLAGS) -shared -fPIC

LUA_JIT_PATH=/opt/homebrew/Cellar/luajit/2.1.1734355927
LUA_JIT_VERSION=2.1

BUILD=build
INCLUDE=-I./libs/
LUA_LIBS=-L$(LUA_JIT_PATH)/lib/ -lluajit -I$(LUA_JIT_PATH)/include/luajit-$(LUA_JIT_VERSION)/
SRC=src

MINIAUDIO_BINDINGS_NAME=luaminiaudio
MINIAUDIO_BINDINGS_SRC=$(SRC)/bindings/luaminiaudio.c
MINIAUDIO_BINDINGS=$(SRC)/$(MINIAUDIO_BINDINGS_NAME).so

build_$(MINIAUDIO_BINDINGS_NAME):
	clear
	$(CC) $(ARCHIVE_CFLAGS) $(INCLUDE) $(LUA_LIBS) $(MINIAUDIO_BINDINGS_SRC) -o $(MINIAUDIO_BINDINGS)

install:
	cd libs/nativefiledialog && sudo luarocks make lua/nfd-scm-1.rockspec

clean:
	rm -rf $(BUILD)/*
