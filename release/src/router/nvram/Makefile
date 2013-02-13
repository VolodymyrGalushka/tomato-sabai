include ../common.mak

CFLAGS = -O2 -Wall $(EXTRACFLAGS) -fPIC
CFLAGS += -I$(TOP)/shared -I$(SRCBASE)/include -I.
ifeq ($(STATIC),1)
CFLAGS += -static
endif

all: libnvram.so libnvram.a nvram

libnvram.so: nvram_linux.o nvram_convert.o
	# [ nvram ] CC $@"
	@$(CC) -shared $(CFLAGS) -o $@ $^

libnvram.a: nvram_linux.o nvram_convert.o
	# [ nvram ] AR $@"
	@$(AR) cruv $@ $^
	
nvram: nvram.o defaults.o libnvram.so
	# [ nvram ] CC $@"
ifeq ($(STATIC),1)
	@$(CC) $(CFLAGS) -static -o $@ nvram.o defaults.o -L. -lnvram -L$(TOP)/shared -lshared
else
	@$(CC) $(CFLAGS) -o $@ nvram.o defaults.o -L. -lnvram -L$(TOP)/shared -lshared
endif
	# [ nvram ] Sizecheck and copy to temp.
	@$(SIZECHECK)
	@$(CPTMP)
	
install: all
	# [ nvram ] install $@"
	@install -D libnvram.so $(INSTALLDIR)/usr/lib/libnvram.so
	@install -D nvram $(INSTALLDIR)/bin/nvram
	@$(STRIP) $(INSTALLDIR)/usr/lib/libnvram.so
	@$(STRIP) $(INSTALLDIR)/bin/nvram
	@chmod 0555 $(INSTALLDIR)/bin/nvram

clean:
	@rm -f nvram *.o *.a *.so

	
%.o: %.c .%.depend
	# [ nvram ] CC $@"
	@$(CC) $(CFLAGS) -o $@ -c $<

.depend: $(OBJS:%.o=%.c)
	# [ nvram ] CC $@"
	@$(CC) $(CFLAGS) -M $^ > .depend

.%.depend: %.c
	# [ nvram ] CC $@"
	@$(CC) $(CFLAGS) -M $< > $@

-include $(OBJS:%.o=.%.depend)
