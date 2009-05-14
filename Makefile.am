##
## Process this file with automake to produce 'Makefile.in'
## 
## To create the configure script using this file follow these steps
## in order
## 1. write Makefile.am    
## 2. autoscan
## 3. aclocal
## 4. autoheader
## 5. autoconf
## 6. automake -ac --foreign
##

bin_PROGRAMS = pem
pem_SOURCES = pem.pl

man1_MANS = pem.1 
info_TEXINFOS = pem.texi

dist_man_MANS = pem.1
EXTRA_DIST = $(man_MANS) README COPYING readme.ms pem.txt

pemdir=$(pkgdatadir)
pem_DATA = pem.txt

pem: $(pem_SOURCES)
	@cp ./pem.pl pem
