# Generated automatically from Makefile.in by configure.

##############################
#   Makefile for QuickPage   #
##############################



CCENV=		-DTCP_WRAPPERS 
#DEBUG=		-g -DDEBUG

CFLAGS=		 $(DEBUG) $(CCENV)
CPPFLAGS=	-I/usr/local/include
LDFLAGS=	-L/usr/local/lib
LDLIBS=		-lwrap -lnsl -lsocket 

prefix=		/usr/local
exec_prefix=	${prefix}

bindir=		${exec_prefix}/bin
mandir=		${prefix}/man

CC=		cc
RM=		/bin/rm -f
CP=		/bin/cp
CHMOD=		/bin/chmod
MKDIR=		/bin/mkdir


#####################################################################
# ----- you shouldn't need to change anything below this line ----- #
#####################################################################

VERSION=	3.3
PROG=		qpage
NAME=		$(PROG)-$(VERSION)
INCL=		$(PROG).h config.h

SRCS=		$(PROG).c usersnpp.c srvrsnpp.c queue.c \
		config.c util.c ixo.c ident.c readmail.c \
		sendmail.c

OBJS=		$(PROG).o usersnpp.o srvrsnpp.o queue.o \
		config.o util.o ixo.o ident.o readmail.o \
		sendmail.o

CLNTSRCS=	$(PROG).c usersnpp.c util.c readmail.c
CLNTOBJS=	$(PROG).o usersnpp.o util.o readmail.o

.c.o:
		$(CC) $(CFLAGS) $(CPPFLAGS) -c $<

all:		config-check $(PROG)

config-check .cflags: config.h
		@set +e; echo $(CFLAGS) > .cflags.$$$$ ; \
		if cmp .cflags .cflags.$$$$ ; \
		then rm .cflags.$$$$ ; \
		else mv .cflags.$$$$ .cflags ; \
		fi >/dev/null 2>/dev/null

config.h:
		@echo
		@echo 'Please type "./configure" first!'
		@echo
		@exit 1

install:	all
		$(RM) $(bindir)/$(PROG)
		$(MKDIR) -p $(bindir)
		$(CP) $(PROG) $(bindir)
		$(RM) $(mandir)/man1/$(PROG).1
		$(MKDIR) -p $(mandir)/man1
		$(CP) $(PROG).man $(mandir)/man1/$(PROG).1

#		$(INSTALL) S99qpage /etc/rc3.d
#		ln /etc/rc3.d/S99qpage /etc/init.d/qpage

$(OBJS):	$(INCL) Makefile
$(CLNTOBJS):	.cflags

$(PROG):	$(OBJS)
		$(RM) $(PROG)
		$(CC) -o $(PROG) $(OBJS) $(LDFLAGS) $(LDLIBS)

client:
		@$(MAKE) CCENV='-DCLIENT_ONLY $(CCENV)' OBJS="$(CLNTOBJS)"

lint:
		$(LINT) -mux $(CPPFLAGS) $(CCENV) $(SRCS)

client-lint:
		$(LINT) -mux -DCLIENT_ONLY $(CPPFLAGS) $(CCENV) $(CLNTSRCS)

client-install:
		@$(MAKE) CCENV='-DCLIENT_ONLY $(CCENV)' OBJS="$(CLNTOBJS)" \
			install

clean:
		$(RM) $(PROG) $(OBJS) .cflags core tags

clobber:	clean
		$(RM) config.h config.cache config.log config.status

##########################################################################
# ----- everything below this line is intended for developers only ----- #
##########################################################################

tar:		clean history doc
		$(RM) ../$(NAME).work-in-progress.tar.Z ../$(NAME).tar.Z
		tar -cvf ../$(NAME).work-in-progress.tar -C .. $(NAME)
		compress ../$(NAME).work-in-progress.tar
		(cd ..; tar -cvfFFX - $(NAME)/exclude $(NAME)/* \
			| compress > $(NAME).tar.Z)
		zcat ../$(NAME).tar.Z | tar -tvf -

tags:		$(SRCS) $(INCL)
		ctags $(SRCS) $(INCL)

history:
		sccs prt $(SRCS) > HISTORY

last:
		@sccs prt -y $(SRCS) | awk '{print $$1,$$2,$$3,$$4,$$5,$$6}'

version:
		sccs admin -f q$(VERSION) $(PROG).h $(SRCS)
		sed 's/VERSION/$(VERSION)/' exclude.in > exclude

diffs:
		sccs diffs $(INCL) $(SRCS)

doc:		$(PROG).man
		troff -man qpage.man \
			| /usr/lib/lp/postscript/dpost > qpage.ps
		nroff -man $(PROG).man \
			| sed -e 's/.//g' > $(PROG).doc

pkg:
		pkgmk -o -d /tmp PSTAMP=`date "+%y%m%d"`
		pkgtrans -os /tmp TJDtmp TJDqpage
		mv /tmp/TJDtmp TJDqpage
		rm -rf /tmp/TJDqpage
