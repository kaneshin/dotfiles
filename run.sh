#!/bin/sh
# vim:set ts=8 sts=2 sw=2 tw=0:
#
# File:        run.sh
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 21-Dec-2014.
# ============================================================

PROGNAME=$(basename $0)
VERSION="0.1"

DEST=$HOME
DOTFILESDIR=dotfiles/

usage()
{
  echo "Usage: ./$PROGNAME link"
  echo "           create symbolic links of dotfiles and directories into $DEST"
  echo "       ./$PROGNAME unlink"
  echo "           delete symbolic links of dotfiles and directories from $DEST"
  echo "       ./$PROGNAME version"
  echo "           print the script version and exit"
  echo "       ./$PROGNAME help"
  echo "           print this help message"
}

_link()
{
  case $1 in
    'dotfiles')
      _install $DEST
      ;;
    'homebrew')
      brew=`which brew 2>&1`
      if [ -x $brew ]; then
        for x in $(brew list -1);
        do
          $brew unlink $x;
          $brew link $x;
        done
      fi
      ;;
  esac
}

_unlink()
{
  echo "Unlink"
}

_install()
{
  [ $1 -eq "" ] && return
  cd $DOTFILESDIR
  for dotfile in .?*; do
    ln -sf $PWD/$dotfile $1/$dotfile
    echo "created $1/$dotfile@"
  done
}

cd $(dirname ${0})
case $1 in
  'link')
    _link $2
    ;;
  'unlink')
    _unlink $2
    ;;
  'version')
    echo $VERSION
    ;;
  'help')
    usage
    ;;
  *)
    usage
    ;;
esac

