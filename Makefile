# ---------------------------------------------------------------
# Copyright © 2018 Jason J.A. Stephenson <jason@sigio.com>
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

# A little Makefile to ease testing and generation of the slides
# and/or HTML README.

presentation:
	asciidoc -f asciidoc.conf -b slidy -o presentation.html slides/main.adoc

README:
	markdown README.md > README.html
