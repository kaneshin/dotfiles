#!/bin/bash

cd $(dirname ${0})
for dotfile in .?*
do
    if [[ $dotfile != '..' ]] && [[ $dotfile != '.git' ]] && [[ $dotfile != '.gitignore' ]] && [[ $dotfile != '.doskey' ]]
    then
        ln -Fis "$PWD/$dotfile" ~/
    fi
done

# EOF
