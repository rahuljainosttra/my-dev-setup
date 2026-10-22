# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# werlevel10k/powerlevel10k"
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git
	docker
	docker-compose
	zsh-syntax-highlighting
	z
	kubectl
	zsh-vi-mode
        asdf)


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#export PATH="$PATH:/opt/nvim-linux64/bin/:/home/rahulj/.local/bin:/home/rahulj/.asdf:/home/rahulj/.asdf/installs/golang/1.24.2/packages/bin"
export PATH="$PATH:/home/rahulj/.local/bin"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source $ZSH/oh-my-zsh.sh

export GOOGLE_CLOUD_PROJECT="prj-c-platformtools-fn8z"
export NODE_EXTRA_CA_CERTS="/home/rahulj/cacerts/trioptima-ad-root-ca.crt"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# --- CA Certificate Configuration for Dev Tools ---
# # Most tools will use one of the variables below to trust your custom CA.
#
# # Generic variable for Go, Rust, .NET Core, and other tools
 export SSL_CERT_FILE="/home/rahulj/cacerts/cabundle.pem"
#
# # Node.js
 export NODE_EXTRA_CA_CERTS="/home/rahulj/cacerts/cabundle.pem"
#
# # cURL & Git
 export CURL_CA_BUNDLE="/home/rahulj/cacerts/cabundle.pem"
 export GIT_SSL_CAINFO="/home/rahulj/cacerts/cabundle.pem"
#
# # Python (Requests library, pip, uv)
 export REQUESTS_CA_BUNDLE="/home/rahulj/cacerts/cabundle.pem"
 export PIP_CERT="/home/rahulj/cacerts/cabundle.pem"
 export UV_CA_BUNDLE="/home/rahulj/cacerts/cabundle.pem"
#
export HTTPLIB2_CA_CERTS="/home/rahulj/cacerts/cabundle.pem"

# --- Dynamic Terminal Background Color for Kube Context ---
# Automatically changes terminal background when current context contains 'trisettle-prod'
_update_terminal_bg_for_kube_context() {
  local kube_context=""
  local config_file="${KUBECONFIG:-$HOME/.kube/config}"
  
  # Resolve the first file if KUBECONFIG contains a colon-separated list
  config_file="${config_file%%:*}"
  
  # Highly optimized: read the context from file directly to prevent prompt lag
  if [[ -f "$config_file" ]]; then
    kube_context=$(grep '^current-context:' "$config_file" | cut -d' ' -f2)
  else
    # Fallback if config doesn't exist
    kube_context=$(kubectl config current-context 2>/dev/null)
  fi

  # Check if the active context is the production context
  if [[ "$kube_context" == *"trisettle-prod"* ]]; then
    # Set background to a subtle dark warning red (Hex: #2d0000)
    printf "\e]11;#2d0000\a"
  else
    # Reset background color to terminal default
    printf "\e]111\a"
  fi
}

# Hook into Zsh precmd so this executes before every prompt rendering
autoload -Uz add-zsh-hook
add-zsh-hook precmd _update_terminal_bg_for_kube_context
export GITHUB_TOKEN=$(gh auth token)


# Added by Antigravity CLI installer
export PATH="/home/rahulj/.local/bin:$PATH"
