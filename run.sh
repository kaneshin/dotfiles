#!/bin/sh
#
# File:        install.sh
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 17-Oct-2014.

PROGNAME=$(basename $0)
VERSION="0.1"

usage()
{
    echo "Usage: ./$PROGNAME install"
    echo "       ./$PROGNAME"
    echo "Options:"
    echo "    --version         print product version and exit"
    echo "    -h | -help        print this help message"
    echo
}

check()
{
    which $1 > /dev/null 2>&1
    if [ $? = 0 ]; then
        finish "$1 is already installed."
    fi
}

install()
{
    case $1 in
        'all')
            ;;
        'homebrew')
            check "brew"
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            ;;
        'tmux')
            bin_dir=~/local/bin
            src_dir=~/local/src
            dest=tmux-MacOSX-pasteboard
            bin=reattach-to-user-namespace
            mkdir -p $bin_dir $src_dir && cd $src_dir
            git clone https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard.git $dest && cd $dest
            make $bin
            ln -s $src_dir/$dest/$bin $bin_dir/$bin
            ;;
    esac
}

link()
{
    case $1 in
        'dotfiles')
            ;;
        'homebrew')
            for x in $(brew list -1);
            do
                brew unlink $x;
                brew link $x;
            done
            ;;
        'tmux')
            ;;
    esac
}

finish()
{
    echo $1
    exit 0
}

abort()
{
    echo $1 1>&2
    exit 1
}

# ==========

for OPT in $*
do
    case $OPT in
        'install')
            install $2
            break
            ;;
        'link')
            link $2
            break
            ;;
        '--version')
            finish $VERSION
            ;;
        '-h'|'--help')
            usage
            finish
            ;;
    esac
    shift
done

