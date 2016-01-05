DEBUG ?= n

ifeq ($(DEBUG),y)
  DBGFLAGS = -g -DDEBUG
else
  DBGFLAGS = -O2
endif

XTRA_CFLAGS = $(DBGFLAGS) -Wall
XTRALIBS = -lrt -lpthread

all: vm-trace cscope

vm-trace: vm-trace.c
	$(CC) $(XTRA_CFLAGS) $< -o $@ $(XTRALIBS)

cscope.out: vm-trace.c
	cscope -b

cscope: cscope.out

clean:
	rm -f *.o core* vm-trace cscope.*
