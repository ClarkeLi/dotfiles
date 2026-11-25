#!/bin/sh
# tmux 状态栏用：超过 1 小时没有 continuum 自动保存时显示警告（正常间隔 15 分钟）。
last=$(tmux show -gqv @continuum-save-last-timestamp)
[ $(( $(date +%s) - ${last:-0} )) -gt 3600 ] && printf '⚠ 存档过期 '
exit 0
