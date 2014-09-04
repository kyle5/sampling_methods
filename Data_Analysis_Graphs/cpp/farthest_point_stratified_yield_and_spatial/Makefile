##### configuration #####
INC := -I/opt/local/include
LIB := -L/opt/local/lib
##########################

CXX := g++
CXXFLAGS := -Wall -frounding-math
OPTFLAGS := -O2 -march=core2 -msse3

LIB += -lgmp -lCGAL  # Needs CGAL 3.7 or higher

CXXFILES := main.cpp DT.cpp
OBJS   := $(patsubst %.cpp, %.o, $(CXXFILES))
TARGET := fpo

.PHONY: all clean cleanall rebuild

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(OPTFLAGS) -o $(TARGET) $(LIB) $(OBJS)

%.o : %.cpp
	$(CXX) $(CXXFLAGS) $(OPTFLAGS) $(INC) -o $@ -c $<

clean:
	rm -f *.o

cleanall: clean
	rm -rf $(TARGET)

rebuild:
	$(MAKE) cleanall
	$(MAKE) all