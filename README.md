# `xen.sh`

A do-it-yourself script that downloads, builds and installs [Xen](https://xenproject.org/) from source.

## Usage

```
xen.sh - Xen build & installation tool

Usage:
  xen.sh [OPTIONS] download     Get program sources
  xen.sh [OPTIONS] build        Get program sources and build
  xen.sh [OPTIONS] install      Get program sources, build and install

Options:
  -h --help          Show this help menu
  -w --workdir       Place temporary build files into this working directory
                       (default is ./.build)
  --arch             Build for this architecture
  --xen-root         Use an existing Xen source code.  If the directory is empty,
                       Xen source will be saved here.
  --xen-version      Checkout this version of Xen

Some influential environment variables:
  CC        C compiler command
  CFLAGS    C compiler flags
  LDFLAGS   linker flags, e.g. -L<lib dir> if you have libraries in a
            nonstandard directory <lib dir>
  LIBS      libraries to pass to the linker, e.g. -l<library>
  CPPFLAGS  (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
            you have headers in a nonstandard directory <include dir>
  CPP       C preprocessor
  CXX       C++ compiler command
  CXXFLAGS  C++ compiler flags
  CXXCPP    C++ preprocessor
  XENFLAGS  Additional Xen configuration flags

Help:
  For help using this tool, please open an issue on the GitHub repository:
  https://github.com/nderjung/xen.sh
```