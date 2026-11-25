# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""  # 由 starship 接管提示符

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

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

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
  git
  fzf
  fzf-tab
  you-should-use
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Claude Code can exhaust the default macOS shell descriptor limit while
# indexing larger projects. Keep the higher limit local to interactive shells.
if (( $+commands[ulimit] )); then
  ulimit -n 2147483646 2>/dev/null || true
fi

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# thefuck 懒加载：第一次输入 fuck 时才初始化
fuck() { unfunction fuck; eval "$(thefuck --alias)"; fuck "$@"; }

alias proxy='export all_proxy=socks5://127.0.0.1:7890'

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# ---- conda 懒加载：第一次运行 conda 时才初始化（启动快约 0.45 秒）----
# 新 shell 仍默认使用 base 里的 python/pip，与原来一致；运行 `conda init` 会把原区块加回来，届时删掉即可。
unset -m 'CONDA_(PREFIX*|DEFAULT_ENV|SHLVL|PROMPT_MODIFIER)'   # 清掉从父进程继承的激活状态
path=(/opt/homebrew/Caskroom/miniconda/base/bin ${path:#/opt/homebrew/Caskroom/miniconda/base/bin})
conda() {
  unfunction conda
  eval "$(/opt/homebrew/bin/conda shell.zsh hook)"
  conda "$@"
}

# finder helper
# case ":$PATH:" in
#   *":$HOME/Desktop/c/finder:"*) ;;
#   *) export PATH="$HOME/Desktop/c/finder:$PATH" ;;
# esac

# Added by cua-driver-rs installer — see https://github.com/trycua/cua
export PATH="$HOME/.local/bin:$PATH"

# ---- fzf: use fd as the search source (hidden files on, .git off) ----
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

# ---- yazi: y 退出后自动 cd 到最后浏览的目录 ----
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ---- zoxide: z 命令按访问频率跳转目录（zi 为交互式选择）----
eval "$(zoxide init zsh)"

# ===== 现代终端增强（Monokai）=====
export CONDA_CHANGEPS1=false   # 提示符里的 conda 环境交给 starship 显示
export BAT_THEME="Monokai Extended"
export YSU_MESSAGE_POSITION="after"
export EZA_COLORS="da=38;2;117;113;94"
export FZF_DEFAULT_OPTS="--height 45% --layout=reverse --border=rounded --info=inline \
  --color=bg+:#3E3D32,bg:#272822,spinner:#AE81FF,hl:#F92672,fg:#F8F8F2,header:#F92672,info:#66D9EF,pointer:#A6E22E,marker:#A6E22E,fg+:#F8F8F2,prompt:#FD971F,hl+:#F92672,border:#75715E"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons=auto -- {}'"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=auto -- $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# LS_COLORS（Monokai）——需在下面的 list-colors 之前
command -v vivid >/dev/null && export LS_COLORS="$(vivid generate molokai)"

# fzf-tab 沿用 FZF_DEFAULT_OPTS 里的 Monokai 配色与圆角边框
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:git-checkout:*' sort false
# 补全文件、目录时的预览
zstyle ':fzf-tab:complete:(ls|eza|bat|cat|nvim|vim|code):*' fzf-preview \
  '[[ -d $realpath ]] && eza -1 --color=always --icons=auto -- $realpath || bat --color=always --style=numbers --line-range=:120 -- $realpath 2>/dev/null'

# 命令行语法高亮（Monokai）
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#A6E22E'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#A6E22E'
ZSH_HIGHLIGHT_STYLES[function]='fg=#A6E22E'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#A6E22E,italic'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#A6E22E,italic'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#F92672'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#F92672,bold'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#FD971F'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#FD971F'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#E6DB74'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#E6DB74'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#E6DB74'
ZSH_HIGHLIGHT_STYLES[path]='fg=#F8F8F2,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#AE81FF'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#F92672'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#F92672'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#75715E,italic'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#66D9EF'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#75715E'

# man 页用 bat 上色
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# eza reads file names from stdin when stdin is not a TTY (hangs in Claude Code etc.),
# so only use eza interactively; fall back to plain ls otherwise.
# eza/bat 的选项含义与原生命令不同（如 ls -lt、cat -v），带任何选项时走原生命令。
unalias ls ll lt l la lsa cat 2>/dev/null
ls() { if [[ -t 0 && -z ${(M)@:#-*} ]]; then eza --icons=auto --group-directories-first "$@"; else command ls -G "$@"; fi }
ll() { if [[ -t 0 && -z ${(M)@:#-*} ]]; then eza -lah --icons=auto --git --group-directories-first "$@"; else command ls -lahG "$@"; fi }
lt() { eza --tree --level=2 --icons=auto "${@:-.}" </dev/null }
l() { ll "$@" }; la() { ll "$@" }; lsa() { ll "$@" }   # 用函数，免得 you-should-use 在输入 ll 时提示
# 只替换交互输入的 cat；用别名而不是同名函数，避免影响插件和脚本函数里的 cat
pretty_cat() { if [[ -t 1 && -z ${(M)@:#-*} ]]; then bat --paging=never --style=plain "$@"; else command cat "$@"; fi }
alias cat='pretty_cat'
alias top='btop'
alias lg='lazygit'
alias help='tldr'
alias reload='exec zsh'
alias ff='fastfetch'

command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"
command -v starship >/dev/null && eval "$(starship init zsh)"

# Transient prompt：回车执行后，把这一行提示符收缩成一个 ❯
_transient_prompt_finish() {
  local _p=$PROMPT _rp=$RPROMPT
  PROMPT=$'%{\e[38;2;166;226;46m%}❯%{\e[0m%} '
  RPROMPT=''
  zle .reset-prompt
  zle -R   # 还原 PROMPT 之前必须先重绘，否则看不到收缩效果
  PROMPT=$_p; RPROMPT=$_rp
}
# 追加钩子而不是覆盖 zle-line-finish，保留语法高亮和 oh-my-zsh 的收尾钩子
autoload -Uz add-zle-hook-widget
add-zle-hook-widget line-finish _transient_prompt_finish

# 首次进入某个 git 仓库时显示 onefetch（每个仓库每个终端只显示一次）
typeset -g _ONEFETCH_LAST=""
_onefetch_on_cd() {
  [[ -n "$CLAUDECODE" ]] && return
  command -v onefetch >/dev/null || return
  local root; root=$(git rev-parse --show-toplevel 2>/dev/null) || return
  [[ "$root" == "$_ONEFETCH_LAST" || "$root" == "$HOME" ]] && return
  _ONEFETCH_LAST=$root
  onefetch --no-bots 2>/dev/null
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _onefetch_on_cd
alias c='cd /Volumes/CLARKE/c'

# ---- tmux ----
alias t='tmux new -A -s claude'   # 进入 claude 会话，没有就新建
# 把当前目录写成窗格标题：状态栏显示用；空标题还会让 tmux-resurrect 的存档字段错位
if [[ -n $TMUX ]]; then
  tmux_pane_title() { print -Pn '\e]2;%1~\a' }
  add-zsh-hook precmd tmux_pane_title
fi

# machine-specific or private settings (not tracked)
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local
