#!/usr/bin/perl
# ---------------------------------------------------------------
# Copyright © 2019 Jason J.A. Stephenson <jason@sigio.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# ---------------------------------------------------------------

# A simple program to demonstrate AppUtils' simplereq and Cronscript's
# arguments.  How to checkin copies by barcode and how to pass
# authentication parameters via the command line.

# This script requires a username, password, and workstation passed in
# via the command line options: --username, --password, and
# --workstation, respectively.  It accepts a list of 1 or more copy
# barcodes from the remaining command line options and attempts to
# check each copy in, one at a time.  For each barcode, it prints the
# barcode, followed by the textcode from the checkin response.

use strict; use warnings;
use OpenILS::Utils::Cronscript;
my $U = 'OpenILS::Application::AppUtils';

my %defaults = (
    'username=s' => '',
    'password=s' => '',
    'workstation=s' => '',
    type => 'staff',
    nolockfile => 1
);

my $script = OpenILS::Utils::Cronscript->new(\%defaults);

# Retrieve the options passed in so we can authenticate with them:
my $opts = $script->MyGetOptions();

my $authtoken = $script->authenticate($opts) || die 'No session';

for my $barcode (@ARGV) {
    my $r = $U->simplereq(
        'open-ils.circ',
        'open-ils.circ.checkin.override',
        $authtoken,
        {
            barcode => $barcode,
            noop => 1,
            override_args => {events => ['COPY_ALERT_MESSAGE']}
        }
    );
    if (ref($r)) {
        print("$barcode: " . $r->{textcode} . "\n");
    }
}

END {
    $script->logout() if ($script->authtoken);
}
