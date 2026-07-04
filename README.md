# dotfiles

Personal config managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory is a Stow package whose contents mirror the path they should have under `$HOME`
(e.g. `zsh/.zshrc` → `~/.zshrc`).

## Repository layout

```
dotfiles/
├── zsh/            stow package → ~/.zshrc, ~/.oh-my-zsh/custom (oh-my-zsh plugins as submodules)
├── aerospace/       stow package → ~/.config/aerospace/aerospace.toml (tiling WM config)
├── ssh/             stow package → ~/.ssh/config (config only, never private keys)
├── iterm2/          NOT a stow package — iTerm2 points its own "custom folder" setting here
├── Brewfile         `brew bundle` manifest — formulae, casks, taps
└── README.md        this file
```

Nothing in `~/.claude/` lives in this repo — see [Claude Code configuration](#claude-code-configuration)
for why, and what's worth copying by hand.

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
stow claude     # ~/.claude/CLAUDE.md, ~/.claude/rules/commit-workflow.md, ~/.claude/statusline-command.sh
```

`~/.oh-my-zsh` itself must already exist before `stow zsh` (install
[oh-my-zsh](https://ohmyz.sh/) first) — Stow only symlinks the `custom` subdirectory into it.
The zsh theme is `agnoster`; `plugins=(git zsh-autosuggestions zsh-syntax-highlighting)` in
`.zshrc`, with the last two vendored as git submodules under
`zsh/.oh-my-zsh/custom/plugins/`.

`~/.ssh` must already exist with correct permissions (`chmod 700 ~/.ssh`) before `stow ssh`.
This only manages `~/.ssh/config` — private keys are never stored in this repo (see Secrets
below).

`~/.claude` must already exist before `stow claude` (just run Claude Code once). Stow symlinks
`CLAUDE.md` directly, and — since `~/.claude/rules/` already exists as a real directory with
files Stow doesn't own (e.g. `context7.md`, kept local on purpose, see below) — it degrades to
symlinking individual files inside `rules/` (currently just `commit-workflow.md`) rather than
the whole directory. Everything else under `~/.claude/` (history, sessions, caches, auth) is
left alone. See [Claude Code configuration](#claude-code-configuration) for what belongs where.

To verify what's currently symlinked without changing anything: `stow -n -v <package>` (dry run).

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

Installs all brew formulae/casks captured in `Brewfile`. Regenerate this file after installing
something new with `brew bundle dump --file=Brewfile --force`. Only need a subset? Open
`Brewfile` and `brew install`/`cask install` the specific lines you want instead of running the
whole bundle.

To check the current machine against the Brewfile without installing anything:
`brew bundle check --file=Brewfile --no-upgrade --verbose` (the `--no-upgrade` flag matters —
without it, brew also flags every outdated-but-installed package as "needs installing").

On machines where the account isn't in the `admin` group (e.g. a managed corporate Mac), casks
fail because they can't copy `.app` bundles into `/Applications` (owned `root:admin`,
group-writable only by `admin`). `zsh/.zshrc` sets `HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"`
to redirect cask installs to `~/Applications` instead, which is user-writable — no admin rights
needed. This only affects casks; regular formulae are unaffected since `/opt/homebrew` is
already user-owned.

### Node.js via pnpm (optional)

Node/npm are **not** installed via Homebrew on this machine — installing them from Homebrew
(e.g. as a dependency of a cask/formula like `angular-cli`) would place a second `node`/`npm`
in `/opt/homebrew/bin`, which sits earlier on `PATH` than pnpm's bin dir and would silently
shadow the pnpm-managed one. Keep Node ownership single-sourced through pnpm:

```sh
curl -fsSL https://get.pnpm.io/install.sh | sh -
pnpm env use --global lts
```

This installs `pnpm` standalone, then has pnpm install and manage its own Node.js version.
`corepack` isn't needed — it exists to auto-switch package manager versions per-project (mainly
for npm/yarn); pnpm manages its own version directly (`pnpm self-update`).

Install global npm packages with `pnpm add -g <package>` instead of Homebrew, e.g.:

```sh
pnpm add -g typescript typescript-language-server
```

To sanity-check on an existing machine that nothing broke this: `which -a node` should list
pnpm's path (`~/Library/pnpm/node`) before `/opt/homebrew/bin/node` — if the Homebrew one comes
first, something (re)installed Node/a Node-dependent formula via brew and is shadowing pnpm.

### VS Code (optional)

Extensions and settings sync via VS Code's built-in **Settings Sync** (sign in with the same
account) — not managed by this repo.

### Claude Code configuration

Most of `~/.claude/` is **not** in this repo and never copied — it's mostly machine-local
session state (chat history, auth tokens, per-project caches). The `claude` Stow package
(`stow claude`, see above) carries only the plain, shareable config: `~/.claude/CLAUDE.md`, plus
individual files inside `~/.claude/rules/` (not the whole directory — some rule files are kept
local on purpose, see below).

**Global instructions:**
- `~/.claude/CLAUDE.md` — broad, always-relevant instructions applied to every project on this
  machine: communication style, general working principles. The kind of thing that's true
  regardless of what you're working on, so it earns a permanent spot in the one file every
  session reads.
- `~/.claude/rules/*.md` — one self-contained file per topic-scoped playbook, e.g. the exact
  steps for a commit-and-push workflow (`commit-workflow.md`, tracked in this repo). Kept out of
  `CLAUDE.md` and split one-topic-per-file so each can be added, edited, or dropped on its own
  without reshuffling the core file, and so a single rule can be reused or shared independently
  of the rest.
- Not every rule file belongs in this repo, though: `context7.md` stays local and untracked
  because that guidance is meant to be superseded by installing the actual context7 plugin
  rather than hand-written instructions — once a capability is installed as a plugin, document
  it under **Plugins & marketplaces** below instead of duplicating it as a rule.
- `~/.claude/statusline-command.sh` — the script `settings.json`'s `statusLine.command` points
  at (shows model, reasoning effort, git branch, context-window usage). Plain bash, no secrets
  or machine-specific paths, so it's tracked and stowed too.

**Settings — `~/.claude/settings.json`:**
Declarative machine config: default model and reasoning effort, hooks (e.g. a `PostToolUse`
hook that reminds about batching Chrome-automation tool calls), the statusline command, and
which plugins/marketplaces are enabled:

```json
"enabledPlugins": {
  "typescript-lsp@claude-plugins-official": true,
  "andrej-karpathy-skills@karpathy-skills": true,
  "feature-dev@claude-plugins-official": true,
  "frontend-design@claude-plugins-official": true,
  "skill-creator@claude-plugins-official": true
},
"extraKnownMarketplaces": {
  "karpathy-skills": { "source": { "source": "github", "repo": "forrestchang/andrej-karpathy-skills" } }
}
```
These two keys are the reproducible part — merging them into a fresh `settings.json` (after
adding the `karpathy-skills` marketplace) recreates the same plugin set on another machine.

**Plugins & marketplaces — `~/.claude/plugins/`:**
Two marketplaces are registered: `claude-plugins-official` (Anthropic's official one) and
`karpathy-skills` (`github.com/forrestchang/andrej-karpathy-skills`). Five plugins are enabled
from them at `scope: "user"` (global, not tied to one project) — see `enabledPlugins` above.
`~/.claude/plugins/marketplaces/` holds the actual cloned marketplace repos;
`installed_plugins.json` and `known_marketplaces.json` are Claude Code's own bookkeeping —
don't hand-edit, they're regenerated by `/plugin` commands.

**MCP servers:**
No MCP servers are registered globally — `mcpServers` in `~/.claude.json` is empty on this
machine. MCP is instead wired per-project via a `.mcp.json` file in that project's own repo
root, e.g.:
```json
{ "mcpServers": { "playwright": { "command": "npx", "args": ["@playwright/mcp@latest"] } } }
```
That file lives in and travels with the project repo, not here.

**Project-level Claude settings (concept, not present in this repo):**
Any project can have its own `.claude/settings.json` for permissions, hooks, and allowed tools
scoped to that repo — same shape as the global one, just project-local. Put shared config in
`.claude/settings.json` (tracked in git, ready to use on clone), not `settings.local.json`
(untracked, personal-only). This dotfiles repo doesn't currently have a project-level `.claude/`
— the point applies to other project repos. Separately, `~/.claude.json` keeps a `projects` map
with per-project state (trust-dialog acceptance, MCP enable/disable overrides, session stats) —
that's Claude Code's own bookkeeping, not something to author or copy.

**Never copy to a new machine or into this repo:**
`~/.claude/history.jsonl`, `sessions/`, `projects/`, `file-history/`, any `*cache*` file, and
`oauthAccount`/tokens inside `~/.claude.json` — all machine- and session-local, and regenerated
automatically. Re-authenticate (`claude login` equivalent) on the new machine instead.

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
