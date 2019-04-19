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

# A not so simple program to demonstrate AppUtils' simplereq and
# Cronscript's arguments.  How to apply payments by patron barcode and
# how to pass authentication parameters via the command line.

# This script requires a username, password, and workstation passed in
# via the command line options: --username, --password, and
# --workstation, respectively.  It accepts a list of 1 or more patron
# barcodes from the remaining command line options.  It then looks up
# that patron's bills, and if any are found, it applies forgive
# payments to them.

use strict;
use warnings;

use OpenILS::Utils::Cronscript;
use Data::Dumper;

my $U = 'OpenILS::Application::AppUtils';

my %defaults = (
    'username=s' => '',
    'password=s' => '',
    'workstation=s' => '',
    nolockfile => 1
);

my $script = OpenILS::Utils::Cronscript->new(\%defaults);

# Retrieve the options passed in so we can authenticate with them:
my $opts = $script->MyGetOptions();

my $authtoken = $script->authenticate($opts) || die 'No session';

END {
    $script->logout();
}

for my $barcode (@ARGV) {
    my ($user, $event) = $U->fetch_user_by_barcode($barcode);
    if (!$user && $event) {
        print Dumper $event;
    } else {
        my $bills = $U->simplereq(
            'open-ils.actor',
            'open-ils.actor.user.transactions.history.have_balance',
            $authtoken,
            $user->id
        );

        if (ref($bills) eq 'ARRAY') {
            my @payments = ();
            foreach my $bill (@$bills) {
                printf("\t%d : %.2f\n", $bill->id, $bill->balance_owed);
                push(@payments, [$bill->id, $bill->balance_owed])
                    if ($bill->balance_owed > 0.0);
            }
            if (@payments) {
                my $r = forgive_bills($user, \@payments);
                print Dumper $r;
            }
        } else {
            print Dumper $bills;
        }
    }
}

sub forgive_bills {
    my $user = shift;
    my $paymentref = shift;

    my $result = $U->simplereq(
        'open-ils.circ',
        'open-ils.circ.money.payment',
        $authtoken,
        {
            payment_type => "forgive_payment",
            userid => $user->id,
            note => "Forgiven en masse: forgive_bills.pl",
            payments => $paymentref
        },
        $user->last_xact_id
    );
    return $result;
}
