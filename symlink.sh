#!/bin/bash

cd $(dirname ${0})
SANDBOX=$HOME/Dropbox/dev/sandbox
TARGET=$HOME
case $1 in
    make )
        cd dotfiles/
        for dotfile in .?*; do
            if [ -f $dotfile ]; then
                ln -sf $PWD/$dotfile $TARGET
                echo "created $TARGET/$dotfile@ as a symbolic link."
            elif [ $dotfile = '..' ]; then
                echo "parent directory"
            elif [ -d $dotfile ]; then
                cp -fpr $PWD/$dotfile $TARGET/
                echo "copy $TARGET/$dotfile"
            fi
        done
    ;;
    rm )
        cd $TARGET
        for dotfile in .?*; do
            if [ -L $dotfile ]; then
                rm -f $PWD/$dotfile
                echo "removed $TARGET/$dotfile@."
            fi
        done
    ;;
    test )
        echo "test"
    ;;
    * )
        echo "Require argument"
        echo "  make"
        echo "      create symbolic link and copy directory from dotfiles/."
        echo "  rm"
        echo "      remove symbolic link in $TARGET."
    ;;
esac

