#!/usr/bin/perl

BEGIN{unshit @INC, "/path/to/"}
use warnings;
use strict;
use Getopts::Std;
use vars qw($opt_i $opt_o);
getopts
