#!/bin/bash

cd $(dirname ${0})
for dotfile in .?*; do
    case "$dotfile" in
        ".." )
            continue ;;
        \.git* )
            continue ;;
        ".doskey" )
            continue ;;
        * )
            ln -Fis "$PWD/$dotfile" $HOME ;;
    esac
done

