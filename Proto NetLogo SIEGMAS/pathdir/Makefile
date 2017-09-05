ifeq ($(origin JAVA_HOME), undefined)
  JAVA_HOME=/usr
endif

ifeq ($(origin NETLOGO), undefined)
  NETLOGO=../..
endif

JAVAC=$(JAVA_HOME)/bin/javac
SRCS=$(wildcard src/*.java)

pathdir.zip: pathdir.jar pathdir.jar.pack.gz README.md license.md pathdir.nlogo Makefile src manifest.txt
	rm -rf pathdir
	mkdir pathdir
	cp -rp pathdir.jar pathdir.jar.pack.gz README.md license.md pathdir.nlogo Makefile src manifest.txt pathdir
	zip -rv pathdir.zip pathdir
	rm -rf pathdir

pathdir.jar pathdir.jar.pack.gz: $(SRCS) manifest.txt Makefile
	mkdir -p classes
	$(JAVAC) -g -deprecation -Xlint:all -Xlint:-serial -Xlint:-path -encoding us-ascii -source 1.6 -target 1.6 -classpath $(NETLOGO)/NetLogoLite.jar -d classes $(SRCS)
	jar cmf manifest.txt pathdir.jar -C classes .
	pack200 --modification-time=latest --effort=9 --strip-debug --no-keep-file-order --unknown-attribute=strip pathdir.jar.pack.gz pathdir.jar

