CXXFLAGS=-DNO_STORAGE -Wall -DDEBUG_BUILD --std=gnu++0x
OPTFLAGS=-O3 


ifdef DEBUG
ifeq ($(DEBUG), 1)
OPTFLAGS= -O0 -g
endif
endif
CXXFLAGS+=$(OPTFLAGS)

EXE_NAME=HMSim1
LIB_NAME=libdramsim.so
LIB_NAME_MACOS=libdramsim.dylib

SRC = $(wildcard *.cpp)
OBJ = $(addsuffix .o, $(basename $(SRC)))

#build portable objects (i.e. with -fPIC)
POBJ = $(addsuffix .po, $(basename $(SRC)))

REBUILDABLES=$(OBJ) ${POBJ} $(EXE_NAME) $(LIB_NAME) 

all: ${EXE_NAME}

#   $@ target name, $^ target deps, $< matched pattern
$(EXE_NAME): $(OBJ)
	$(CXX) $(CXXFLAGS) -o $@ $^ 
	@echo "Built $@ successfully" 

$(LIB_NAME): $(POBJ)
	g++ -g -shared -Wl,-soname,$@ -o $@ $^
	@echo "Built $@ successfully"

$(LIB_NAME_MACOS): $(POBJ)
	g++ -dynamiclib -o $@ $^
	@echo "Built $@ successfully"

#include the autogenerated dependency files for each .o file
-include $(OBJ:.o=.dep)
-include $(POBJ:.po=.deppo)

# build dependency list via gcc -M and save to a .dep file
%.dep : %.cpp
	@$(CXX) -M $(CXXFLAGS) $< > $@

%.deppo : %.cpp
	@$(CXX) -M $(CXXFLAGS) -MT"$*.po" $< > $@

# build all .cpp files to .o files
%.o : %.cpp
	g++ $(CXXFLAGS) -o $@ -c $<

#po = portable object .. for lack of a better term
%.po : %.cpp
	g++ $(CXXFLAGS) -DLOG_OUTPUT -fPIC -o $@ -c $<

clean: 
	-rm -f $(REBUILDABLES) *.dep *.deppo
