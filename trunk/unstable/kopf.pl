#!/usr/bin/perl
#

use SL::Form;

eval { require "unternehmer.conf"; };

$form = new Form;

eval { require("$userspath/$form->{login}.conf"); };

$locale = new Locale "$myconfig{countrycode}", "kopf";

eval { require "bin/mozilla/kopf.pl"; };
