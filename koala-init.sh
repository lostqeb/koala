#!/bin/bash

USER_CONFIG_DIR="$HOME/.config/koala"
USER_CONFIG_FILE="$USER_CONFIG_DIR/config.conf"
DEFAULT_CONFIG="/usr/share/koala/config.conf"

mkdir -p "$USER_CONFIG_DIR"

if [ ! -f "$USER_CONFIG_FILE" ]; then
  if [ -f "$DEFAULT_CONFIG" ]; then
    cp "$DEFAULT_CONFIG" "$USER_CONFIG_FILE"
    echo "✅ Default config copied to $USER_CONFIG_FILE"
  else
    echo "❌ Default config not found at $DEFAULT_CONFIG"
    exit 1
  fi
fi

