

# Compiler and linker options.
CC     = cc
CXX    = c++
NASM   = nasm
LINKER = c++

# Source and include directories.
SRC_DIR     = src
INCLUDE_DIR = -I$(SRC_DIR)/include -I$(SRC_DIR)/include/third_party
SOURCES_DIR = $(SRC_DIR)/sources
ROOT_DEPDIR = .deps

GLOBAL_SOURCE_DIR = $(SOURCES_DIR)/teavpn2/global
CLIENT_SOURCE_DIR = $(SOURCES_DIR)/teavpn2/client
SERVER_SOURCE_DIR = $(SOURCES_DIR)/teavpn2/server

# C/C++ compile flag.
CC_COMPILE_FLAGS  = -std=c99 $(INCLUDE_DIR) -c
CXX_COMPILE_FLAGS = -std=c++17 $(INCLUDE_DIR) -D_GLIBCXX_ASSERTIONS -c

LIB_LINK_FLAGS    = -lpthread

ifeq ($(RELEASE_MODE),1)

	# Compile flags that apply to CC and CXX.
	CCCXX_COMPILE_FLAGS = -s -fno-stack-protector -Ofast -fPIC -fasynchronous-unwind-tables -fexceptions -mstackrealign -DNDEBUG -D_GNU_SOURCE -D_REENTRANT

	# Link flags
	LINK_FLAGS = -s -Ofast -fPIC

else

	# Compile flags that apply to CC and CXX.
	CCCXX_COMPILE_FLAGS = -fstack-protector-strong -ggdb3 -O0 -grecord-gcc-switches -fPIC -fasynchronous-unwind-tables -fexceptions -mstackrealign -D_GNU_SOURCE -D_REENTRANT -DTEAVPN_DEBUG

	# Link flags
	LINK_FLAGS = -ggdb3 -O0 -fPIC

endif


# Target compile.
CLIENT_BIN = teavpn_client
SERVER_BIN = teavpn_server


###################### Global Part ######################
# Source code that must be compiled for client and server.

# Global source code.
GLOBAL_CC_SOURCES   = $(shell find ${GLOBAL_SOURCE_DIR} -name '*.c')
GLOBAL_CXX_SOURCES  = $(shell find ${GLOBAL_SOURCE_DIR} -name '*.cc')
GLOBAL_CXX_SOURCES += $(shell find ${GLOBAL_SOURCE_DIR} -name '*.cpp')
GLOBAL_CXX_SOURCES += $(shell find ${GLOBAL_SOURCE_DIR} -name '*.cxx')

# Global objects.
GLOBAL_CC_OBJECTS   = $(GLOBAL_CC_SOURCES:%=%.o)
GLOBAL_CXX_OBJECTS  = $(GLOBAL_CXX_SOURCES:%=%.o)
GLOBAL_OBJECTS      = $(GLOBAL_CC_OBJECTS)
GLOBAL_OBJECTS     += $(GLOBAL_CXX_OBJECTS)

# Global depends directories.
GLOBAL_DIR_L     = $(shell find ${GLOBAL_SOURCE_DIR} -type d)
GLOBAL_DEPDIR    = $(GLOBAL_DIR_L:%=${ROOT_DEPDIR}/%)
GLOBAL_DEPFLAGS  = -MT $@ -MMD -MP -MF ${ROOT_DEPDIR}/$*.d
GLOBAL_DEPFILES  = $(GLOBAL_CC_SOURCES:%=${ROOT_DEPDIR}/%.d})
GLOBAL_DEPFILES += $(GLOBAL_CXX_SOURCES:%=${ROOT_DEPDIR}/%.d})
###################### End of Global Part ######################


###################### Client Part ######################
# Source code that must be compiled for client.

# Global source code.
CLIENT_CC_SOURCES   = $(shell find ${CLIENT_SOURCE_DIR} -name '*.c')
CLIENT_CXX_SOURCES  = $(shell find ${CLIENT_SOURCE_DIR} -name '*.cc')
CLIENT_CXX_SOURCES += $(shell find ${CLIENT_SOURCE_DIR} -name '*.cpp')
CLIENT_CXX_SOURCES += $(shell find ${CLIENT_SOURCE_DIR} -name '*.cxx')

# Global objects.
CLIENT_CC_OBJECTS   = $(CLIENT_CC_SOURCES:%=%.o)
CLIENT_CXX_OBJECTS  = $(CLIENT_CXX_SOURCES:%=%.o)
CLIENT_OBJECTS      = $(CLIENT_CC_OBJECTS)
CLIENT_OBJECTS     += $(CLIENT_CXX_OBJECTS)

# Global depends directories.
CLIENT_DIR_L     = $(shell find ${CLIENT_SOURCE_DIR} -type d)
CLIENT_DEPDIR    = $(CLIENT_DIR_L:%=${ROOT_DEPDIR}/%)
CLIENT_DEPFLAGS  = -MT $@ -MMD -MP -MF ${ROOT_DEPDIR}/$*.d
CLIENT_DEPFILES  = $(CLIENT_CC_SOURCES:%=${ROOT_DEPDIR}/%.d})
CLIENT_DEPFILES += $(CLIENT_CXX_SOURCES:%=${ROOT_DEPDIR}/%.d})
###################### End of Client Part ######################


###################### Server Part ######################
# Source code that must be compiled for client.

# Server source code.
SERVER_CC_SOURCES   = $(shell find ${SERVER_SOURCE_DIR} -name '*.c')
SERVER_CXX_SOURCES  = $(shell find ${SERVER_SOURCE_DIR} -name '*.cc')
SERVER_CXX_SOURCES += $(shell find ${SERVER_SOURCE_DIR} -name '*.cpp')
SERVER_CXX_SOURCES += $(shell find ${SERVER_SOURCE_DIR} -name '*.cxx')

# Server objects.
SERVER_CC_OBJECTS   = $(SERVER_CC_SOURCES:%=%.o)
SERVER_CXX_OBJECTS  = $(SERVER_CXX_SOURCES:%=%.o)
SERVER_OBJECTS      = $(SERVER_CC_OBJECTS)
SERVER_OBJECTS     += $(SERVER_CXX_OBJECTS)

# Server depends directories.
SERVER_DIR_L     = $(shell find ${SERVER_SOURCE_DIR} -type d)
SERVER_DEPDIR    = $(SERVER_DIR_L:%=${ROOT_DEPDIR}/%)
SERVER_DEPFLAGS  = -MT $@ -MMD -MP -MF ${ROOT_DEPDIR}/$*.d
SERVER_DEPFILES  = $(SERVER_CC_SOURCES:%=${ROOT_DEPDIR}/%.d})
SERVER_DEPFILES += $(SERVER_CXX_SOURCES:%=${ROOT_DEPDIR}/%.d})
###################### End of Server Part ######################


all: client server

.PHONY: deps_dir

deps_dir: $(GLOBAL_DEPDIR)


${ROOT_DEPDIR}:
	mkdir -pv $@


###################### Build global sources ######################
global: $(GLOBAL_OBJECTS)

$(GLOBAL_DEPDIR): | $(ROOT_DEPDIR)
	mkdir -pv $@

$(GLOBAL_CC_OBJECTS): | $(GLOBAL_DEPDIR)
	$(CC) $(GLOBAL_DEPFLAGS) $(CC_COMPILE_FLAGS) $(CCCXX_COMPILE_FLAGS) $(@:%.o=%) -o $@

$(GLOBAL_CXX_OBJECTS): | $(GLOBAL_DEPDIR)
	$(CXX) $(GLOBAL_DEPFLAGS) $(CXX_COMPILE_FLAGS) $(CCCXX_COMPILE_FLAGS) $(@:%.o=%) -o $@

-include $(GLOBAL_DEPFILES)
###################### End of build global sources ######################



###################### Build client sources ######################
client: $(CLIENT_BIN)

$(CLIENT_DEPDIR): | $(ROOT_DEPDIR)
	mkdir -pv $@

$(CLIENT_CC_OBJECTS): | $(CLIENT_DEPDIR)
	$(CC) $(CLIENT_DEPFLAGS) $(CC_COMPILE_FLAGS) $(CCCXX_COMPILE_FLAGS) $(@:%.o=%) -o $@

$(CLIENT_CXX_OBJECTS): | $(CLIENT_DEPDIR)
	$(CXX) $(CLIENT_DEPFLAGS) $(CXX_COMPILE_FLAGS) $(CCCXX_COMPILE_FLAGS) $(@:%.o=%) -o $@

-include $(CLIENT_DEPFILES)

$(CLIENT_BIN): $(GLOBAL_OBJECTS) $(CLIENT_OBJECTS)
	$(LINKER) $(LINK_FLAGS) -o $@ $(CLIENT_OBJECTS) $(GLOBAL_OBJECTS) $(LIB_LINK_FLAGS)
###################### End of build client sources ######################



###################### Build server sources ######################
server: $(SERVER_BIN)

$(SERVER_DEPDIR): | $(ROOT_DEPDIR)
	mkdir -pv $@

$(SERVER_CC_OBJECTS): | $(SERVER_DEPDIR)
	$(CC) $(SERVER_DEPFLAGS) $(CC_COMPILE_FLAGS) $(CCCXX_COMPILE_FLAGS) $(@:%.o=%) -o $@

$(SERVER_CXX_OBJECTS): | $(SERVER_DEPDIR)
	$(CXX) $(SERVER_DEPFLAGS) $(CXX_COMPILE_FLAGS) $(CCCXX_COMPILE_FLAGS) $(@:%.o=%) -o $@

-include $(SERVER_DEPFILES)

$(SERVER_BIN): $(GLOBAL_OBJECTS) $(SERVER_OBJECTS)
	$(LINKER) $(LINK_FLAGS) -o $@ $(SERVER_OBJECTS) $(GLOBAL_OBJECTS) $(LIB_LINK_FLAGS)
###################### End of build server sources ######################



###################### Cleaning part ######################
clean: clean_global clean_client clean_server
	rm -rfv $(ROOT_DEPDIR)

clean_global:
	rm -rfv $(GLOBAL_OBJECTS)
	rm -rfv $(GLOBAL_DEPDIR)

clean_server:
	rm -rfv $(SERVER_OBJECTS)
	rm -rfv $(SERVER_BIN)
	rm -rfv $(SERVER_DEPDIR)

clean_client:
	rm -rfv $(CLIENT_OBJECTS)
	rm -rfv $(CLIENT_BIN)
	rm -rfv $(CLIENT_DEPDIR)
###################### End of cleaning part ######################
