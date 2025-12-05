#        __               __
#       / /_  ____ ______/ /_  __________
#      / __ \/ __ `/ ___/ __ \/ ___/ ___/
#   _ / /_/ / /_/ (__  ) / / / /  / /_
#  (_)_.___/\__,_/____/_/ /_/_/   \___/
#
# Lars Bohnsack
# 2025-12-05


###############################
## Source global definitions ##
###############################
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi


#############
## ALIASES ##
#############
# User specific aliases
alias ls='ls --color=auto' 2>/dev/null
alias grep='grep --color=auto' 2>/dev/null
alias egrep='egrep --color=auto' 2>/dev/null
alias fgrep='fgrep --color=auto' 2>/dev/null
alias xzgrep='xzgrep --color=auto' 2>/dev/null
alias xzegrep='xzegrep --color=auto' 2>/dev/null
alias xzfgrep='xzfgrep --color=auto' 2>/dev/null
alias zgrep='zgrep --color=auto' 2>/dev/null
alias zegrep='zegrep --color=auto' 2>/dev/null
alias zfgrep='zfgrep --color=auto' 2>/dev/null
alias fuck='eval sudo $(history -p \!\!)' 2>/dev/null


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


#################
## COMPLETIONS ##
#################
# enable oc completion
[ -x "$(which oc 2>/dev/null)" ] && eval "$(oc completion bash)"

# enable omc completion
# Instructions to download here: https://github.com/gmeghnag/omc?tab=readme-ov-file#linux--os-x                                                                                                                    
[ -x "$(which omc 2>/dev/null)" ] && eval "$(omc completion bash)"

# enable virtctl completion
[ -x "$(which virtctl 2>/dev/null)" ] && eval "$(virtctl completion bash)"

# enable yq completion
# Instructions to download here: https://github.com/mikefarah/yq#download-the-latest-binary
[ -x "$(which yq 2>/dev/null)" ] && eval "$(yq shell-completion bash)"

# enable helm completion
# Download it here: https://github.com/helm/helm/releases
# Or here: https://mirror.openshift.com/pub/openshift-v4/clients/helm/
[ -x "$(which helm 2>/dev/null)" ] && eval "$(helm completion bash)"


############
## EDITOR ##
############
# set standard editor to vim (what else?)
export EDITOR='vim'
export VISUAL='vim'
export SYSTEMD_EDITOR='vim'


###########################
## ETERNAL BASH HISTORY ##
###########################
# undocumented feature which sets the size to unlimited
export HISTFILESIZE=
export HISTSIZE=

# add timestamps to every executed command
export HISTTIMEFORMAT="[%F %T] "

# Change the file location because certain bash sessions truncate .bash_history file upon close.
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"


#################
## Export path ##
#################
# export CodeReadyContainers path
[ -f "$HOME/Projects/CodeReadyContainers" ] && export PATH=$PATH:$HOME/Projects/CodeReadyContainers

# export KREW path
[ -f "$HOME/.krew" ] && export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"


#####################
## Export env vars ##
#####################
# sealed secrets on openshift
export SEALED_SECRETS_CONTROLLER_NAMESPACE=sealed-secrets


##################################################################
## Fix bash: __vte_prompt_command: command not found... in tmux ##
##################################################################
# check if function exists and define empty one if doesn't
if [[ $(type -t "__vte_prompt_command") != function ]]; then
    function __vte_prompt_command(){
        return 0
    }
fi


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


###############
## GPG stuff ##
###############
export GPG_TTY="$(tty)"


############
## PROMPT ##
############
if [ $(id -u) -eq 0 ]
then # you are root
  export PS1="\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;32m\]\H \[\033[01;34m\] \[\033[01;34m\]\t \[\033[01;33m\] \W \[\033[00m\]\[\033[01;31m\]\$(type -t parse_git_branch &>/dev/null && parse_git_branch)\[\033[00m\] \[\033[01;31m\]#\[\033[01;00m\] "
else # you are not root
  export PS1="\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;32m\]\H \[\033[01;34m\] \[\033[01;34m\]\t \[\033[01;33m\] \W \[\033[00m\]\[\033[01;31m\]\$(type -t parse_git_branch &>/dev/null && parse_git_branch)\[\033[00m\] $ "
fi

###########
## Proxy ##
###########
function proxy_show(){
  env | grep -e _PROXY -e _proxy | sort
}
function proxy_on(){
  export HTTP_PROXY=''
  export HTTPS_PROXY=''
  export FTP_PROXY=''
  export NO_PROXY='localhost,127.0.0.0/8,::1'

  export http_proxy=${HTTP_PROXY}
  export https_proxy=${HTTPS_PROXY}
  export ftp_proxy=${FTP_PROXY}
  export no_proxy=${NO_PROXY}                                                                                                                                                                                      

  echo -e "\nThese proxy-related environment variables are set."
  proxy_show
}

function proxy_off(){
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset FTP_PROXY
  unset NO_PROXY

  unset http_proxy
  unset https_proxy
  unset ftp_proxy
  unset no_proxy

  proxy_show
  echo -e "\nProxy-related environment variables are removed."
}


###############
## SSH stuff ##
###############
# Start ssh-agent if available and not running
[ -x "$(which ssh-agent 2>/dev/null)" ] && ps auxww | grep -v grep | grep ${SSH_AGENT_PID} > /dev/null 2>&1 || eval $(ssh-agent) > /dev/null


##############
## TERMINAL ##
##############
# set TERM to xterm-256color
export TERM=xterm-256color


##########
## TMUX ##
##########
# Start/attach tmux session ssh_tmux if logged in via ssh
if [[ $- =~ i ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
  tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
fi
