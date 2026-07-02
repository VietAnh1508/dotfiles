# dotfiles

Personal config managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory is a Stow package whose contents mirror the path they should have under `$HOME`
(e.g. `zsh/.zshrc` → `~/.zshrc`).

## Setting up a new machine

Each component below is independent — set up whichever ones this machine needs, in any
order, and skip the rest. None of them depend on each other except the prerequisites.

### Prerequisites

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install stow
git clone --recurse-submodules git@github.com:VietAnh1508/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

If already cloned without `--recurse-submodules`, run `git submodule update --init`.

### Stow packages — pick whichever apply

Run only the ones you want on this machine — each is independent:

```sh
stow aerospace  # ~/.config/aerospace
stow zsh        # ~/.zshrc, ~/.oh-my-zsh/custom
stow ssh        # ~/.ssh/config
```

`~/.oh-my-zsh` itself must already exist before `stow zsh` (install
[oh-my-zsh](https://ohmyz.sh/) first) — Stow only symlinks the `custom` subdirectory into it.

`~/.ssh` must already exist with correct permissions (`chmod 700 ~/.ssh`) before `stow ssh`.
This only manages `~/.ssh/config` — private keys are never stored in this repo (see Secrets
below).

### iTerm2 (optional)

Not managed by Stow. In iTerm2: **Preferences → General → Preferences** → check
"Load preferences from a custom folder or URL" and point it at `~/dotfiles/iterm2`, then
"Save changes to folder when iTerm2 quits".

The profile's font is **Source Code Pro for Powerline** (`cask "font-source-code-pro-for-powerline"`
in the Brewfile below). Install it before pointing iTerm2 at this profile, otherwise it
silently falls back to a system font instead of the powerline glyphs the `agnoster` zsh theme
needs.

### Homebrew packages (optional)

```sh
brew bundle install --file=Brewfile
```

Installs all brew formulae/casks and the npm globals (`typescript`,
`typescript-language-server`, `corepack`) captured in `Brewfile`. Regenerate this file after
installing something new with `brew bundle dump --file=Brewfile --force`. Only need a subset?
Open `Brewfile` and `brew install`/`cask install` the specific lines you want instead of
running the whole bundle.

### VS Code (optional)

Extensions and settings sync via VS Code's built-in **Settings Sync** (sign in with the same
account) — not managed by this repo.

### Claude Code config (optional)

`~/.claude/` is not in this repo. Transfer manually (e.g. AirDrop) if needed — it can contain
machine-specific state and session data that shouldn't go in git.

### Secrets (not in this repo)

None of the following are tracked here — the repo is public. Transfer these separately,
directly between machines (AirDrop, an encrypted USB drive, or a password manager), never via
git:

- SSH private keys (`~/.ssh/github_vlu`, etc.) and `known_hosts`
- GPG keys, if used for commit signing
- CLI auth/tokens: `gh auth login`, `aws configure`, `gcloud auth login`, `az login` — easiest
  to just re-authenticate on the new machine rather than copy credential files
- `~/.gitconfig` — intentionally not tracked here since it contains a work email; copy or
  recreate it manually on the new machine

### Not transferred (informational only)

- Colima — `~/.ssh/config` previously included `~/.colima/ssh_config`; that line was dropped
  since Colima isn't being set up on the new machine. If that changes, re-add the include
  after Colima has been started at least once (it generates that file itself).

