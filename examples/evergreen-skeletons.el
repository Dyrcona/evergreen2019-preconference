;;; evergreen-skeletons.el --- Useful skeletons for Evergreen development

;; Copyright © 2019 Jason J.A. Stephenson

;; Author: Jason Stephenson <jason@sigio.com>
;; Created: 20 Apr 2019
;; Keywords: abbrev

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 2 of the License,
;; or (at your option) any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;;; Commentary:
;; A library of Emacs Skeletons that are useful in Evergreen
;; development and writing maintenance scripts.

;;; Code:
(define-skeleton evergreen-cronscript
  "Insert a basic skeleton for a Cronscript.pm-based Perl script."
  nil
  "#!/usr/bin/perl\n"
  "use strict;\n"
  "use warnings;\n"
  "use OpenILS::Utils::Cronscript;\n"
  @ _ ?\n
  "my $U = 'OpenILS::Application::AppUtils';\n\n"
  "my $script = OpenILS::Utils::Cronscript->new({nolockfile=>1});\n"
  @ _)

(define-skeleton evergreen-cronscript-auth
  "Insert a skeleton for a Conscript.pm-based Perl script that requires authentication."
  nil
  "#!/usr/bin/perl\n"
  "use strict;\n"
  "use warnings;\n"
  "use OpenILS::Utils::Cronscript;\n"
  @ _ ?\n
  "my $U = 'OpenILS::Application::AppUtils';\n\n"
  "my %defaults = (\n"
  > "'username=s' => '',\n"
  > "'password=s' => '',\n"
  > "'workstation=s' => '',\n"
  > "nolockfile => 1\n"
  ");\n\n"
  "my $script = OpenILS::Utils::Cronscript->new(\\%defaults);\n"
  @ _)

(define-skeleton evergreen-marcxml
  "Inserts use statements for MARC in Evergreen Perl scripts."
  nil
  > "use MARC::Record;\n"
  > "use MARC::File::XML;\n"
  > "use OpenILS::Utils::Normalize qw(clean_marc);")

(define-skeleton evergreen-database-update
  "Inserts boiler plate for an Evergreen database upgrade script."
  nil
  @ "BEGIN;\n\n--SELECT evergreen.upgrade_deps_block_check('XXXX', :eg_version);\n\n"
  @ _ ?\n?\n
    "COMMIT;\n")

(define-skeleton yaous-upsert
  "Create upsert block for actor.org_unit_setting."
  nil
  '(setq str (skeleton-read "Name of setting: ")
         v1 (skeleton-read "Org Unit ID: " "1")
         v2 (skeleton-read "Setting value: "))
  "INSERT INTO actor.org_unit_setting\n"
  "(org_unit, name, value)\n"
  "VALUES (" v1 ", '" str "', '" v2 "')\n"
  "ON CONFLICT ON CONSTRAINT ou_once_per_key\n"
  "DO UPDATE\n"
  "SET value = '" v2 "'\n"
  "WHERE org_unit_setting.org_unit = " v1 ?\n
  "AND org_unit_setting.name = '" str "';\n")

(define-skeleton postgresql-do
  "Create a skeleton for a PostgreSQL DO block."
  nil
  "DO\n"
  "$$\n"
  "DECLARE\n"
  @ _ | ("Enter variable name: " "    " str
  " " (skeleton-read "Enter variable type: ") ";\n")
  "BEGIN\n"
  @ _ | ?\n
  "END\n"
  "$$;")

(define-skeleton evergreen-dbi
  "Inserts a typical set of code to start a Perl DBI script for Evergreen."
  nil
  > "#!/usr/bin/perl\n\n"
  > "use strict;\n"
  > "use warnings;\n"
  > "use Getopt::Long;\n"
  > "use DBI;\n"
  > "use DBD::Pg;\n\n"
  > @ _ ?\n?\n
  > "# DBI options with defaults:\n"
  > "my $db_user = $ENV{PGUSER} || 'evergreen';\n"
  > "my $db_host = $ENV{PGHOST} || 'localhost';\n"
  > "my $db_db = $ENV{PGDATABASE} || 'evergreen';\n"
  > "my $db_password = $ENV{PGPASSWORD} || 'evergreen';\n"
  > "my $db_port = $ENV{PGPORT} || 5432;\n\n"
  > "GetOptions('user=s' => \\$db_user,\n"
  > "'host=s' => \\$db_host,\n"
  > "'db=s' => \\$db_db,\n"
  > "'password=s' => \\$db_password,\n"
  > "'port=i' => \\$db_port)\n"
  > "or die('Error in command line arguments');\n\n"
  > "my $dbh = DBI->connect(\"dbi:Pg:database=$db_db;host=$db_host;port=$db_port\",\n"
  > "$db_user, $db_password) or die('No database connection');\n\n"
  @ -)

(define-skeleton evergreen-psycopg2
  "Create a skeleton for a Python script to talk to Evergreen."
  nil
  "#!/usr/bin/env python3\n\n"
  "import argparse, psycopg2\n"
  @ _ | ?\n
  "parser = argparse.ArgumentParser()\n"
  "parser.add_argument('--user', default='evergreen')\n"
  "parser.add_argument('--host', default='localhost')\n"
  "parser.add_argument('--database', default='evergreen')\n"
  "parser.add_argument('--port', default=5432, type=int)\n"
  "parser.add_argument('--password', default='evergreen')\n"
  @ _ | ?\n
  "args = parser.parse_args()\n"
  @ _  | ?\n
  "with psycopg2.connect(host=args.host, port=args.port, user=args.user, password=args.password, dbname=args.database) as conn:\n"
  > "with conn.cursor() as cursor:\n"
  @ _)

(provide 'evergreen-skeletons)
