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

use strict;
use warnings;

use OpenILS::Utils::Cronscript;
use Data::Dumper;

my $script = OpenILS::Utils::Cronscript->new({nolockfile=>1});

my $editor = $script->editor();

# Let's list all copy statuses:
print("All copy statues:\n");
print("------------------------------------------------------------------------\n");
my $ccs_list = $editor->retrieve_all_config_copy_status;
for (@$ccs_list) {
    print($_->id, ": ", $_->name, "\n");
}
print("------------------------------------------------------------------------\n\n");

# Look for the statuses that are not opac visible:
$ccs_list = $editor->search_config_copy_status({opac_visible=>'f'});
print("Not OPAC Visible:\n");
print("------------------------------------------------------------------------\n");
for (@$ccs_list) {
    print($_->id, ": ", $_->name, "\n");
}
print("------------------------------------------------------------------------\n\n");

# Get the ids of the not holdable statuses.
my $ccs_ids = $editor->search_config_copy_status({holdable=>'f'},{idlist=>1});
print("IDs of not holdable statuses:\n");
print("------------------------------------------------------------------------\n");
for (@$ccs_ids) {
    print("$_\n");
}
print("------------------------------------------------------------------------\n\n");

# Example of batch retrieve
$ccs_list = $editor->batch_retrieve_config_copy_status($ccs_ids);
print("Batch retrieved not holdable statuses:\n");
print("------------------------------------------------------------------------\n");
for (@$ccs_list) {
    print($_->id, ": ", $_->name, "\n");
}
print("------------------------------------------------------------------------\n\n");

# Next, we create a new copy status:
my $ccs = Fieldmapper::config::copy_status->new();
$ccs->name('Red Alert');
$ccs->holdable('f');
$ccs->opac_visible('f');
$ccs->copy_active('t');
$ccs->restrict_copy_delete('t');
$ccs->is_available('t');

# We need a transaction to create it in the database
$editor->xact_begin();
my $result_ccs = $editor->create_config_copy_status($ccs);
$editor->commit();

# Just to make sure it was successful.
print("Our new config.copy_status:\n");
print("------------------------------------------------------------------------\n");
print Dumper $result_ccs->to_bare_hash;
print("------------------------------------------------------------------------\n\n");
# Just to show what happens when we try to update without a
# transaction:
eval {
    $result_ccs->opac_visible('t');
    $result_ccs = $editor->update_config_copy_status($result_ccs);
};
if ($@) {
    print("We forgot the transaction:\n");
    print("------------------------------------------------------------------------\n");
    warn $@;
    print("------------------------------------------------------------------------\n\n");
    $result_ccs->opac_visible($ccs->opac_visible);
}

# Now, let's delete our new status.
eval {
    $editor->xact_begin;
    $result_ccs = $editor->delete_config_copy_status($result_ccs);
    $editor->commit;
};
if ($@) {
    print("Something went wrong:\n");
    print("------------------------------------------------------------------------\n");
    warn $@;
    print("------------------------------------------------------------------------\n\n");
} else {
    print("We deleted the new config.copy_status:\n");
    print("------------------------------------------------------------------------\n");
    print Dumper $result_ccs;
    print("------------------------------------------------------------------------\n");
}

