
CFLAGS=-Wall -Werror -Wextra -Os -fPIE
AR=ar
ARFLAGS=rcs
ZIGOUT=zig-out/lib
LPATH=-L.
ZIG_SRCS=$(wildcard src/*.zig)

.PHONY: clean libadd.a test default

default: main

%.o:: %.c
	$(CC) -o $@ -c $(CFLAGS) $^

$(ZIGOUT)/libadd.a: $(ZIG_SRCS)
	zig build

libi32math.a: $(ZIGOUT)/libadd.a mul.o
	cp $(ZIGOUT)/libadd.a ./libi32math.a
	$(AR) $(ARFLAGS) libi32math.a mul.o

main: main.o libi32math.a
	$(CC) -o main $(CFLAGS) $(LPATH) $< -li32math

test: $(ZIG_SRCS)
	zig build test

clean:
	rm -f *.o *.a main
	rm -rf zig-out .zig-cache
