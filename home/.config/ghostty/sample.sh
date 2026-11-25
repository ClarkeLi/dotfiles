#!/bin/zsh
print -P "%B粗体 Bold 0123%b  \e[3m斜体 Italic 0123\e[0m  \e[1;3m粗斜体 BoldItalic\e[0m  常规 Regular"
print "连字: -> => != >= <= === |> ::  中英混排: 终端 Terminal 美化 0Oo 1lI"
print "图标:          󰊢  "
print "\e[4:3m\e[58:2::249:38:114m波浪下划线 undercurl\e[0m  \e[9m删除线\e[0m  \e[4m下划线\e[0m"
for c in '249;38;114' '253;151;31' '230;219;116' '166;226;46' '102;217;239' '174;129;255' '117;113;94'; do
  printf "\e[48;2;%sm      \e[0m " "$c"
done; print
