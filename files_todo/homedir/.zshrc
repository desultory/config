# ~/.zshrc

# Install oh-my-zsh if it's not installed
if [[ ! -d $HOME/.oh-my-zsh ]]; then
    echo "oh-my-zsh not found, press y to install"
    read key
    if [[ $key =~ ^[Yy]$ ]]; then
        echo "Installing oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "Skipping oh-my-zsh installation"
    fi
fi

#
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 7

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration
[ -d "$HOME/.local/bin" ] && [ `echo $PATH | grep -c "$HOME/.local/bin"` -eq 0 ] && PATH="$HOME/.local/bin:$PATH"

# https://github.com/romkatv/powerlevel10k#oh-my-zsh
if [ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    echo "Installed Powerline10k to ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    echo "Run source '$ZSH/oh-my-zsh.sh' to start configuration"
fi

gpgconf --launch gpg-agent
#export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

if [ -z "$SSH_AUTH_SOCK" ] && ! [ -e "$SSH_AUTH_SOCK" ] && ! [ -n "$SSH_CONNECTION" ]; then
    eval $(ssh-agent)
fi

# start weechat session in tmux
if [[ $(ps -ef | grep -c tmux) -eq 1 ]] || ([[ $(ps -ef | grep -c tmux) -ne 1 ]] && ! tmux has-session -t weechat) ; then
    echo "Starting weechat tmux session"
    tmux new-session -d -s weechat weechat
fi

# Start sway on TTY login
if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
    exec dbus-run-session sway > /tmp/sway.log 2> /tmp/sway.err
fi

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
zstyle :compinstall filename "${HOME}/.zshrc"

autoload -Uz compinit promptinit
compinit
ZSH_THEME="powerlevel10k/powerlevel10k"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
