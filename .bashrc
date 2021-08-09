#        __               __
#       / /_  ____ ______/ /_  __________
#      / __ \/ __ `/ ___/ __ \/ ___/ ___/
#   _ / /_/ / /_/ (__  ) / / / /  / /_
#  (_)_.___/\__,_/____/_/ /_/_/   \___/
#
# Lars Bohnsack
# 2021-08-09

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
## Eternal bash history
# undocumented feature which sets the size to unlimited
export HISTFILESIZE=
export HISTSIZE=

# add timestamps to every executed command
export HISTTIMEFORMAT="[%F %T] "

# Change the file location because certain bash sessions truncate .bash_history file upon close.
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"


## Eternal bash history
# undocumented feature which sets the size to unlimited
export HISTFILESIZE=
export HISTSIZE=

# add timestamps to every executed command
export HISTTIMEFORMAT="[%F %T] "

# Change the file location because certain bash sessions truncate .bash_history file upon close.
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Start/attach tmux session ssh_tmux if logged in via ssh
if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
  tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
fi

# User specific aliases and functions
alias fuck='sudo history -p \!\!'
export PATH=$PATH:/home/lbohnsac/Projects/CodeReadyContainers

## Completions
# enable oc completion
[ -x "$(which oc)" ] && eval "$(oc completion bash)"

# enable yq completion
[ -x "$(which yq)" ] && eval "$(yq completion bash)"

# KREW path
[ -f "$HOME/.krew" ] && export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# get current branch in git repo
function parse_git_branch() {
  BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
  if [ ! "${BRANCH}" == "" ]
  then
    STAT=`parse_git_dirty`
    echo "[${BRANCH}${STAT}]"
  else
    echo ""
  fi
}

# get current status of git repo
function parse_git_dirty {
  status=`git status 2>&1 | tee`
  dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
  untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
  ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
  newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
  renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
  deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
  bits=''
  if [ "${renamed}" == "0" ]; then
    bits=">${bits}"
  fi
  if [ "${ahead}" == "0" ]; then
    bits="*${bits}"
  fi
  if [ "${newfile}" == "0" ]; then
    bits="+${bits}"
  fi
  if [ "${untracked}" == "0" ]; then
    bits="?${bits}"
  fi
  if [ "${deleted}" == "0" ]; then
    bits="x${bits}"
  fi
  if [ "${dirty}" == "0" ]; then
    bits="!${bits}"
  fi
  if [ ! "${bits}" == "" ]; then
    echo " ${bits}"
  else
    echo ""
  fi
}

export PS1="\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;32m\]\H \[\033[01;34m\] \[\033[01;34m\]\t \[\033[01;33m\] \W \[\033[00m\]\[\033[01;31m\]\$(parse_git_branch)\[\033[00m\] $ "
