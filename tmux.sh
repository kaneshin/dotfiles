#!/bin/bash

# File:         tmux.sh
# Version:      1.0.0
# Maintainer:   Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change:  16-Jul-2013.

mkdir ~/local
mkdir ~/local/bin ~/local/src
cd ~/local/src
git clone https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard.git tmux-MacOSX-pasteboard
cd tmux-MacOSX-pasteboard
make reattach-to-user-namespace
ln -s ~/local/src/tmux-MacOSX-pasteboard/reattach-to-user-namespace ~/local/bin/reattach-to-user-namespace
