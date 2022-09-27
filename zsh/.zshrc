# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"


# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

###### custom stuff below #########


# Set path for the cheat command config (https://github.com/cheat/cheat)
export CHEAT_CONFIG_PATH="$ZSH_SCRIPTS_DIR/miscdotfiles/cheat/conf.yml"
# Cheat autocompletion:
_cmpl_cheat() {
  reply=($(cheat -l | cut -d' ' -f1))
}
compctl -K _cmpl_cheat cheat


# Aliases

## Regular aliases
### zsh sudo last command:
alias ffs='sudo $(fc -ln -1)'
### Brew aliases
alias bi='brew install'
alias br='brew uninstall'
alias bupd='brew update'
alias bupg='brew upgrade'
### Git aliases
alias g='git'
alias gfu='git fetch upstream'
alias gfo='git fetch origin'
alias gr='git rebase'
alias gpull='git pull'
alias gs='git status'
alias gc='git checkout'
alias gl="git log --pretty=format:'%Cblue%h%Creset%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an%Creset' --abbrev-commit --date=relative"
alias gbranches='git branch -a'
alias gnb='git checkout -b'
alias gnewbranch='git checkout -b'
alias grenamebranch='git branch -m'
alias grmbranch='git branch -d'
alias gd='git diff'
alias gss='git stash save'
alias gsp='git stash pop'
alias gsd='git stash drop'
alias gsl='git stash list'
alias ga='git add'
alias gaa='git add -A'
alias gcom='git commit'
alias gcomm='git commit -m'
alias gcomam='git add -A && git commit -m'
alias gcoma='git add -A && git commit'
alias gcommend='git add -A && git commit --amend --no-edit'
alias gm='git merge'
alias gcp='git cherry-pick'
# alias gpoh='git push origin HEAD'
## See the gpoh function instead
alias gremotes='git remote -v'
alias gsub='git submodule'
alias gsubupd='git submodule update --remote --merge'
### Directory aliases
alias cdr='cd ~/Repos/'
alias cdd='cd ~/Repos/docs-internal'
alias cdo='cd ~/Repos/docs'
alias cdcs='cd ~/Repos/docs-strategy'
alias cdg='cd ~/Repos/github'



####### git functions ########

### Internal functon to get the name of the default branch. This is necessary especially for the master -> main transition, where we can't assume the default branch is master.
git_default_branch () {
  local REMOTE=$LUCAS_GIT_REMOTE
  local DEFAULT_BRANCH
  # Array of common default branch names
  local default_git_branches=("main" "master" "default" "develop")
  # Let's try to assume the default branch without needing a slow call to a remote.
  # Iterate through the list; if only one of the common default branches in the list exists on the remote, let's assume it is the default branch.
  local matches=0
  for i in "${default_git_branches[@]}"; do
    # If there is a match, save that as the branch and increment the number of matches found
    if git show-ref --quiet refs/remotes/$REMOTE/$i; then
      DEFAULT_BRANCH=$i
      let "matches++"
    fi
  done
  # If the number of matches found is not exatly one, something is not right and a call to the remote is needed.
  if (($matches != 1)); then
    # From: https://stackoverflow.com/questions/28666357/git-how-to-get-default-branch/44750379#comment92366240_50056710
    DEFAULT_BRANCH=$(git remote show $REMOTE | grep "HEAD branch" | sed 's/.*: //')
  fi
  echo $DEFAULT_BRANCH
}


### Function to make sure I don't push to the default remote branch unless I really mean to 🤦‍♂️
gpoh() {
  local CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  local DEFAULT_BRANCH=$(git_default_branch)

  # check we're not on the default branch
  if [[ $CURRENT_BRANCH == $DEFAULT_BRANCH ]]; then
    print -P "$lcicon_warning$lcicon_warning $FG[009]WARNING: You're about to push to the default branch ($DEFAULT_BRANCH)!$reset_color $lcicon_warning$lcicon_warning"
    vared -p "$lcicon_question Are you sure you want to continue? [y/N] " -c response
    if ! [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
    then
      print -P "$lcicon_fail Aborted! Nothing was done."
      return 1
    fi
  fi
  git push origin HEAD --set-upstream
}



#### For GitHub: e.g gcpr 12345.
#### Requires GitHub CLI: https://github.com/cli/cli
#### Replaces old complicated function. For old function, see https://github.com/lucascosti/zshrc/blob/b371ff5404e47990d37be72c6f4c90618f019445/.zshrc#L215-L241
gcpr() { gh pr checkout $1; }

# Checkout the default branch
# gcm() { gc $(git_default_branch) } 

### Checkout the default branch and attempt to delete the current branch after changing
gcmd() {
  local CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  local DEFAULT_BRANCH=$(git_default_branch)

  # check we're not on the default branch
  if [[ $CURRENT_BRANCH == $DEFAULT_BRANCH ]]; then
    print -P "$lcicon_fail Whoops! 😬 You're already on $DEFAULT_BRANCH!"
    return 1
  fi

  lcfunc_step_border 1 2 "$lcicon_infoi Changing to the default branch: $DEFAULT_BRANCH..."
  gc $DEFAULT_BRANCH \
  && lcfunc_step_border 2 2 "$lcicon_trash Attempting to delete branch $CURRENT_BRANCH..." \
  && grmbranch $CURRENT_BRANCH \
  && lcfunc_step_border
}

