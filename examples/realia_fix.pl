#!/usr/bin/perl
# ---------------------------------------------------------------
# Copyright © 2014 Merrimack Valley Library Consortium
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

# This program was written to fix some MARC records that should have
# had a MARC type of r, but didn't.  It also added a hold matrix
# matchpoint entry to block holds on these types of items
# consortium-wide.  It was originally written for MVLC and has some
# hard-coded values, such as stat cat entry ids in it.  It is still an
# OK example of a more complex program that does multiple things.

# It was updated in 2019 based on things learned by the author and
# added to Cronscript since the orignal was written.

use strict;
use warnings;

use Data::Dumper;

use OpenILS::Utils::Cronscript;
use OpenILS::Utils::Normalize qw/clean_marc/;
use MARC::File::XML;
use MARC::Record;

my %defaults = (
    nolockfile => 1,
    'username=s' => '',
    'password=s' => '',
    'workstation=s' => ''
);

my $script = OpenILS::Utils::Cronscript->new(\%defaults);
my $opts = $script->MyGetOptions();
my $authtoken = $script->authenticate($opts)
    or die "What we have here is a failure to authenticate.";

END {
    # logout
    if ($authtoken) {
        $script->logout();
    }
}

create_hold_matrix_matchpoint();
my @bre_list = search_biblio_record_entry();
foreach (@bre_list) {
    update_biblio_record_entry($_);
}

# Creates a config.hold_matrix_matchpoint to prevent holds on copies
# with MARC type r.
sub create_hold_matrix_matchpoint {
    my $chmm = Fieldmapper::config::hold_matrix_matchpoint->new();
    $chmm->active('t');
    $chmm->usr_grp(1);
    $chmm->requestor_grp(1);
    $chmm->marc_type('r');
    $chmm->holdable('f');
    my $e = $script->editor(authtoken=>$authtoken,xact=>1);
    $e->create_config_hold_matrix_matchpoint($chmm)
        or die Dumper $e->event;
    $e->finish;
}

# Retrieves our bres and returns them in a list.
sub search_biblio_record_entry {
    my $q = {
        'select' => {'bre'=>['id']},
        'from' => {
            'bre' => {
                'mrd' => {
                    'fkey' => 'id', 'field' => 'record',
                    'filter' => {'item_type' => {'<>' => 'r'}}
                },
                'acn' => {
                    'join' => {
                        'acp' => {
                            'join' => {
                                'ascecm' => {
                                    'filter' => {'stat_cat_entry' => [421,422]}
                                }
                            }
                        }
                    }
                }
            }
        },
        'distinct'=>'true'
    };
    my $e = $script->editor(authtoken=>$authtoken);
    my $res = $e->json_query($q);
    die Dumper $e->event unless($res && @$res);
    my @bres = ();
    foreach my $r (@$res) {
        my $bre = $e->retrieve_biblio_record_entry($r->{'id'});
        push(@bres,$bre) if ($bre);
    }
    $e->finish;
    return @bres;
}

# Updates the biblio_record_entry's MARC to have marc type r and sets
# the editor to the logged in user.
sub update_biblio_record_entry {
    my $bre = shift;
    print("Updating bre: " . $bre->id . "\n");
    my $marc = MARC::Record->new_from_xml($bre->marc, 'UTF-8');
    my $leader = $marc->leader();
    $leader = substr($leader, 0, 6) . 'r' . substr($leader, 7);
    $marc->leader($leader);
    $bre->marc(clean_marc($marc));
    my $e = $script->editor(authtoken=>$authtoken,xact=>1);
    $bre->editor($e->requestor->id);
    $e->update_biblio_record_entry($bre);
    $e->finish;
}
