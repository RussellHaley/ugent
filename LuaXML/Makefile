# 2009-03-16 by gf
# 2016-02-03 rh - modified to include inc and lib dirs for local src directory
# generic compiler and linker settings:
CC     = gcc
#INCDIR = -I../lua/src
INCDIR = -I../lua/src -I/usr/local/src/lua-5.1.5/src
LIB    = 
LIBDIR =  -L. -L../lua/src
LIBDIR =  -L. -L../lua/src -L/usr/local/src/lua-5.1.5/src
CFLAGS = -Os -Wall -c -m64 #-g

# generic platform specific rules:
ARCH            = $(shell uname -s)
ifeq ($(ARCH),Linux)
  CFLAGS += -fPIC
  LFLAGS =  -fPIC -shared
  #RH - don't know why this fails? works if -llua and -ldl are removed
  #LIBS          = $(LIBDIR) $(LIB) -llua -ldl
  LIBS          = $(LIBDIR) $(LIB)
  EXESUFFIX =
  SHLIBSUFFIX = .so

else  
  ifeq ($(ARCH),Darwin) # MacOSX
    LFLAGS = -bundle 
    LIBS          = $(LIBDIR) -L/usr/local/lib $(LIB) -llua
    EXESUFFIX = .app
    SHLIBSUFFIX = .so
    
  else  # windows, MinGW
    LFLAGS =  -shared
    LIBS          = $(LIBDIR) $(LIB) -llua51 -mconsole -s
    EXESUFFIX = .exe
    SHLIBSUFFIX = .dll

  endif
endif

# project specific targets:
all:  LuaXML_lib$(SHLIBSUFFIX)

# project specific link rules:
LuaXML_lib$(SHLIBSUFFIX): LuaXML_lib.o
	$(CC) -o $@ $(LFLAGS) $^ $(LIBS) 

# project specific dependencies:
LuaXML_lib.o:  LuaXML_lib.c

# generic rules and targets:
.c.o:
	$(CC) $(CFLAGS) $(INCDIR) -c $<
clean:
	rm -f *.o *~ LuaXML_lib.so LuaXML_lib.dll

