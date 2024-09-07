[[ $- != *i* ]] && return

export HISTFILESIZE=10000
export HISTSIZE=500

export FZF_DEFAULT_OPTS="
	--color=fg:#908caa,bg:#191724,hl:#ebbcba
	--color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
	--color=border:#403d52,header:#31748f,gutter:-1
	--color=spinner:#f6c177,info:#9ccfd8
	--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

alias ls='ls -la --color=auto --group-directories-first'
alias grep='grep --color=auto'
alias ff='fastfetch'
alias cls='clear'
alias rm='printf "\033[1;38;2;235;111;146m" && rm -rIv'
alias sudo='doas'
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

export PATH=/home/kyoko/.local/bin:/home/kyoko/.cargo/bin:/home/kyoko/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
export PATH="$HOME/.cargo/bin:$PATH"
eval "$(starship init bash)"
