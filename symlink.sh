#!/bin/bash

# File:         symlink.sh
# Version:      1.0.0
# Maintainer:   Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change:  09-Nov-2012.

TARGET=$HOME
DOTFILESDIR=dotfiles/
SANDBOX=$HOME/tmp/sandbox

function create_dotfiles()
{
    # create dotfiles and dotdirectories into $1 (require)
    if [[ $1 == '' ]]; then
        return
    fi
    cd $DOTFILESDIR
    for dotfile in .?*; do
        if [[ $dotfile == '..' ]]; then
            # echo ".. is parent directory"
            continue
        elif [[ $dotfile == '.gitconfig' ]]; then
            continue
        elif [[ -f $dotfile ]]; then
            ln -sf $PWD/$dotfile $1
            suffix="@"
        elif [[ -d $dotfile ]]; then
            cp -fpR $PWD/$dotfile $1/
            suffix="/"
        fi
        echo "created $1/$dotfile$suffix"
    done
}

function remove_dotfiles()
{
    # remove dotfiles and dotdirectories from $1 (require)
    if [[ $1 == '' ]]; then
        return
    fi
    cd $DOTFILESDIR
    for dotfile in .?*; do
        if [[ $dotfile == '..' ]]; then
            continue
        elif [[ -f $dotfile ]]; then
            if [ -L $1/$dotfile ]; then
                rm -f $1/$dotfile
                suffix="@"
            fi
        elif [[ -d $dotfile ]]; then
            rm -rf $1/$dotfile/
            suffix="/"
        fi
        echo "removed $1/$dotfile$suffix"
    done
}

cd $(dirname ${0})
case $1 in
    make )
        create_dotfiles $TARGET
    ;;
    clean )
        remove_dotfiles $TARGET
    ;;
    # sandbox at $SANDBOX
    sandboxm )
        echo "run symlink.sh at sandbox"
        create_dotfiles $SANDBOX
    ;;
    sandboxc )
        remove_dotfiles $SANDBOX
    ;;
    * )
        echo "Require argument"
        echo "  make"
        echo "      create dotfile's symbolic link and directory into $TARGET"
        echo "  clean"
        echo "      remove dotfile's symbolic link and directory from $TARGET."
        echo ""
        echo "  sandbox at $SANDBOX"
        echo "      sandboxm - make"
        echo "      sandboxc - clean"
    ;;
esac
