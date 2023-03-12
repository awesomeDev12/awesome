# init.sh

# Swap Capslock and Esc keys
setxkbmap -option caps:swapescape


# Run CLI commands in VI mode
set -o vi

# Set EDITOR env variable to neovim
export EDITOR=nvim


# use options key as super key
# xmodmap -e "keycode 135 = Super_R"

# xmodmap
xmodmap ~/.Xmodmap

