#!/bin/bash -e
#
# Xen build & installation tool
#
# @author Alexander Jung <a.jung@lancs.ac.uk>
#

DIR=$(dirname $(readlink -f "$0"))

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

_echo_bold() {
    echo -e "\033[1m$1\033[0m"
}

_root_or_die() {
    if [[ $EUID -ne 0 ]]; then
        echo "Must be root! Aborting!"
        exit
    fi
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
                autoconf bcc bin86 bison bridge-utils build-essential bzip2 \
                ca-certificates curl e2fslibs-dev flex gawk gcc gettext \
                git-core iasl install-info iproute kmod libaio-dev libbz2-dev \
                \libc6-dev libc6-dev-i386 libcurl3 libcurl4-openssl-dev \
                \libjpeg-dev liblzma-dev libncurses5-dev libpixman-1-0 \
                libpixman-1-dev libsdl-dev libvncserver-dev libx11-dev \
                libyajl-dev make markdown mercurial ocaml ocaml-findlib pandoc \
                patch pciutils-dev python python-dev python-twisted texinfo \
                tgif transfig uuid-dev wget xz-utils zlib1g-de 
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
