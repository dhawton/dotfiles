alias rd="ssh 172.17.243.2 sudo pihole restartdns"
alias w1="watch -n 1"
alias w1d="watch -d -n 1"
alias dolc="doctl kubernetes cluster list"
alias kg="kubectl get"
alias kgn="kubectl get nodes"

doas() {
  if [[ -z "${1:-}" ]]; then
    echo "No team name given."
    return 1
  fi

  doctl auth switch --context $1
}

dogcc() {
  if [[ -z "${1:-}" ]]; then
    echo "No cluster name given."
    return 1
  fi

  doctl kubernetes cluster kubeconfig show $1 > ~/.kube/config-files/$1.yaml
}

update_kubeconfig() {
  export DEFAULT_KUBECONFIG_FILE="$HOME/.kube/config"
  if [[ -f "$DEFAULT_KUBECONFIG_FILE" ]]; then
    export KUBECONFIG="$DEFAULT_KUBECONFIG_FILE"
  fi

  if [[ ! -d "$HOME/.kube/config-files" ]]; then
    mkdir "$HOME/.kube/config-files"
  fi

  for kubeconfig_file in $(find $HOME/.kube/config-files -type f -name "*.yaml"); do
    export KUBECONFIG="$KUBECONFIG:$kubeconfig_file"
  done
}

kflat() {
  kubectl config view --flatten > /tmp/kubeconfig && mv /tmp/kubeconfig $HOME/.kube/config
}

kflatall() {
  update_kubeconfig
  kflat
  export KUBECONFIG=$HOME/.kube/config
  chmod 600 $HOME/.kube/config
}

kc() {
  update_kubeconfig
  kubectx
}

