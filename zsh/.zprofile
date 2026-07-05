# Login-shell PATH setup. This runs after /etc/zprofile's path_helper, which
# rebuilds PATH from /etc/paths + /etc/paths.d/* and puts it *ahead* of
# whatever PATH already held (see ~/.zshenv note below) — so this is the
# right place for PATH entries that need to win, in the order they should win.
# Order below is deliberate: later blocks prepend further to the front, so
# they take precedence over earlier ones. Every entry is dedup-guarded so
# nested/re-entrant login shells (tmux, `exec zsh -l`, etc.) don't keep
# growing PATH.

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# uv
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# cargo / rustup
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# pnpm — must precede Homebrew's bin dir, otherwise a Homebrew-installed
# node/npm (e.g. as a cask dependency) would shadow the pnpm-managed one.
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Android SDK platform-tools
export ANDROID_HOME="$HOME/Library/Android/sdk"
case ":$PATH:" in
  *":$ANDROID_HOME/platform-tools:"*) ;;
  *) export PATH="$PATH:$ANDROID_HOME/platform-tools" ;;
esac

# Antigravity
case ":$PATH:" in
  *":$HOME/.antigravity/antigravity/bin:"*) ;;
  *) export PATH="$PATH:$HOME/.antigravity/antigravity/bin" ;;
esac

# VS Code
case ":$PATH:" in
  *":/Applications/Visual Studio Code.app/Contents/Resources/app/bin:"*) ;;
  *) export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ;;
esac

# JetBrains Toolbox
case ":$PATH:" in
  *":$HOME/Library/Application Support/JetBrains/Toolbox/scripts:"*) ;;
  *) export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts" ;;
esac

# Python 3.12 (python.org installer) — kept frontmost to match prior behavior.
case ":$PATH:" in
  *":/Library/Frameworks/Python.framework/Versions/3.12/bin:"*) ;;
  *) export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:$PATH" ;;
esac
