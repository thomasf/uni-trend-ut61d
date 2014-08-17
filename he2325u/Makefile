###########################################
# he2325u interface program
#
# Rainer Wetzel
# 2011-02-18
###########################################

all: he2325u

CXX=g++
CPPOBJS=./he2325u.o
OBJS=$(COBJS) $(CPPOBJS)
CFLAGS+=-Wall -g -c `pkg-config libusb-1.0 hidapi-hidraw --cflags`
LIBS=`pkg-config hidapi-hidraw libusb-1.0 libudev --libs`

he2325u: $(OBJS)
	g++ -Wall -g $^ $(LIBS) -o he2325u

$(CPPOBJS): %.o: %.cpp
	$(CXX) $(CFLAGS) $< -o $@

clean:
	rm -f $(OBJS) he2325u

.PHONY: clean
