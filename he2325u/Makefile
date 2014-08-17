###########################################
# he2325u interface program
#
# Rainer Wetzel
# 2011-02-18
###########################################

all: he2325u

CC=gcc
CXX=g++
COBJS=./hidapi/linux/hid-libusb.o
CPPOBJS=./he2325u.o
OBJS=$(COBJS) $(CPPOBJS)
CFLAGS+=-I./hidapi/hidapi -Wall -g -c `pkg-config libusb-1.0 --cflags`
LIBS=`pkg-config libusb-1.0 libudev --libs`


he2325u: $(OBJS)
	g++ -Wall -g $^ $(LIBS) -o he2325u

$(COBJS): %.o: %.c
	$(CC) $(CFLAGS) $< -o $@

$(CPPOBJS): %.o: %.cpp
	$(CXX) $(CFLAGS) $< -o $@

clean:
	rm -f $(OBJS) he2325u

.PHONY: clean
