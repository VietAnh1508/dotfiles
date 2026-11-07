source ~/.oh-my-zsh.zsh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Loads work-specific env vars/secrets kept out of this repo — see README.
for config (~/.zsh/*.zsh(N)) source $config

# export PATH="$PATH:$HOME/.jenv/bin"
# eval "$(jenv init -)"

# Load Angular CLI autocompletion.
# source <(ng completion script)

# Homebrew Cask: install apps to ~/Applications instead of /Applications.
# Needed on machines where the account isn't in the admin group and can't
# write to /Applications (root:admin, group-writable).
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"

ENABLE_LSP_TOOL=1