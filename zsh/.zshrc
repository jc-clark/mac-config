# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="fwalch"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time

plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

###### custom stuff below #########

# Aliases

## zsh
### zsh redo the last command with sudo
alias ffs='sudo $(fc -ln -1)'
### open zshrc file
alias zshconfig="open -e ~/.zshrc"

### Brew
alias bi='brew install'
alias br='brew uninstall'
alias bupd='brew update'
alias bupg='brew upgrade'

### Git
alias g='git'
alias gfu='git fetch upstream'
alias gfo='git fetch origin'
alias gp='git pull'
alias gs='git status'
alias gc='git checkout'
alias gl="git log --pretty=format:'%Cblue%h%Creset%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an%Creset' --abbrev-commit --date=relative"
alias gnb='git checkout -b'
alias gcomam='git add -A && git commit -m'
alias gcommend='git add -A && git commit --amend --no-edit'
alias gm='git merge'
alias gcp='git cherry-pick'

### Directory
alias cdr='cd ~/Repos/'
alias cddi='cd ~/Repos/docs-internal'
alias cdcs='cd ~/Repos/docs-strategy'

####### git functions ########

### Function to make sure I don't push to the default remote branch unless I really mean to 🤦‍♂️
gpoh() {
  local CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  local DEFAULT_BRANCH="main"

  # check we're not on the default branch
  if [[ $CURRENT_BRANCH == $DEFAULT_BRANCH ]]; then
    print -P "$lcicon_warning$lcicon_warning $FG[009]WARNING: You're about to push to the default branch ($DEFAULT_BRANCH)!$reset_color $lcicon_warning$lcicon_warning"
    vared -p "$lcicon_question Are you sure you want to continue? [y/N] " -c response
    if ! [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
    then
      print -P "$lcicon_fail Cancelled. Nothing was done."
      return 1
    fi
  fi
  git push origin HEAD --set-upstream

#### For GitHub: e.g gcpr 12345.
#### Requires GitHub CLI: https://github.com/cli/cli
gcpr() { gh pr checkout $1; }

# Checkout the default branch
# gcm() { gc $(git_default_branch) } 
