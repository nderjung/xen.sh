#!/bin/bash -e
#
# Xen build & installation tool
#
# @author Alexander Jung <a.jung@lancs.ac.uk>
#

DIR=$(dirname $(readlink -f "$0"))
. "$DIR/common.sh"

_help() {
    cat <<EOF
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
EOF
}

# Default program parameters
WORKDIR=$DIR/.build
ARCH=x86_64
XEN_ROOT=$WORKDIR/xen
XEN_VERSION=4.11
HELP=n

# Parse arguments
for i in "$@"; do
    case $i in
        -w=*|--workdir=*)
            WORKDIR="${i#*=}"
            shift
            ;;
        --arch=*)
            ARCH="${i#*=}"
            shift
            ;;
        --xen-root=*)
            XEN_ROOT="${i#*=}"
            shift
            ;;
        --xen-version=*)
            XEN_VERSION="${i#*=}"
            shift
            ;;
        -h|--help)
            HELP=y
            shift
            ;;
        *)
            ;;
    esac
done

# Show help menu if requested
if [[ $HELP == 'y' ]]; then
    _help
    exit
fi

# Dependency management
_deps_apt() {
    _root_or_die

    local DISTRO=$(lsb_release -c -s)

    case $DISTRO in
        bionic|xenial)
            apt-get install -y --no-install-recommends \
                autoconf \
      install-info \
      build-essential \
      bcc \
      bin86 \
      gawk \
      bridge-utils \ 
      iproute \
      libcurl3 \
      libcurl4-openssl-dev \
      bzip2 \
      kmod \
      transfig \
      tgif \
      libpixman-1-0 \
      liblzma-dev \
      wget \
      libc6-dev-i386 \
      ca-certificates \
      texinfo \
      pciutils-dev \
      mercurial \
      make \
      gcc \
      libc6-dev \
      zlib1g-dev \
      python \
      python-dev \
      python-twisted \
      libncurses5-dev \
      patch \
      libvncserver-dev \
      libsdl-dev \
      libjpeg-dev \
      iasl \
      libbz2-dev \
      e2fslibs-dev \
      git-core \
      uuid-dev \
      ocaml \
      ocaml-findlib \
      libx11-dev \
      bison \
      flex \
      xz-utils \
      libyajl-dev \
      gettext \
      libpixman-1-dev \
      libaio-dev \
      markdown \
      pandoc curl
                
            ;;
        *)
            echo "This script is not yet compatible with $DISTRO"
            exit
            ;;
    esac
}

# Methods of source code acquisition
_download_xen() {
    _echo_bold "Getting Xen source..."
    
    if [[ ! -d $XEN_ROOT ]]; then
        git clone -b stable-$XEN_VERSION https://xenbits.xen.org/git-http/xen.git $XEN_ROOT
    else
        echo "Xen source already found in $XEN_ROOT"
    fi
}

# Methods for source code build
_build_xen() {
    _echo_bold "Building Xen..."

    cd $XEN_ROOT
    ./configure \
        --disable-docs
    make -j$(getconf _NPROCESSORS_ONLN) build
}

# Program interpretation
COMMAND=$1
shift
case "$COMMAND" in
    download)
        _download_xen
        ;;
    
    build)
        _download_xen
        _build_xen        
        ;;

    install)
        _download_xen
        _build_xen

        cd $XEN_ROOT
        make -j$(getconf _NPROCESSORS_ONLN) install

        ;;
    *)
        _help
        ;;
esac
