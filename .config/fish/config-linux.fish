if type -q exa
    alias ll "exa -l -g --icons"
    alias lla "ll -a"
    alias pacman='pacman --color=always'
end

# function fish_greeting
#     set -l autoload_script "./scripts/autoload.sh"
#     if test -f $autoload_script; and test -x $autoload_script
#         source $autoload_script
#     else
#         echo Hello friend!
#         echo The time is (set_color yellow)(date +%T)(set_color normal) and this machine is called $hostname
#     end
# end

# disable fish_jj_prompt
function fish_jj_prompt
end
#disable fish_fossil_prompt
function fish_fossil_prompt
end
#disable fish_hg_prompt
function fish_hg_prompt
end
