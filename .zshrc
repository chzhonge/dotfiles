# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/deric/.oh-my-zsh
#export PATH="/usr/local/Cellar/git/:$PATH"
export PATH=/usr/local/bin:/Users/deric/.composer/vendor/bin:$PATH
export LC_ALL=en_US.UTF-8
#source $(brew --prefix php-version)/php-version.sh
#source $(brew --prefix php-version)/php-version.sh
# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="maran"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# https://github.com/lukechilds/zsh-nvm
plugins+=(zsh-nvm)

source $ZSH/oh-my-zsh.sh

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

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# alias mysql="/usr/local/mysql/bin/mysql"
 alias mysqladmin="/usr/local/mysql/bin/mysqladmin"
 alias mkl="make help | less"
 alias dk="docker"
# alias dka="docker rm $(docker ps -a -q)"
# alias dkrmi="docker rmi $(docker images -q)"
 alias sl='/usr/local/bin/sl'
 alias pa='php artisan'
 alias pam='php artisan maghead'
 alias pat='php artisan tinker'
 alias pmi='php artisan migrate:reset | php artisan migrate'
# alias pfix='php /usr/local/bin/php-cs-fixer fix'
# alias psysh="~/work/script/psysh"
 alias dc='cd'
# alias kbcgp='kubectl get pods'
# alias kbclog='kubectl log -f'
 alias gbrm='rm -rf _book'
 alias irc='mosh --ssh="ssh -p 222" irc.pixnet.tw'

 alias zsu="upgrade_oh_my_zsh"
 alias phpstorm="open -a PhpStorm"


# function dkrms() {
#     dk images | grep $1 | awk '{print $3}' | xargs -L 1 docker rmi
# }
 function gnf() {
     grep -rni $1 . | less
 }

 function gvim {
     vim -c "$(grep -n $1 $2 * | cut -d ':' -f1 -f2 | sed -e 's/\(.*\):\(.*\)/:tabe \1\|:\2/g' | tr '\n' '|')"
 }
# 如果有遇到檔案搬移又需要查搬移前的 log，可以在 `git log` 後面加 `--follow`


# this is call path
#export PATH="$(brew --prefix homebrew/core/php@7.0)/bin:$PATH"
#export PATH="$(brew --prefix homebrew/php/php71)/bin:$PATH"
#see http://mozy-ok.hatenablog.com/entry/2018/04/13/185313
#
#see https://github.com/creationix/nvm#install--update-script
#see https://stackoverflow.com/questions/28225045/no-such-keg-usr-local-cellar-git

#see https://medium.com/@myread02/nvm-%E5%88%87%E6%8F%9B-node-%E7%89%88%E6%9C%AC%E9%AC%BC%E6%89%93%E7%89%86%E5%95%8F%E9%A1%8C-9c24fe0c627b


export GREP_OPTIONS='--exclude-dir=\.git --exclude-dir=node_modules --exclude=bootstrap\.min\.js'


#see https://stackoverflow.com/questions/6565471/how-can-i-exclude-directories-from-grep-r
#is expanded by the shell (e.g. Bash), not by grep, into this:
# https://segmentfault.com/q/1010000002413409 cn
