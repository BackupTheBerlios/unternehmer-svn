#!/usr/bin/perl

opendir ODIR, "../templates/";
@all = grep !/^\.\.?$/, readdir ODIR;
closedir ODIR;

@all = grep /Deutsch/, @all;

open FILE, ">>./teo1";

foreach (@all) {
	$str = substr($_, 7);
	$str1 = "svn rm ../templates/German"."$str";
	print FILE "$str1\n";
	print "$str1\n";
}
close(FILE);
