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

# This is a Perl example of the srfsh script of the same
# name/functionality.  This script will purge pending users from the
# staging tables.

use strict;
use warnings;

use OpenSRF::System;
use OpenSRF::AppSession;

# We have to bootstrap our client with the opensrf_core.xml configuration.
OpenSRF::System->bootstrap_client(config_file=>"/openils/conf/opensrf_core.xml");

# Create a session and connect in one call.  We need to be connected to use a transaction.
my $session = OpenSRF::AppSession->connect('open-ils.cstore');
# Create a database transation or die.
$session->request('open-ils.cstore.transaction.begin')->gather(1)
    || die("Cannot create transaction!");
# Run the staging.purge_pending_users database function.
$session->request('open-ils.cstore.json_query', {"from"=>["staging.purge_pending_users"]})->gather(1)
    || die("Failed to execute query!");
# Commit our transaction.
$session->request('open-ils.cstore.transaction.commit')->gather(1)
    || die("Failed to commit transaction!");
# Disconnect from cstore to free up the drone before the timeout does it for us.
$session->disconnect();
