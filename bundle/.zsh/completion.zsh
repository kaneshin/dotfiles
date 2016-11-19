# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 19-Nov-2016.

shellname=$(basename $SHELL)

# setup goenv
if [ -n "$GOENV_ROOT" ]; then
  if [ -f "$GOENV_ROOT/completions/goenv.$shellname" ]; then
    source "$GOENV_ROOT/completions/goenv.$shellname"
  fi
fi

# setup gcloud
if [ -n "$CLOUDSDK_ROOT" ]; then
  # The next line updates PATH for the Google Cloud SDK.
  if [ -f "$CLOUDSDK_ROOT/path.$shellname.inc" ]; then
    source "$CLOUDSDK_ROOT/path.$shellname.inc"
  fi
  # The next line enables shell command completion for gcloud.
  if [ -f "$CLOUDSDK_ROOT/completion.$shellname.inc" ]; then
    source "$CLOUDSDK_ROOT/completion.$shellname.inc"
  fi
fi
