#!/bin/sh
set -e

REPO="pdasilem/uniam"
BINARY="uniam"

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Linux)  OS="linux" ;;
  Darwin) OS="darwin" ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

# Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)          ARCH="amd64" ;;
  aarch64 | arm64) ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Get latest release version
echo "Fetching latest release..."
VERSION="$(curl -sSf "https://api.github.com/repos/$REPO/releases/latest" \
  | grep '"tag_name"' \
  | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')"

if [ -z "$VERSION" ]; then
  echo "Failed to fetch latest version"
  exit 1
fi

FILENAME="${BINARY}-${OS}-${ARCH}"
URL="https://github.com/${REPO}/releases/download/${VERSION}/${FILENAME}"

echo "Downloading uniam ${VERSION} for ${OS}/${ARCH}..."
TMP="$(mktemp)"
curl -sSfL "$URL" -o "$TMP"
chmod +x "$TMP"

# Try to install to /usr/local/bin (system-wide, may need sudo)
install_system() {
  if mv "$TMP" "/usr/local/bin/$BINARY" 2>/dev/null; then
    echo "Installed to /usr/local/bin/$BINARY"
    return 0
  fi
  echo "No write access to /usr/local/bin. Trying with sudo..."
  if sudo mv "$TMP" "/usr/local/bin/$BINARY"; then
    echo "Installed to /usr/local/bin/$BINARY"
    return 0
  fi
  return 1
}

# Fallback to ~/.local/bin (no sudo needed)
install_user() {
  LOCAL_BIN="$HOME/.local/bin"
  mkdir -p "$LOCAL_BIN"
  mv "$TMP" "$LOCAL_BIN/$BINARY"
  echo "Installed to $LOCAL_BIN/$BINARY"

  # Check if ~/.local/bin is in PATH
  case ":$PATH:" in
    *":$LOCAL_BIN:"*) ;;  # already in PATH
    *)
      echo ""
      echo "Note: $LOCAL_BIN is not in your PATH."

      # Detect shell profile
      PROFILE=""
      case "$SHELL" in
        */zsh)  PROFILE="$HOME/.zshrc" ;;
        */bash) PROFILE="$HOME/.bashrc" ;;
        *)      PROFILE="$HOME/.profile" ;;
      esac

      LINE="export PATH=\"\$HOME/.local/bin:\$PATH\""
      if ! grep -qF "$LINE" "$PROFILE" 2>/dev/null; then
        echo "$LINE" >> "$PROFILE"
        echo "Added to $PROFILE."
      fi
      echo "Run: source $PROFILE  (or restart your terminal)"
      ;;
  esac
}

if ! install_system; then
  echo "Falling back to user installation..."
  install_user
fi

echo ""
echo "Verifying installation..."
"$BINARY" version || true
echo ""
echo "Done! Run 'uniam init' to get started."
