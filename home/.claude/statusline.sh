#!/bin/zsh
# Claude Code 状态栏 · Monokai · 两行，全部左对齐：①模型·effort ②目录·git·上下文·5h/7d 额度
input=$(cat)
IFS=$'\t' read -r model effort dir pct size r5 r5t r7 r7t cwarm cobs cexp <<< "$(print -r -- "$input" | jq -r '[
  (.model.display_name // .model.id // "Claude"),
  (.effort.level // "-"),
  (.workspace.current_dir // .cwd // "-"),
  (.context_window.used_percentage // "-"),
  (.context_window.context_window_size // "-"),
  (.rate_limits.five_hour.used_percentage // "-"),
  (.rate_limits.five_hour.resets_at // "-"),
  (.rate_limits.seven_day.used_percentage // "-"),
  (.rate_limits.seven_day.resets_at // "-"),
  (.prompt_cache.warm | if . == null then "-" else tostring end),
  (.prompt_cache.caching_observed | if . == null then "-" else tostring end),
  (.prompt_cache.expires_at // "-")] | @tsv' 2>/dev/null)"
for v in effort pct size r5 r5t r7 r7t cwarm cobs cexp; do [[ "${(P)v}" == "-" ]] && typeset $v=""; done
[[ "$dir" == "-" || -z "$dir" ]] && dir=$PWD

c() { printf '\e[38;2;%sm' "$1"; }
R=$'\e[0m'; B=$'\e[1m'
PINK=$(c '249;38;114'); ORG=$(c '253;151;31'); YEL=$(c '230;219;116')
GRN=$(c '166;226;46'); CYA=$(c '102;217;239'); PUR=$(c '174;129;255')
GRY=$(c '117;113;94'); DIM=$(c '73;72;62')
SEP="${GRY} ▏${R}"

# 颜色随占用变化
pcol() { local p=$1; local col=$GRN; (( p >= 50 )) && col=$YEL; (( p >= 75 )) && col=$ORG; (( p >= 90 )) && col=$PINK; print -r -- "$col"; }
# 细线进度条：bar <百分比> <格数>
bar() {   # bar <填充百分比> <格数> [用于取色的百分比]
  local p=$1 n=$2 col; col=$(pcol ${3:-$1})
  (( p > 100 )) && p=100; (( p < 0 )) && p=0
  local full=$(( p * n / 100 )) rem=$(( p * n % 100 )) tip=0
  (( rem >= 50 )) && tip=1
  local rest=$(( n - full - tip )) s="$col" i
  for ((i=0;i<full;i++)); do s+="━"; done
  (( tip )) && s+="╸"
  s+="$DIM"; for ((i=0;i<rest;i++)); do s+="─"; done
  print -rn -- "${s}${R}"
}
# 距重置时间：epoch -> 2h13m / 3d4h
until_reset() {
  local d=$(( $1 - $(date +%s) )); (( d < 0 )) && d=0
  if (( d >= 86400 )); then print -rn -- "$(( d/86400 ))d$(( d%86400/3600 ))h"
  elif (( d >= 3600 )); then print -rn -- "$(( d/3600 ))h$(( d%3600/60 ))m"
  else print -rn -- "$(( d/60 ))m"; fi
}
# 左对齐拼接
join() { local out="" x; for x in "$@"; do [[ -n "$x" ]] && out+="${out:+${SEP} }${x}"; done; print -r -- "$out"; }

# 缓存状态：warm → 剩余时间；将过期 → 橙色；cold → 粉红整块警告（同时让 ctx 条变红）
cache_cold=0; seg_cache=""
if [[ "$cobs" == "true" ]]; then
  now=$(date +%s); cleft=$(( ${cexp%.*:-0} - now ))
  if [[ "$cwarm" == "false" || ( -n "$cexp" && $cleft -le 0 ) ]]; then
    cache_cold=1
    seg_cache=$'\e[48;2;249;38;114m\e[38;2;39;40;34m\e[1m'" ⚠ CACHE COLD · new session "${R}
  elif (( cleft <= 300 )); then
    seg_cache="${ORG}${B}◐ cache $(until_reset $cexp) left${R}"
  else
    seg_cache="${GRN}● cache${R}${GRY} $(until_reset $cexp)${R}"
  fi
fi

# ===== 全部一行：模型 · effort · 目录 · git · 上下文 · 5h/7d 剩余额度 · 缓存 =====
seg_model="${PINK}${B}◆ ${model}${R}"
if [[ -n "$effort" ]]; then
  case $effort in
    low)    ec=$GRY ;;
    medium) ec=$CYA ;;
    high)   ec=$ORG ;;
    *)      ec=$PINK ;;
  esac
  seg_model+=" ${ec}(${effort})${R}"
fi
seg_effort=""
dname=${dir:t}; (( ${#dname} > 14 )) && dname="${dname[1,13]}…"
seg_dir="${CYA}"$'\U000F024B'" ${dname}${R}"
seg_git=""
branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null)
if [[ -n "$branch" ]]; then
  dirty=""; [[ -n $(git -C "$dir" status --porcelain 2>/dev/null | head -1) ]] && dirty="${ORG} ●"
  bname=$branch; (( ${#bname} > 16 )) && bname="${bname[1,15]}…"
  seg_git="${PUR}"$'\U000F062C'" ${bname}${dirty}${R}"
fi
seg_ctx=""
if [[ -n "$pct" ]]; then
  p=${pct%.*}; col=$(pcol $p); lbl=""; ctxlabel="${GRY}ctx${R}"
  if (( cache_cold )); then col=$PINK; ctxlabel="${PINK}${B}⚠ ctx${R}"; fi
  if [[ -n "$size" ]]; then (( size >= 1000000 )) && lbl="/$(( size / 1000000 ))M" || lbl="/$(( size / 1000 ))k"; fi
  if (( cache_cold )); then
    seg_ctx="${ctxlabel} $(bar $p 6 100) ${PINK}${B}${p}%${R}${PINK}${lbl}${R}"
  else
    seg_ctx="${ctxlabel} $(bar $p 6) ${col}${p}%${R}${GRY}${lbl}${R}"
  fi
fi

# ===== 第二行：额度（剩余）· 重置时间 · 缓存状态 =====
quota() {   # quota <名称> <已用%> <重置epoch> [short]
  local name=$1 used=${2%.*} t=$3 short=$4 left col out
  left=$(( 100 - used )); (( left < 0 )) && left=0
  col=$(pcol $used)
  out="${GRY}${name}${R} ${col}${left}%${R}"
  [[ -n "$t" && -z "$short" ]] && out+="${GRY} ↻$(until_reset ${t%.*})${R}"
  print -rn -- "$out"
}
seg_5h=""; [[ -n "$r5" ]] && seg_5h=$(quota 5h "$r5" "$r5t")
seg_7d=""; [[ -n "$r7" ]] && seg_7d=$(quota 7d "$r7" "$r7t")

# ===== 宽度预算（默认 114，可用环境变量 STATUSLINE_MAX 调整）=====
vlen() { setopt localoptions extendedglob; local t="${1//$'\e'\[[0-9;]#m/}"; print -rn -- ${#t}; }
BUDGET=${STATUSLINE_MAX:-114}
total() { local n=0 x cnt=0; for x in "$@"; do [[ -n "$x" ]] && { n=$(( n + $(vlen "$x") )); cnt=$(( cnt + 1 )); }; done; print -rn -- $(( n + (cnt > 1 ? (cnt - 1) * 3 : 0) )); }

# 舍弃顺序：7d 重置时间 → 5h 重置时间 → git → 7d → 目录
seg_7d_s=""; [[ -n "$r7" ]] && seg_7d_s=$(quota 7d "$r7" "$r7t" short)
seg_5h_s=""; [[ -n "$r5" ]] && seg_5h_s=$(quota 5h "$r5" "$r5t" short)
t=$(total "$seg_model" "$seg_dir" "$seg_git" "$seg_ctx" "$seg_5h" "$seg_7d" "$seg_cache")
(( t > BUDGET )) && { seg_7d=$seg_7d_s; t=$(total "$seg_model" "$seg_dir" "$seg_git" "$seg_ctx" "$seg_5h" "$seg_7d" "$seg_cache"); }
(( t > BUDGET )) && { seg_5h=$seg_5h_s; t=$(total "$seg_model" "$seg_dir" "$seg_git" "$seg_ctx" "$seg_5h" "$seg_7d" "$seg_cache"); }
(( t > BUDGET )) && { seg_git=""; t=$(total "$seg_model" "$seg_dir" "$seg_git" "$seg_ctx" "$seg_5h" "$seg_7d" "$seg_cache"); }
(( t > BUDGET )) && { seg_7d=""; t=$(total "$seg_model" "$seg_dir" "$seg_git" "$seg_ctx" "$seg_5h" "$seg_7d" "$seg_cache"); }
(( t > BUDGET )) && { seg_dir=""; }

join "$seg_model" "$seg_dir" "$seg_git" "$seg_ctx" "$seg_5h" "$seg_7d" "$seg_cache"
