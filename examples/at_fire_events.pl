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

# This script can be used to rerun events that got "stuck" for some
# reason, for instance the action_trigger_runner.pl got hung up on a
# large event or something.  You pass in a bunch of event ids on
# standard input and it will fire them. Here's an example of a
# possible command line to fire off some hold is ready for pickup SMS
# events:
#
# psql -U evergreen -h $PGHOST -d $PGDATABASE -A -t \
# -c "select id from action_trigger.event where event_def = 101 and state = 'collected'" \
# | at_fire_events.pl
#
# If you were using this for real, you'd likely also use the add_time
# or similar date field to limit the event query.
#
# It uses the same lock file as the standard action_trigger_runner.pl
# from the crontab so that this script won't interfere with its
# operation and vice versa.

use strict;
use warnings;

use OpenILS::Utils::Cronscript;

my $script = OpenILS::Utils::Cronscript->new({'lock-file'=>'/tmp/action-triggger-LOCK'});

my $ses = $script->session('open-ils.trigger');

foreach my $event (<>) {
    chomp($event);
    print ("open-ils.trigger.event.fire $event\n");
    my $result = $ses->request('open-ils.trigger.event.fire', $event)->gather(1);
    print("Valid: " . $result->{valid} . "\n\n");
}
