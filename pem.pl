#!/usr/bin/perl -w
#
# pem.pl: Pem is a script to manage my personal income and expenses. This
# file is a part of the `pem' project version 0.7.6
# Copyright (C) 2007 2008 2009 Prasad J Pandit
#
# `pem' is a free software; you can redistribute it and/or modify it under
# the terms of GNU General Public License as published by the Free Software
# Foundation; But only under version 2 of the License.
#
# `pem' is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along
# with `pem'; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA  02111-1307  USA
#

use strict;
use POSIX qw(strftime);
my ($prog, $ver, $pemdir, $fpem) = ("", "0.7.6", "", "");

my ($DAILY, $MONTHLY, $CATEGORYWISE) = (1, 2, 4);
my ($ern, $mode, $mstep, $spc, $lln) = (0, 0, 1, "\t", 0);
my ($mm, $yy, $tdays, $totl, $dfmt, $tag) = (0, 0, 0, 0, "", "");

my @mn = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @wd = qw( Sunday Monday Tuesday Wednesday Thursday Friday Saturday );


sub usage
{
    printf ("Usage: %s [OPTIONS] [<description> <amount> ...]\n", $prog);
}


sub printh
{
    my $fmt = " %-23s %s\n";

    usage ();
    printf ("\nOptions: \n");

    printf ("\n");
    printf ($fmt, "  -c --category <name>", "categorise/tag your expenses");
    printf ($fmt, "  -e --earned", "indicates income");
    printf ($fmt, "  -f --file <name>", "specify file name");

    printf ("\n");
    printf ($fmt, "  -s [n]", "show daily report with total after [n] days");
    printf ($fmt, "  -m [n]", "monthly report with total after [n] months");
    printf ($fmt, "  -C", "show category/tag-wise report");
    printf ($fmt, "  -t --total", "show just the total");

    printf ("\n");
    printf ($fmt, "  -M --month <mm>", "select a month (01 <= mm <= 12)");
    printf ($fmt, "  -Y --year  <yy>", "select an year (00 <= yy <= 99)");

    printf ("\n");
    printf ($fmt, "  -h --help", "show this help");
    printf ($fmt, "  -v --version", "show version");

    printf ("\n");
    printf ("Report bugs to <pj.pandit\@yahoo.co.in>\n");
}


sub check_options
{
    my ($i, $arg, $cnt) = (0, "", 0);

    $mode = 0;
    for ($i = 0; $i < @ARGV; $i++)
    {
        $arg = $ARGV[$i];
        if ($arg eq "-c" || $arg eq "--category")
        {
            die ("$prog: value <name> missing\n") if ($arg eq $ARGV[$#ARGV]);
            $arg = $ARGV[++$i];
            $tag = $arg;

            die ("$prog: do not use comma(,) in tags!\n") if ($tag =~ /,/);

            $cnt += 2;
        }
        elsif ($arg eq "-C")
        {
            $mode |= $CATEGORYWISE;       # show category/tag-wise report
            $cnt++;
        }
        elsif ($arg eq "-e" || $arg eq "--earned")
        {
            $ern = 1;
            $cnt++;
        }
        elsif ($arg eq "-f" || $arg eq "--file")
        {
            die ("$prog: filename missing\n") if ($arg eq $ARGV[$#ARGV]);
            $fpem = $ARGV[++$i];
            $cnt += 2;
        }
        elsif ($arg eq "-h" || $arg eq "--help")
        {
            printh ();
            exit 0;
        }
        elsif ($arg eq "-m")
        {
            $mode |= $MONTHLY;       # show monthly report
            $cnt++;

            if ($arg ne $ARGV[$#ARGV])
            {
                if ($ARGV[$i + 1] =~ /^\d+$/)
                {
                    $mstep = $ARGV[++$i];
                    $cnt++;

                    $mstep = 01 if ($mstep < 01);
                    $mstep = 12 if ($mstep > 12);
                }
            }
        }
        elsif ($arg eq "-M" || $arg eq "--month")
        {
            die ("$prog: value <mm> missing\n") if ($arg eq $ARGV[$#ARGV]);

            $mm = $ARGV[++$i];
            die ("$prog: <mm> should be between 1..12\n")
                            if ($mm =~ /[^\d]+/ || $mm < 1 || $mm > 12);
            $cnt += 2;
        }
        elsif ($arg eq "-s")
        {
            $mode |= $DAILY;         # show daily report
            $cnt++;

            if ($arg ne $ARGV[$#ARGV])
            {
                if ($ARGV[$i + 1] =~ /^\d+$/)
                {
                    $tdays = $ARGV[++$i];
                    $cnt++;
                }
            }
        }
        elsif ($arg eq "-t" || $arg eq "--total")
        {
            $totl = 1;
            $cnt++;
        }
        elsif ($arg eq "-v" || $arg eq "--version")
        {
            printf ("%s version %s\n", $prog, $ver);
            exit 0;
        }
        elsif ($arg eq "-Y" || $arg eq "--year")
        {
            die ("$prog: value <yy> missing\n") if ($arg eq $ARGV[$#ARGV]);

            $yy = $ARGV[++$i];
            die ("$prog: year should be a numeric value like 2008 or 08\n")
                                                     if (!($yy =~ /^\d+$/));
            $yy = $yy % 100;
            $yy = "0".$yy if ($yy < 10);
            $cnt += 2;
        }
        elsif ($arg =~ /^\-{1,}\w*/)
        {
            printf ("%s: invalid option: `%s'\n", $prog, $arg);
            exit 1;
        }
    }
    shift @ARGV while ($cnt-- > 0);
}


sub initpem
{
    my $mi = $mm;

    $mi = strftime ("%m", localtime (time)) if ($mi == 0);
    $yy = strftime ("%y", localtime (time)) if ($yy == 0);

    my $mnth = $mn[$mi - 1];
    if ($^O eq "MSWin32")
    {
        $pemdir = $ENV{"USERPROFILE"}."\\pem";
        if ($mode == 0)
        {
            mkdir ($pemdir) if (!defined (-e ($pemdir)));
            die ("$prog: could not create `$pemdir'\n") if (-d ($pemdir) != 1);
        }
        $pemdir = $pemdir."\\".$yy;
        if ($mode == 0)
        {
            mkdir ($pemdir) if (!defined (-e ($pemdir)));
            die ("$prog: could not create `$pemdir'\n") if (-d ($pemdir) != 1);
        }
        $fpem = $pemdir."\\".$mnth if ($fpem eq "");
    }
    else  # It is Linux or Unix :)
    {
        $pemdir = $ENV{"HOME"}."/.pem";
        if ($mode == 0)
        {
            mkdir ($pemdir) if (!defined (-e ($pemdir)));
            die ("$prog: could not create `$pemdir'\n") if (-d ($pemdir) != 1);
        }
        $pemdir = $pemdir."/".$yy;
        if ($mode == 0)
        {
            mkdir ($pemdir) if (!defined (-e ($pemdir)));
            die ("$prog: could not create `$pemdir'\n") if (-d ($pemdir) != 1);
        }
        $fpem = $pemdir."/".$mnth if ($fpem eq "");
    }
}


sub basename
{
    my ($slash, $pos, $prg) = ("/", 0, "");

    $slash = "\\" if ($^O eq "MSWin32");
    $pos = rindex $_[0], $slash;
    chomp ($prg = substr ($_[0], $pos + 1));

    return $prg;
}


# main ()
{
    my ($i, $ernd, $spnt) = (0, 0, 0);

    $prog = basename ($0);
    usage () && exit 0 if (@ARGV < 1);

    check_options ();
    usage () && exit 0 if (@ARGV == 0 && $mode == 0);

    initpem ();
    if ($mode != 0)
    {
        show ($mode);
        exit 0;
    }

    die ("$prog: amount missing!\n") if (@ARGV % 2 != 0);
    open (FPEM, ">>$fpem") or die ("$prog: could not open file `$fpem'\n");
    for ($i = 0; $i < @ARGV; $i += 2)
    {
        if ($ARGV[$i] =~ /,/)
        {
            printf ("$prog: hey, don't use comma(,) in the description!\n");
            last;
        }
        if ($ARGV[$i + 1] =~ /^\d*[\.]?\d+$/)
        {
            $spnt = $ARGV[$i + 1] if ($ern == 0);
            $ernd = $ARGV[$i + 1] if ($ern == 1);
        }
        else
        {
            printf ("$prog: amount must be numeric!\n");
            last;
        }
        printf FPEM "%ld,%s,%.2f,%.2f,%s\n",
                                    time (), $ARGV[$i], $ernd, $spnt, $tag;
        $ernd = $spnt = 0;
    }
    close FPEM;

    exit 0;
}


sub show
{
    daily () if ($_[0] & $DAILY);
    monthly () if ($_[0] & $MONTHLY);
    categorywise () if ($_[0] & $CATEGORYWISE);
}


sub daily
{
    my (@col) = ("");
    my ($tern, $tspnt, $wday, $dt) =  (0, 0, "", "");
    my ($cnt, $flag, $rec, $ldt) = (0, 0, "", "0");

    if (!defined ($ENV{"PEMTIME"}) || $ENV{"PEMTIME"} eq "")
    {
        $ENV{"PEMTIME"} = "%b-%d %y";
    }

    open (FPEM, "$fpem") or die ("$prog: could not open file `$fpem'\n");
    die ("$prog: input file `$fpem' is empty\n") if (-z FPEM);
    while ($rec = <FPEM>)
    {
        chomp ($rec);
        @col = split (',', $rec);

        $tag = $ARGV[0];
        if (defined ($tag))
        {
            next if ((!defined ($col[4]) || (!is_subset ($col[4], $tag)
                                         && !is_subset ($tag, $col[4])))
                     && (!is_subset ($col[1], $tag)
                         && !is_subset ($tag, $col[1])));
        }

        $dt = strftime ($ENV{"PEMTIME"}, localtime ($col[0]));

        # Set minimum length of the date field, because it'll vary with
        # the value of environment variable $PEMTIME.
        #
        my $dln = length ($dt);
        $dln = 10 if (10 > length ($dt));
        $dfmt = sprintf("%%-%ds", $dln);
        $lln = $dln + 30 + 10 + 10 + 5;     #length of the horizontal line.

        if ($flag == 0)
        {
            printf ("$spc"); ln ("-", $lln);
            printf ("$spc|$dfmt|%-30s|", "   Date", "    Description");
            printf ("%10s|%10s|\n", "Earned  ", "Spent  ");
        }
        if ($ldt ne $dt)
        {
            if ($ldt ne "0" && $tdays > 0 && (++$cnt % $tdays == 0))
            {
                show_total ($ldt, $wday, $tern, $tspnt);
            }
            $ldt = $dt;
            $flag = 0;
            $wday = strftime ("%A", localtime ($col[0]));
            if ($totl == 0) { printf ("$spc"); ln ("-", $lln); }
        }
        $dt = "" if ($flag == 1);
        if ($totl == 0)
        {
            printf ("$spc|$dfmt|%-30s|", $dt, $col[1]);
            printf ("%10.2f|%10.2f|\n", $col[2], $col[3]);
        }
        $tern  += $col[2];
        $tspnt += $col[3];
        $flag = 1;
    }
    if ($flag)
    {
        show_total ($ldt, $wday, $tern, $tspnt);
        printf ("$spc"); ln ("-", $lln);
        printf ("$spc|$dfmt|%-30s|", "", "Average expense/day");
        printf ("%21.2f|\n", $tspnt / no_of_days ($col[0]));
        printf ("$spc"); ln ("-", $lln);
    }

    close FPEM;
}


sub show_total
{
    my ($ldt, $wday, $tern, $tspnt) = ($_[0], $_[1], $_[2], $_[3]);

    printf ("$spc"); ln ("-", $lln);
    printf ("$spc|$dfmt|%-30s|", $ldt, $wday." (Total)");
    printf ("%10.2f|%10.2f|\n", $tern, $tspnt);

    if (!defined ($tag))
    {
        printf ("$spc"); ln ("-", $lln);
        printf ("$spc|$dfmt|%-30s|", "", "Balance");
        printf ("%21.2f|\n", $tern - $tspnt);
    }
}


sub ln
{
    my ($i, $c, $len) = (0, $_[0], $_[1]);

    for ($i = 0; $i < $len; $i++)
    {
        printf ("%s", $c);
    }
    printf ("\n");
}


sub monthly
{
    my @inc = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    my @exp = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    my ($te, $ts, $tern, $tspnt) = (0, 0, 0, 0, 0);
    my ($mname, $mnth, $rec, @col) = ("", "", "", "");
    my ($i, $td, $cnt, $nday, $tday) = (0, 0, 0, 0, 0);

    $i = strftime ("%C", localtime(time()))."$yy";
    printf ("$spc"); ln ("-", 65);
    printf ("$spc|%-26s|%12s|", "   Month  of  $i ", "Earned  ");
    printf ("%12s|%10s|\n", "Spent  ", "Exp/day ");
    printf ("$spc"); ln ("-", 65);

    $i = 0;
    $i = $mm - 1 if ($mm != 0);
    for (; $i < @mn; $i++)
    {
        $mnth = $pemdir."/".$mn[$i] if ($^O eq "linux");
        $mnth = $pemdir."\\".$mn[$i] if ($^O eq "MSWin32");

        next if (!defined (open (FPEM, "$mnth")) || (-z FPEM));

        while ($rec = <FPEM>)
        {
            chomp ($rec);
            @col = split (',', $rec);

            $tag = $ARGV[0];
            if (defined ($tag))
            {
                next if ((!defined ($col[4]) || (!is_subset ($col[4], $tag)
                                             && !is_subset ($tag, $col[4])))
                         && (!is_subset ($col[1], $tag)
                             && !is_subset ($tag, $col[1])));
            }

            $inc[$i] += $col[2];
            $exp[$i] += $col[3];
        }
        close FPEM;

        next if ($exp[$i] == 0  &&  $inc[$i] == 0);

        $cnt++;
        $mname = strftime ("%B", localtime ($col[0]));
        $nday = no_of_days ($col[0]);
        $tern += $inc[$i];
        $tspnt += $exp[$i];
        $tday += $nday;

        if ($mstep == 1)
        {
            printf ("$spc|%-26s|%12.2f|", $mname, $inc[$i]);
            printf ("%12.2f|%10.2f|\n", $exp[$i], $exp[$i] / $nday);
            printf ("$spc"); ln ("-", 65);
        }
        elsif ($cnt % $mstep == 0)
        {
            my ($avg) = ($tspnt - $ts) / ($tday - $td);
            my ($mnm) = strftime ("%m", localtime ($col[0]));

            $mname = $mn[$mnm - $mstep]." - $mname";
            printf ("$spc|%-26s|%12.2f|", $mname, $tern - $te);
            printf ("%12.2f|%10.2f|\n", $tspnt - $ts, $avg);
            printf ("$spc"); ln ("-", 65);

            $td = $tday;
            $te = $tern;
            $ts = $tspnt;
        }
    }
    if ($cnt)
    {
        printf ("$spc|%-26s|%12.2f|", "Total", $tern);
        printf ("%12.2f|%10.2f|\n", $tspnt, $tspnt / $tday);
        printf ("$spc"); ln ("-", 65);
        printf ("$spc|%-26s|%25.2f|", "Average expense/month", $tspnt / $cnt);
        printf ("%10s|\n", "");
        printf ("$spc"); ln ("-", 65);
    }
}


# categorywise: shows cumulative income/expenses for each tag or category.
#
sub categorywise
{
    my (%tag, @col) = ((), ());
    my ($rec, $flag) = ("", 0);

    open (FPEM, "$fpem") or die ("$prog: could not open file: `$fpem'\n");
    die ("$prog: input file `$fpem' is empty\n") if (-z FPEM);
    while ($rec = <FPEM>)
    {
        chomp ($rec);
        @col = split (',', $rec);

        next if (!defined ($col[4]));

        my ($ern, $exp) = ($col[2], $col[3]);
        my ($key, $s) = ("", join (' ', sort (split (' ', $col[4]))));

        $flag = 0;
        foreach $key (sort (keys (%tag)))
        {
            if (is_subset ($key, $s))
            {
                $tag{$key}[0] += $ern;
                $tag{$key}[1] += $exp;

                $flag = 1;
                last;
            }
            if (is_subset ($s, $key))
            {
               $ern += $tag{$key}[0];
               $exp += $tag{$key}[1];

               delete ($tag{$key});
            }
        }
        $tag{$s} = [ $ern, $exp ] if ($flag == 0);
    }
    close FPEM;

    my ($tern, $tspnt) = (0, 0);
    my $mn = strftime ("%B %Y", localtime ($col[0]));

    printf ("$spc"); ln ("-", 65);
    printf ("$spc|%-41s|%10s|", "    Tags/Categories of $mn", "Earned  ");
    printf ("%10s|\n", "Spent  ");
    printf ("$spc"); ln ("-", 65);
    foreach my $k (keys (%tag))
    {
        printf ("$spc|%-41s|%10.2f|", $k, $tag{$k}[0]);
        printf ("%10.2f|\n", $tag{$k}[1]);
        printf ("$spc"); ln ("-", 65);

        $tern += $tag{$k}[0];
        $tspnt += $tag{$k}[1];
    }
    printf ("$spc|%-41s|%10.2f|", "Total ", $tern);
    printf ("%10.2f|\n", $tspnt);
    printf ("$spc"); ln ("-", 65);
}


# is_subset ($a, $b): checks if $b is subset of $a; returns 1 if yes and 0
# if not.
#
sub is_subset
{
    my ($ret, $a, $b) = (1, $_[0], $_[1]);

    my @list = sort (split (' ', $b));

    foreach my $i (@list)
    {
        $i = quotemeta ($i);
        if (!($a =~ /$i/i))
        {
            $ret = 0;
            last;
        }
    }

    return $ret;
}


sub no_of_days
{
    my ($mn, $yr, $tsec) = (0, 0, shift (@_));
    my @mnd = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

    $mn = strftime ("%m", localtime ($tsec));
    if ($mn == 2)
    {
        $yr = strftime ("%Y", localtime ($tsec));
        return 29 if ($yr % 100 == 0 && $yr % 400 == 0) || ($yr % 4 == 0);
    }
    return $mnd[$mn - 1];
}
