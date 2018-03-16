######################################
# Generic Makefile - Brian Bright 2018
######################################


#####################
# flags for cc/ld/etc.
#####################
AR = ar
CC = gcc

CFLAGS += -g -Wall -I./src/ -O0 -rdynamic $(OPTFLAGS)
COVFLAGS = -fprofile-arcs -ftest-coverage -g -pg
LDFLAGS += -lpthread -ldl $(OPTLIBS) #-L./build/ 
ARFLAGS = rcs
PREFIX ?= /usr/local

###########################
# define common dependencies
###########################

C_SOURCES=$(wildcard src/**/*.c src/*.c)
OBJS=$(patsubst %.c,%.o,$(C_SOURCES))

H_SOURCES=$(wildcard src/includes/*.h)
AUX += $(H_SOURCES)

TEST_SRC=$(wildcard tests/*_tests.c)
TESTS=$(patsubst %.c,%,$(TEST_SRC))

# implementation dependant
TARGET=./bin/main

LIBTARGET=./build/libYOUR_LIB.a
SO_TARGET=$(patsubst %.a,%.so,$(LIBTARGET))

# in case library source code in seperate directory
LIBSRC=$(wildcard lib/*.c)
LIBOBJS=$(patsubst %.c, %.o, $(LIBSRC))

# directory variables
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))


##################
# the build rules
##################

all: clean $(LIBTARGET) $(TARGET)
# turn on for dynamic linking
#all:  $(SO_TARGET)

#either do gcov or lcov, not both - some weird bugs.
coverage: CFLAGS = -Wall -I./src/ -O0 $(COVFLAGS)
coverage:  all
	./bin/main #change this line depending on how your proj is run
	lcov -b $(current_dir) -c -d ./src/ -o ./build/coverageinfo.info
	genhtml ./build/lcov_info.info -o ./build/coverage_html/
	@echo "Open ./build/coverage_html files in a browser for coverage data"
# in case gprof is useful - timing data for the program.
#	gprof -b ./bin/proxy ./gmon.out > ./build/proxyoput.stats
#	mv ./gmon.out ./build/

$(TARGET): build $(OBJS) 
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS) $(LDFLAGS) $(LIBTARGET)

$(LIBTARGET): CFLAGS += -fPIC
$(LIBTARGET): build $(LIBOBJS)
	$(AR) $(ARFLAGS) $@ $(LIBOBJS)
	ranlib $@

$(SO_TARGET): $(LIBTARGET) $(LIBOBJS)
	$(CC) -shared -o $@ $(LIBOBJS)

%.o: %.c $(AUX)
	$(CC) $(CFLAGS) -c $<
.PHONY: build
build:
	@mkdir -p ./build
	@mkdir -p ./bin/tests
	$(MAKE) TAGS

.PHONY: test_coverage
test_coverage: clean build $(LIBTARGET)
test_coverage: CFLAGS = -Wall -I./src/ -O0 $(COVFLAGS)
test_coverage: $(OBJS) $(TESTS)

# caution: could be implementation specific.
$(TESTS): 
	$(CC) -Wall -g -DNDEBUG $@.c $(LIBTARGET) -o ./bin/$@ $(OBJS)
	./bin/$@
	mv *.gcda ./tests/
	mv gmon.out ./tests/
	mv *.gcno ./tests/
	lcov -b $(mkfile_path) -c -d ./tests/ -o ./$@info.info
	genhtml ./$@info.info -o ./$@_html/
	@echo "Open html files in a browser for coverage data"

#the Unit Tests
.PHONY: tests
tests: CFLAGS += $(TARGET) 
tests: $(TESTS) 
	sh ./tests/runtests.sh || true

.PHONY: TAGS tags
TAGS tags:
	find ./src/ -type f -name "*.[ch]" | xargs etags -

#the Cleaner
# -- last line removes *.dSYM directories that Apple's XCode leaves
#    for debugging. doubt I'll ever code on a Mac but who knows.
.PHONY: clean
clean:
	rm -Rf ./bin/*
	rm -Rf ./build/*
	rm -rf ./*/*_html/
	find . -type f \( -name "TAGS" -o -name "*.o" -o -name "*.gc*" -o -name ".stats" \
-o -name "*.log" -o -name "*.info" -o -name "gmon.out" -o -name "*_tests" \) -exec rm {} \;
	rm -rf 'find . -name "*.dSYM" -print'

#the Install
.PHONY: install
install: all
	install -d $(DESTDIR)/$(PREFIX)/lib/
	install $(TARGET) $(DESTDIR)/$(PREFIX)/lib/

#the Checker
.PHONY: check
check:
	@echo Files with potentially dangerous functions.
	@egrep '[^_.>a-zA-Z0-9](str(n?cpy|n?cat|xfrm|n?dup|str|pbrk|tok|_)\
			|stpn?cpy|a?sn?printf|byte_)' $(SOURCES) || true



