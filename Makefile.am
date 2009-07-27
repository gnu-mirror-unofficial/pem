#
# Process this file with automake to produce 'Makefile.in'
#
# Makefile.am: This is a base file to generate makefile for `pem'. This
# file is part of the `pem' project version 0.7.8
# Copyright (C) 2007 2008 2009 Prasad J Pandit
#
# `pem' is a free software; you can redistribute it and/or modify it under
# the terms of GNU General Public License as published by the Free Software
# Foundation; either version 3 of the license, or(at your option) any later
# version.
#
# `pem' is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along
# with `pem'; if not, see: <http://www.gnu.org/licenses>.
#
#
# To create the configure script using this file follow these steps:
#
#  1. write Makefile.am
#  2. autoscan
#  3. aclocal
#  4. autoheader
#  5. autoconf
#  6. automake -ac
#

bin_PROGRAMS = pem
pem_SOURCES = pem.pl

# man1_MANS = pem.1
info_TEXINFOS = pem.texi

dist_man_MANS = pem.1
EXTRA_DIST = $(man_MANS) README COPYING INSTALL readme.ms pem.txt gfdl.texi

pemdir=$(pkgdatadir)
pem_DATA = pem.txt

pem: $(pem_SOURCES)
	@cp ./pem.pl pem
