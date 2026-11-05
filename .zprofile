if [[ "$OSTYPE" == darwin* ]]; then
  # Retain existing Docker Desktop command discovery on macOS.
  export PATH="$PATH:$HOME/.docker/bin"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv zsh)"
  else
    print -ru2 -- "Homebrew was not found. Install it from https://brew.sh."
    return 1
  fi
else
  typeset -U path PATH
  path=("$HOME/.local/bin" $path)
  export PATH
fi
