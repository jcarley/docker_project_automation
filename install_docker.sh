#!/usr/bin/env bash

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

fancy_echo() {
  printf "\n%b\n" "$1"
}

brew_install_or_upgrade() {
  if brew_is_installed "$1"; then
    if brew_is_upgradable "$1"; then
      brew upgrade "$@"
    fi
  else
    brew install "$@"
  fi
}

brew_is_installed() {
  local NAME=$(brew_expand_alias "$1")

  brew list -1 | grep -Fqx "$NAME"
}

brew_is_upgradable() {
  local NAME=$(brew_expand_alias "$1")

  local INSTALLED=$(brew ls --versions "$NAME" | awk '{print $NF}')
  local LATEST=$(brew info "$NAME" 2>/dev/null | head -1 | awk '{gsub(/,/, ""); print $3}')

  [ "$INSTALLED" != "$LATEST" ]
}

brew_expand_alias() {
  brew info "$1" 2>/dev/null | head -1 | awk '{gsub(/:/, ""); print $1}'
}

if ! command -v brew &>/dev/null; then
  fancy_echo "Installing Homebrew, a good OS X package manager ..."
    ruby <(curl -fsS https://raw.githubusercontent.com/Homebrew/homebrew/go/install)

  if ! grep -qs "recommended by brew doctor" ~/.zshrc.local; then
    fancy_echo "Put Homebrew location earlier in PATH ..."
      printf '\n# recommended by brew doctor\n' >> ~/.zshrc.local
      printf 'export PATH="/usr/local/bin:$PATH"\n' >> ~/.zshrc.local
      export PATH="/usr/local/bin:$PATH"
  fi
else
  fancy_echo "Homebrew already installed. Skipping ..."
fi

fancy_echo "Updating Homebrew formulas ..."
  brew update

fancy_echo "Installing Docker ..."
  brew_install_or_upgrade 'docker'

fancy_echo "Installing Docker-Compose ..."
  brew_install_or_upgrade 'docker-compose'

fancy_echo "Installing Docker-Machine ..."
  brew_install_or_upgrade 'docker-machine'

