# init.sh

# Keymaps begin
# setxkbmap -option
# Swap Capslock and Esc keys
# setxkbmap -option caps:swapescape
# Swap Left Alt and Left Control keys
# setxkbmap -option ctrl:swap_lalt_lctl
# Swap Right Alt and Right Control keys
# setxkbmap -option ctrl:swap_ralt_rctl
# Keymaps end

# Run CLI commands in VI mode
set -o vi

# Set EDITOR env variable to neovim
export EDITOR=nvim


# use options key as super key
# xmodmap -e "keycode 135 = Super_R"

# xmodmap
# xmodmap ~/.Xmodmap
#
#
bash ~/.bash_general

