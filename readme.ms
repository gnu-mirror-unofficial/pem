\" This is the manuscript of the readme file for pem. 
\" Use nroff -ms <file-name> to format this file.
\" (C) 2007 2008 2009 Prasad J Pandit
\"

.po 1.25i
.pl 66
.ll 6i

.nr PO 1.25i
.nr PL 66
.nr LL 6i
.nr HM 1i
.nr FM 1i

\" Page header
.ds LH
.ds CH
.ds RH

\" Page footer
.ds LF
.ds CF
.ds RF

\" No hyphenation
.hy 0
.nr HY 0


.ce 2
pem - 0.7.7
===========
.LP
Hi,
.PP
I am happy to give you this *new* version of Pem. Pem is a handy tool to
help you keep track of your personal income and expenses. On Linux like
systems, Pem works by storing the details in a CSV file, placed in the
~/.pem directory under your $HOME directory; On Windows, the same file is
placed in pem directory, under the %USERPROFILE% directory. Each such file
is named after the current month, and is automatically created by Pem when
you enter the first record for the month. It is not advisable to edit these
files by hand.
.LP
Installation:
.br
=============
.sp
On Linux: just say
.br
---------
.DS I
$ ./configure [--prefix=/install/directory]
$ make
# make install
.DE
By default, this should install Pem under /usr/local/bin directory, assuming
you have the right privileges to do that. You may also consider changing the
prefix using the --prefix option, in case you don't have the necessary
permissions. For more information please see:
.sp
.in +5
$ ./configure --help.
.in -5

.LP
On Windows:
.br
-----------
.br
    Copy and paste the pem.pl file to the directory where you keep your
other executable files, and make sure, this directory is included in your
%PATH% variable. That's all, Pem is ready to serve you. :)
.LP
For usage information about pem, on Linux, try
.DS I
$ pem --help
$ man pem
$ info pem
.DE
On Windows try
.DS I
C:\\> pem.pl --help
.DE
Also, use the pem.txt file to explore what Pem can do, and how it does
that.

.sp 2
Bugs/Comments:
.br
--------------
.PP
Please send any suggestions/comments or bug reports you may have, to
<pj.pandit@yahoo.co.in>. They are most welcome and appreciated.
.sp 2
Thank you!
