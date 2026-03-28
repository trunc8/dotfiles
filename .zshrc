# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

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

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

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
plugins=(
    docker
    docker-compose
    extract # Alias 'x'
    git
    tmux # Shortcuts ts and ta
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# trunc8 did this; Because Sem_Coursework was too big and slow to load
# https://gist.github.com/msabramo/2355834#gistcomment-2820263
# (Modified function in zsh source): Outputs current branch info in prompt format
function git_prompt_info() {
  local ref
  if [[ "$(command git config --get oh-my-zsh.hide-dirty)" != "1" ]]; then
    if [[ "$(__git_prompt_git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
      ref=$(__git_prompt_git symbolic-ref HEAD 2> /dev/null) || \
      ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) || return 0
      echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
    fi
  fi
}

# function function_test() {
#   echo "Do you wish to install this program?"
# select yn in "Yes" "No"; do
#     case $yn in
#         Yes ) echo $@; break;;
#         No ) break;;
#     esac
# done
# }

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8
# to obtain powerline symbols in tmux. The earlier hack was to use tmux -u. This forced the output to be UTF-8

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



# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.



## trunc8 did these

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

if [ -f ~/.private_aliases ]; then
    . ~/.private_aliases
fi
# Key mapping (Update: done differently now in i3 config file)
# xmodmap /home/trunc8/villa/Basement/.key_mapping

# ROS related
# source /opt/ros/melodic/setup.zsh
# source /usr/share/gazebo-9/setup.sh
# export TURTLEBOT3_MODEL=waffle
# source /home/trunc8/catkin_ws/devel/setup.zsh
# source /home/trunc8/catkin_ws/devel_cb/setup.zsh

# source /opt/ros/foxy/setup.zsh
# source /usr/share/colcon_cd/function/colcon_cd.sh
# source ~/colcon_ws/install/setup.zsh
# source /usr/share/gazebo-11/setup.sh

#export _colcon_cd_root=~/ros2_install

# Swiss army knife; opens nearly everything
op() {
  if [[ "$1" == "" ]];
  then
    xdg-open . > /dev/null 2>&1 &
  else
    for file in "$@"
    do
      xdg-open "$file" > /dev/null 2>&1 &
    done
  fi
}

con() {
  if [[ "$2" == "" ]];
  then
    # Make a copy of a.png as a@2x.png
    cp "$1" $(echo "$1" | sed -E 's/\.([a-z]+)$/@2x\.\1/')
    # Rewrite a.png with its halved image
    convert -resize 50% "$1" "$1"
    # End up with a.png and a@2x.png making semantic sense
  elif [[ "$3" != "" ]];
  then
    convert -resize "$1"% "$2" "$3"
  fi
}

# Convert webm to mp4 with the same file name
w2m() {
  for file in "$@"
  do
    ffmpeg -i "$file" $(echo $file | sed -E 's/webm$/mp4/')
  done
}

# export GAZEBOSIM_PATH=$HOME/villa/Basement/Model_Editor_Models/Gazebosim_Tutorial
# export GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:~/catkin_ws/src/my_package/models:${GAZEBOSIM_PATH}:
# export GAZEBO_PLUGIN_PATH=${GAZEBO_PLUGIN_PATH}:${GAZEBOSIM_PATH}/Velodyne_LiDAR/Velodyne_Plugin/build:${GAZEBOSIM_PATH}/Gazebo_Plugin_Tutorial/build:${GAZEBOSIM_PATH}/Sensor_Tutorial/build:
# export LD_LIBRARY_PATH=/usr/local/lib:/home/trunc8/villa/Basement/Playground/f1tenth/lpopt_install/ThirdParty-HSL/coinhsl/lib:$LD_LIBRARY_PATH
# export WEBOTS_HOME=/usr/local/webots
# export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:~/colcon_ws/src/turtlebot3/turtlebot3_simulations/turtlebot3_gazebo/models
# export TURTLEBOT3_MODEL=waffle_pi

eval "$(fasd --init auto)"
eval $(thefuck --alias)

# Vim extension to the shell
set -o vi

################### FZF ##################################
# **Must appear after the vim** row in zshrc for fzf keybindings to work
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Call script to preview files
export FZF_CTRL_T_OPTS=" --preview '~/bin/fzf-preview.sh {}'"
##########################################################


# Probably "less" (the pager tool) has upgraded. LESS="-R" doesn't cut it anymore
# https://superuser.com/a/1514628
export LESS='-R --mouse --wheel-lines=3'

# For gupload(https://github.com/labbots/google-drive-upload)
PATH="/home/trunc8/.google-drive-upload/bin:${PATH}"

# To get nvcc executable from cuda's bin directory
PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/cuda/targets/x86_64-linux/lib"


# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/versions/2.7.0/bin:$PATH"
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"

# For Julia
export PATH="$HOME/villa/Lobby/installers/julia-1.6.7/bin:$PATH"


# To remove the "Are you sure about this?" prompt from apt and apt-get, check which apt and go to that location and delete/rename the executable script
# Update: Deleted that script

source ~/.env

# Reason that closing lid doesn't work normally-
# sudo nano /etc/systemd/logind.conf
# HandleLidSwitch=suspend -> ignore
