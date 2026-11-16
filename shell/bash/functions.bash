# Functions for bash. Ported from the zsh dh-git plugin, oh-my-zsh lib/git.zsh, the kubectl plugin and
# custom/0.kubetools.zsh. The aliases in aliases.bash call several of these.

# --- git ---------------------------------------------------------------------------------------------------------

git_current_branch() {
  local ref ret
  ref=$(command git symbolic-ref --quiet HEAD 2>/dev/null)
  ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return # no git repo
    ref=$(command git rev-parse --short HEAD 2>/dev/null) || return
  fi
  echo "${ref#refs/heads/}"
}

current_branch() { git_current_branch; }

git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel develop development; do
    if command git show-ref -q --verify "refs/heads/$branch"; then
      echo "$branch"
      return 0
    fi
  done
  echo develop
  return 1
}

git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify "$ref"; then
      echo "${ref##*/}"
      return 0
    fi
  done
  echo master
  return 1
}

grename() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: ${FUNCNAME[0]} old_branch new_branch"
    return 1
  fi
  git branch -m "$1" "$2"
  if git push origin :"$1"; then
    git push --set-upstream origin "$2"
  fi
}

gunwipall() {
  local _commit
  _commit=$(git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H)
  if [[ "$_commit" != "$(git rev-parse HEAD)" ]]; then
    git reset "$_commit" || return 1
  fi
}

work_in_progress() {
  command git -c log.showSignature=false log -n 1 2>/dev/null | grep -q -- "--wip--" && echo "WIP!!"
}

gbda() {
  git branch --no-color --merged |
    command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" |
    command xargs git branch --delete 2>/dev/null
}

gbds() {
  local default_branch branch merge_base
  default_branch=$(git_main_branch) || default_branch=$(git_develop_branch)
  git for-each-ref refs/heads/ "--format=%(refname:short)" | while read -r branch; do
    merge_base=$(git merge-base "$default_branch" "$branch")
    if [[ $(git cherry "$default_branch" "$(git commit-tree "$(git rev-parse "$branch^{tree}")" -p "$merge_base" -m _)") = -* ]]; then
      git branch -D "$branch"
    fi
  done
}

# Clone, then cd into the new folder (last argument if it is a folder, else the repo name).
gccd() {
  command git clone --recurse-submodules "$@" || return
  local last="${!#}" repo dir
  if [[ -d "$last" ]]; then
    cd "$last"
    return
  fi
  for repo in "$@"; do
    [[ "$repo" == *://* || "$repo" == *@* ]] && dir=$repo
  done
  dir=${dir%/}
  dir=${dir##*/}
  dir=${dir##*:}
  cd "${dir%.git}"
}

gdv() { git diff -w "$@" | view -; }

gdnolock() { git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"; }

gtl() { git tag --sort=-v:refname -n --list "${1}*"; }

_git_log_prettily() {
  if [[ -n "$1" ]]; then
    git log --pretty="$1"
  fi
}

ggu() {
  local b=$1
  [[ $# != 1 ]] && b=$(git_current_branch)
  git pull --rebase origin "$b"
}

ggl() {
  if [[ $# != 0 && $# != 1 ]]; then
    git pull origin "$*"
  else
    local b=$1
    [[ $# == 0 ]] && b=$(git_current_branch)
    git pull origin "$b"
  fi
}

ggf() {
  local b=$1
  [[ $# != 1 ]] && b=$(git_current_branch)
  git push --force origin "$b"
}

ggfl() {
  local b=$1
  [[ $# != 1 ]] && b=$(git_current_branch)
  git push --force-with-lease origin "$b"
}

ggp() {
  if [[ $# != 0 && $# != 1 ]]; then
    git push origin "$*"
  else
    local b=$1
    [[ $# == 0 ]] && b=$(git_current_branch)
    git push origin "$b"
  fi
}

ggpnp() {
  if [[ $# == 0 ]]; then
    ggl && ggp
  else
    ggl "$@" && ggp "$@"
  fi
}

# --- kubernetes --------------------------------------------------------------------------------------------------

doas() {
  if [[ -z "${1:-}" ]]; then
    echo "No team name given."
    return 1
  fi
  doctl auth switch --context "$1"
}

dogcc() {
  if [[ -z "${1:-}" ]]; then
    echo "No cluster name given."
    return 1
  fi
  doctl kubernetes cluster kubeconfig show "$1" >~/.kube/config-files/"$1".yaml
}

update_kubeconfig() {
  export DEFAULT_KUBECONFIG_FILE="$HOME/.kube/config"
  if [[ -f "$DEFAULT_KUBECONFIG_FILE" ]]; then
    export KUBECONFIG="$DEFAULT_KUBECONFIG_FILE"
  fi
  if [[ ! -d "$HOME/.kube/config-files" ]]; then
    mkdir "$HOME/.kube/config-files"
  fi
  local kubeconfig_file
  for kubeconfig_file in $(find "$HOME/.kube/config-files" -type f -name "*.yaml"); do
    export KUBECONFIG="$KUBECONFIG:$kubeconfig_file"
  done
}

kflat() {
  kubectl config view --flatten >/tmp/kubeconfig && mv /tmp/kubeconfig "$HOME/.kube/config"
}

kflatall() {
  update_kubeconfig
  kflat
  export KUBECONFIG=$HOME/.kube/config
  chmod 600 "$HOME/.kube/config"
}

kc() {
  update_kubeconfig
  kubectx
}

kres() { kubectl set env "$@" REFRESHED_AT="$(date +%Y%m%d%H%M%S)"; }
kj() { kubectl "$@" -o json | jq; }
kjx() { kubectl "$@" -o json | fx; }
ky() { kubectl "$@" -o yaml | yh; }
