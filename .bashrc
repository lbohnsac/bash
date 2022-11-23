#        __               __
#       / /_  ____ ______/ /_  __________
#      / __ \/ __ `/ ___/ __ \/ ___/ ___/
#   _ / /_/ / /_/ (__  ) / / / /  / /_
#  (_)_.___/\__,_/____/_/ /_/_/   \___/
#
# Lars Bohnsack
# 2023-07-13

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# set TERM to xterm-256color
export TERM=xterm-256color

###########################
## ETERNAL BASH HIOSTORY ##
###########################
# undocumented feature which sets the size to unlimited
export HISTFILESIZE=
export HISTSIZE=

# add timestamps to every executed command
export HISTTIMEFORMAT="[%F %T] "

# Change the file location because certain bash sessions truncate .bash_history file upon close.
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

##########
## TMUX ##
##########
# Start/attach tmux session ssh_tmux if logged in via ssh
if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
  tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
fi

############
## EDITOR ##
############
# set standard editor to vim (what else?)
export EDITOR='vim'
export VISUAL='vim'
export SYSTEMD_EDITOR='vim'

#############
## ALIASES ##
#############
# User specific aliases
alias fuck='sudo history -p \!\!'

#################
## Export path ##
#################
# export CodeReadyContainers path
[ -f "$HOME/Projects/CodeReadyContainers" ] && export PATH=$PATH:$HOME/Projects/CodeReadyContainers

# export KREW path
[ -f "$HOME/.krew" ] && export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

#################
## COMPLETIONS ##
#################
# enable oc completion
[ -x "$(which oc 2>/dev/null)" ] && eval "$(oc completion bash)"

# enable yq completion
# Instructions to download here: https://github.com/mikefarah/yq#download-the-latest-binary
[ -x "$(which yq 2>/dev/null)" ] && eval "$(yq shell-completion bash)"

# enable helm completion
# Download it here: https://github.com/helm/helm/releases
# Or here: https://mirror.openshift.com/pub/openshift-v4/clients/helm/
[ -x "$(which helm 2>/dev/null)" ] && eval "$(helm completion bash)"

#####################
## CHECK FUNCTIONS ##
#####################
# Check the given md5 sum of a given file
# e.g. md5check <CHECKSUM> <FILENAME>
# Output will be <FILENAME>: OK or FAILED
[ -x "$(which md5sum 2>/dev/null)" ] && function md5check() {
  echo "$1  $2" | md5sum --check
}

# Check the given sha1 sum of a given file
# e.g. sha1check <CHECKSUM> <FILENAME>
# Output will be <FILENAME>: OK or FAILED
[ -x "$(which sha1sum 2>/dev/null)" ] && function sha1check() {
  echo "$1  $2" | sha1sum --check
}

# Check the given sha224 sum of a given file
# e.g. sha224check <CHECKSUM> <FILENAME>
# Output will be <FILENAME>: OK or FAILED
[ -x "$(which sha224sum 2>/dev/null)" ] && function sha224check() {
  echo "$1  $2" | sha224sum --check
}

# Check the given sha256 sum of a given file                                                                                                                                                                       
# e.g. sha256check <CHECKSUM> <FILENAME>
# Output will be <FILENAME>: OK or FAILED
[ -x "$(which sha256sum 2>/dev/null)" ] && function sha256check() {
  echo "$1  $2" | sha256sum --check
}

# Check the given sha384 sum of a given file
# e.g. sha384check <CHECKSUM> <FILENAME>
# Output will be <FILENAME>: OK or FAILED
[ -x "$(which sha384sum 2>/dev/null)" ] && function sha384check() {
  echo "$1  $2" | sha384sum --check
}

# Check the given sha512 sum of a given file
# e.g. sha512check <CHECKSUM> <FILENAME>
# Output will be <FILENAME>: OK or FAILED
[ -x "$(which sha512sum 2>/dev/null)" ] && function sha512check() {
  echo "$1  $2" | sha512sum --check
}

#########
## GIT ##
#########
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

############
## PROMPT ##
############
export PS1="\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;32m\]\H \[\033[01;34m\] \[\033[01;34m\]\t \[\033[01;33m\] \W \[\033[00m\]\[\033[01;31m\]\$(parse_git_branch)\[\033[00m\] $ "
