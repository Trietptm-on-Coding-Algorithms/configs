# http://aperiodic.net/phil/prompt/
# https://github.com/ghosTM55/ghosTconf/blob/master/misc/_zshrc

# get local ip address
function ipaddr {
    ifconfig en1 | grep 'inet ' | awk '{print $2}'
}

### PROMPT提示符设置 ###
function precmd {

    local TERMWIDTH
    (( TERMWIDTH = ${COLUMNS} - 1 )) # 设置TERM长度

# 如果路径太长，进行截取

    PR_FILLBAR=""
    PR_PWDLEN=""

    local promptsize=${#${(%):---(%n@%m:%l)---()--}}
    # FIXME
    local ipaddress=`ifconfig en1 | grep 'inet ' | awk '{print $2}'`
    local ipaddrsize=${#${ipaddress}}
    local pwdsize=${#${(%):-%~}}

    if [[ "$promptsize + $ipaddrsize + 1 + $pwdsize" -gt $TERMWIDTH ]]; then
        ((PR_PWDLEN=$TERMWIDTH - $promptsize))
    else
        # 1 == length('@')
        PR_FILLBAR="\${(l.(($TERMWIDTH - ($promptsize + $ipaddrsize + 1 + $pwdsize)))..${PR_HBAR}.)}"
    fi

# APM信息
#   if which ibam > /dev/null; then
#       PR_APM_RESULT=`ibam --percentbattery`
#   elif which apm > /dev/null; then
#       PR_APM_RESULT=`apm`
#   fi
}


setopt extended_glob
preexec () {
    if [[ "$TERM" == "screen" ]]; then
        local CMD=${1[(wr)^(*=*|sudo|-*)]}
        echo -n "\ek$CMD\e\\"
    fi
}

setprompt () {

    setopt prompt_subst

# git
    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[red]%} ‹"
    ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"

# 使用颜色

    autoload colors zsh/terminfo
    if [[ "$terminfo[colors]" -ge 8 ]]; then
        colors
    fi
    for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
        eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
        eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
        (( count = $count + 1 ))
    done
    PR_NO_COLOUR="%{$terminfo[sgr0]%}"

# 扩展字符，获取更好的显示效果

    typeset -A altchar
    set -A altchar ${(s..)terminfo[acsc]}
    PR_SET_CHARSET="%{$terminfo[enacs]%}"
    PR_SHIFT_IN="%{$terminfo[smacs]%}"
    PR_SHIFT_OUT="%{$terminfo[rmacs]%}"
    PR_HBAR=${altchar[q]:--}
#PR_HBAR=" "
    PR_ULCORNER=${altchar[l]:--}
    PR_LLCORNER=${altchar[m]:--}
    PR_LRCORNER=${altchar[j]:--}
    PR_URCORNER=${altchar[k]:--}

# 设置Title

    case $TERM in
        xterm*)
            PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%m:%~ \a%}'
            ;;
        screen)
            PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
            ;;
        *)
            PR_TITLEBAR=''
            ;;
    esac

# 设置screen下的标题
    if [[ "$TERM" == "screen" ]]; then
        PR_STITLE=$'%{\ekzsh\e\\%}'
    else
        PR_STITLE=''
    fi

# PROMPT

    PROMPT='$PR_SET_CHARSET$PR_STITLE${(e)PR_TITLEBAR}\
$PR_CYAN$PR_SHIFT_IN$PR_ULCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_GREEN%(!.%SROOT%s.%n)$PR_GREEN@%m:%l@$(ipaddr)\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_HBAR${(e)PR_FILLBAR}$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
$PR_MAGENTA%$PR_PWDLEN<...<%~%<<\
$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_URCORNER$PR_SHIFT_OUT\

$PR_CYAN$PR_SHIFT_IN$PR_LLCORNER$PR_BLUE$PR_HBAR$PR_SHIFT_OUT(\
%(?..$PR_LIGHT_RED%?$PR_BLUE:)\
${(e)PR_APM}$PR_YELLOW%C$(git_prompt_info)%{$reset_color%}\
$PR_LIGHT_BLUE:%(!.$PR_RED.$PR_WHITE)%#$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_NO_COLOUR '

    RPROMPT=' $PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_BLUE$PR_HBAR$PR_SHIFT_OUT\
($PR_YELLOW%D{%H:%M,%a,%b%d}$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_CYAN$PR_LRCORNER$PR_SHIFT_OUT$PR_NO_COLOUR'

    PS2='$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_BLUE$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT(\
$PR_LIGHT_GREEN%_$PR_BLUE)$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT\
$PR_CYAN$PR_SHIFT_IN$PR_HBAR$PR_SHIFT_OUT$PR_NO_COLOUR '
}

setprompt                       # 读取prompt函数设置

### emacs-shell中的配置 ###
if [[ "$TERM" == "dumb" ]]; then
    setopt No_zle
    PROMPT='%~ %% '
    alias ls='ls -F'
fi

### 历史机制设置 ###
export HISTSIZE=1000
export SAVEHIST=1000
export HISTFILE=~/.zhistory
setopt HIST_IGNORE_DUPS         # 相同命令只记录一次
setopt EXTENDED_HISTORY         # 添加时间戳

### rvm配置 ###
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

### Man Page配置 ###
export GROFF_NO_SGR=yes
export LESS_TERMCAP_mb=$'\E[01;31m'     # Begin blinking
export LESS_TERMCAP_md=$'\E[01;31m'     # Begin bold
export LESS_TERMCAP_me=$'\E[0m'         # End mode
export LESS_TERMCAP_se=$'\E[0m'         # End standout-mode - info box
export LESS_TERMCAP_so=$'\E[0;4;30;42m' # Begin standout-mode
export LESS_TERMCAP_ue=$'\E[0m'         # Begin underline
export LESS_TERMCAP_us=$'\E[01;32m'     # ENd underline

### 文件关联 ###
autoload -U zsh-mime-setup
zsh-mime-setup

#alias -s html=firefox          # html文件使用firefox打开
#alias -s pdf=evince                # pdf文件使用evince打开

### misc ###
setopt INTERACTIVE_COMMENTS     # 允许在交互shell中使用注释
bindkey -e                      # emacs风格按键
setopt autocd                   # 直接输入目录名称可直接cd进入
autoload -U compinit            # 开启自动补全
compinit
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' # 大小写纠正
