# Makefile for http_load

# Solaris 专属
# CONFIGURE: 
# 	If you are using a SystemV-based operating system, such as Solaris, you will need to uncomment this definition.
#SYSV_LIBS = -lnsl -lsocket -lresolv

# 手动编译openssl 库时用到
# CONFIGURE: If you want to compile in support for https, uncomment these
# definitions.  You will need to have already built OpenSSL, available at
# http://www.openssl.org/  Make sure the SSL_TREE definition points to the
# tree with your OpenSSL installation - depending on how you installed it,
# it may be in /usr/local instead of /usr/local/ssl.
#SSL_TREE = /usr/local/ssl
#SSL_DEFS = -DUSE_SSL
#SSL_INC = -I$(SSL_TREE)/include
#SSL_LIBS = -L$(SSL_TREE)/lib -lssl -lcrypto

# 命令安装openssl 库时会用到
# apt-get install libssl-dev
SSL_TREE = /usr
SSL_DEFS = -DUSE_SSL
SSL_INC = -I$(SSL_TREE)/include
SSL_LIBS = -L$(SSL_TREE)/lib -lssl -lcrypto


BINDIR = /usr/local/bin
MANDIR = /usr/local/man/man1

CC = cc

CFLAGS = -O $(SRANDOM_DEFS) $(SSL_DEFS) $(SSL_INC) -ansi -pedantic -U__STRICT_ANSI__ -Wall -Wpointer-arith -Wshadow -Wcast-qual -Wcast-align -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations -Wredundant-decls -Wno-long-long

LDFLAGS = -s $(SSL_LIBS) $(SYSV_LIBS)

all: http_load

http_load: http_load.c timers.h port.h timers.o
	$(CC) $(CFLAGS) http_load.c timers.o $(LDFLAGS) -o http_load

timers.o: timers.c timers.h
	$(CC) $(CFLAGS) -c timers.c

install: all
	rm -f $(BINDIR)/http_load
	cp http_load $(BINDIR)
	rm -f $(MANDIR)/http_load.1
	cp http_load.1 $(MANDIR)

clean:
	rm -f http_load *.o core core.* *.core

tar:
	@name=`sed -n -e '/#define HTTP_LOAD_VERSION /!d' -e 's,.*http_load ,http_load-,' -e 's,",,p' version.h` ; \
		rm -rf $$name ; \
		mkdir $$name ; \
		tar cf - `cat FILES` | ( cd $$name ; tar xfBp - ) ; \
		chmod 644 $$name/Makefile ; \
		tar cf $$name.tar $$name ; \
		rm -rf $$name ; \
		gzip $$name.tar
