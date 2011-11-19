#!/bin/bash

DOTDIR=~/dotfiles
cd $DOTDIR
for dotfile in .?*
do
    if [[ $dotfile != '..' ]] 
        && [[ $dotfile != '.git' ]] 
        && [[ $dotfile != '.gitignore' ]]
        && [[ $dotfile != '.doskey' ]]
    then
        ln -Fis "$DOTDIR/$dotfile" ~/
    fi
done

# EOF
