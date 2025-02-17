# frg - fuzzy find/rg, piped to vscode.
# Usage: frg [-d dir] [-f] search_term
#   -d dir: cd to dir before searching
#   -f: search for files instead of text

install_frg () {
    read -p "Please specify a path to somewhere on your PATH: " PATH_TO_DIR_ON_PATH
    cd $PATH_TO_DIR_ON_PATH
    if ! which fzf > /dev/null; then
        wget https://github.com/junegunn/fzf/releases/download/v0.59.0/fzf-0.59.0-linux_amd64.tar.gz
        tar -xvf fzf-0.59.0-linux_amd64.tar.gz
        rm fzf-0.59.0-linux_amd64.tar.gz
    fi
    if ! which rg > /dev/null; then
        wget https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz
        tar -xvf ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz
        rm ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz
    fi
    if ! which bat > /dev/null; then
        wget https://github.com/sharkdp/bat/releases/download/v0.25.0/bat-v0.25.0-x86_64-unknown-linux-musl.tar.gz
        tar -xvf bat-v0.25.0-x86_64-unknown-linux-musl.tar.gz
        rm bat-v0.25.0-x86_64-unknown-linux-musl.tar.gz
        mv bat-v0.25.0-x86_64-unknown-linux-musl/bat bat
        rm -rf bat-v0.25.0-x86_64-unknown-linux-musl
    fi
}

rgg () {
  rg --column --line-number --no-heading --color=always --smart-case $@
}
export -f rgg

frg () {
  (
  local d_value="" f_true=false
  while getopts "d:f" opt; do
    case $opt in
      d) d_value="$OPTARG" ;;
      f) f_true=true ;;
    esac
  done
  shift $((OPTIND - 1))
  
  if [ -n "$d_value" ]; then cd "$d_value" || exit; fi

  if $f_true; then
    BASE_COMMAND="find | grep -i -E"
  else
    BASE_COMMAND="rgg"
  fi

  # Switch between find/rg and fzf filtering mode (CTRL-T)
  rm -f /tmp/rg-fzf-{r,f}
  INITIAL_QUERY="${*:-}"
  fzf --ansi --disabled --query "$INITIAL_QUERY" \
      --bind "start:reload:$BASE_COMMAND {q} " \
      --bind "change:reload:sleep 0.1;$BASE_COMMAND {q} " \
      --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ search ]] &&
        echo "rebind(change)+change-prompt(1. search> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
        echo "unbind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --prompt '1. search> ' \
      --delimiter : \
      --header 'CTRL-T: Switch between search/fzf' \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
      --bind 'enter:become(code -g {1}:{2})'
  )
}