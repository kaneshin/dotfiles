#!/bin/bash

# File:         symlink.sh
# Version:      1.0.0
# Maintainer:   Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change:  18-Nov-2012.

TARGET=$HOME
DOTFILESDIR=dotfiles/
SANDBOX=$HOME/tmp/sandbox
IGNOREFILES=('..' '.gitconfig' '.hgrc')

function create_dotfiles()
{
    # create dotfiles and dotdirectories into $1 (require)
    if [[ $1 == '' ]]; then
        return
    fi
    cd $DOTFILESDIR
    if [[ $all_flag == 1 ]]; then
        ignore_len=1
    else
        ignore_len=${#IGNOREFILES[@]}
    fi
    for dotfile in .?*; do
        # check ignored files
        for (( i = 0; i < $ignore_len; i++ ))
        do
            ignore_flag=1
            if [[ $dotfile == ${IGNOREFILES[$i]} ]]; then
                ignore_flag=0
                break
            fi
        done
        if [[ $ignore_flag == 1 ]]; then
            if [[ -f $dotfile ]]; then
                ln -sf $PWD/$dotfile $1
                suffix="@"
            elif [[ -d $dotfile ]]; then
                cp -fpR $PWD/$dotfile $1/
                suffix="/"
            fi
            echo "created $1/$dotfile$suffix"
        fi
    done
}

function remove_dotfiles()
{
    # remove dotfiles and dotdirectories from $1 (require)
    if [[ $1 == '' ]]; then
        return
    fi
    cd $DOTFILESDIR
    if [[ $all_flag == 1 ]]; then
        ignore_len=1
    else
        ignore_len=${#IGNOREFILES[@]}
    fi
    for dotfile in .?*; do
        # check ignored files
        for (( i = 0; i < $ignore_len; i++ ))
        do
            ignore_flag=1
            if [[ $dotfile == ${IGNOREFILES[$i]} ]]; then
                ignore_flag=0
                break
            fi
        done
        if [[ $ignore_flag == 1 ]]; then
            if [[ -f $dotfile ]]; then
                if [ -L $1/$dotfile ]; then
                    rm -f $1/$dotfile
                    suffix="@"
                fi
            elif [[ -d $dotfile ]]; then
                rm -rf $1/$dotfile/
                suffix="/"
            fi
            echo "removed $1/$dotfile$suffix"
        fi
    done
}

cd $(dirname ${0})
if [[ $2 == '--all' ]]; then
    all_flag=1
fi
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
