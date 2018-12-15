# Cronscript.pm, Or How I Learned to Stop Worrying and Program the Evergreen Back End

This is the source repository for the slides and example programs from
Jason Stephenson's Evergreen 2019 Pre-Conference presentation on
learning to program the Evergeen ILS back end.  The presentation was
delivered at the 2019 Evergreen ILS International Conference in Valley
Forge, Pennsylvania on Wednesday, April 24, 2019 from 1:30 PM EDT to
4:30 PM EDT.

## Getting Started

You will find the raw asciidoc source of the slides in the `slides/`
subdirectory.  You probably do not need these as the latest, compiled
version of the presentation is in the file `presentation.html` in the
root of this repository.

The `examples/` subdirectory contains the full source code of the
example programs discussed in the presentation, except for those that
are part of Evergreen, itself.

### Prerequisites

You will need [asciidoc](http://asciidoc.org/) or
[asciidoctor](https://asciidoctor.org/) to build the presentation from
the source files.

You will need a working Evergreen installation to use the example
programs.

### Installing

The presentaion was built using asciidoc and the slidy backend:

```
asciidoc -b slidy -o presentation.html slides/main.adoc
```
## Author

**Jason Stephenson** - [Sigio](http://www.sigio.com/)

## License

The presentation is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).

The examples are licensed under the [GNU General Public License, Version 2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html) or, at your option, any later version.

