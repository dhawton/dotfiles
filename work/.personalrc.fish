set krew_root $KREW_ROOT
test -z "$krew_root"; and set krew_root "$HOME/.krew"

set -gx PATH "$HOME/.bin:$HOME/go/bin:$HOME/istio/bin:/usr/local/go/bin:$HOME/.gloo/bin:$HOME/.local/bin:$krew_root/bin:$HOME/.gloo-mesh/bin:$PATH"

eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
starship init fish | source

abbr ac "docker run -it --rm -v $HOME:/work -w /work --entrypoint /bin/sh amazon/aws-cli:latest"
abbr rd "ssh 172.17.243.2 sudo pihole restartdns"
abbr k "kubectl"
abbr ls "ls --color=always"
abbr g "glooctl"
abbr gcb "git rev-parse --abbrev-ref HEAD"
abbr gco "git checkout"
abbr gcon "git checkout -b"
abbr kgp "kubectl get pod"
abbr kgn "kubectl get nodes"
abbr kd "kubectl describe"
abbr kail "kubectl logs -f"
abbr ka "kubectl apply"
abbr kdel "kubectl delete"
abbr c "code ."
abbr ins "instruqt"
abbr i "istioctl"
abbr id "$HOME/dev/istio/istio/out/linux_amd64/istioctl"
abbr kflat "kubectl config view --flatten > /tmp/kubeconfig && mv /tmp/kubeconfig $HOME/.kube/config"
abbr istiotestkind "$HOME/dev/istio/istio/prow/integ-suite-kind.sh --skip-build --skip-cleanup --kind-config $HOME/dev/istio/istio/prow/config/ambient-sc2.yaml"

abbr gpush "git push origin (git rev-parse --abbrev-ref HEAD)"
abbr gpushf "git push origin (git rev-parse --abbrev-ref HEAD) --force"
abbr w1ct w1 "curl $argv | tail -n 40"
abbr w1 "watch -d -n 1"

abbr dolc "doctl kubernetes cluster list"

function dogcc
  doctl kubernetes cluster kubeconfig show $argv[1] > ~/.kube/config-files/$argv[1].yaml
end

function update_kubeconfig
  set DEFAULT_KUBECONFIG_FILE "$HOME/.kube/config"
  if test -f "$DEFAULT_KUBECONFIG_FILE"
    set -gx KUBECONFIG "$DEFAULT_KUBECONFIG_FILE"
  end
  # Your additional kubeconfig files should be inside ~/.kube/config-files
  for kubeconfig_file in (find $HOME/.kube/config-files -type f -name "*.yaml")
    set -gx KUBECONFIG "$KUBECONFIG:$kubeconfig_file"
  end
end

function kflat
  kubectl config view --flatten > /tmp/kubeconfig && mv /tmp/kubeconfig $HOME/.kube/config
end

function kflatall
  update_kubeconfig
  kflat
  export KUBECONFIG=$HOME/.kube/config
  chmod 600 $HOME/.kube/config
end

function kc
  update_kubeconfig
  kubectx
end

function gssh
  set vm $argv[1]
  shift
  set ip (gcloud compute instances list --filter="name=('$vm')" --format=json | jq -r .[0].networkInterfaces[0].accessConfigs[0].natIP)
  ssh $ip $argv
end

set -gx AWS_PROFILE work

# kubectl completion
kubectl completion fish | source

# git completion
#git --version | awk '{print $3}' | string match -r '^[0-9]+\.[0-9]+' | string split -m1 '.' | read major minor; curl -L https://raw.githubusercontent.com/fish-shell/fish-shell/master/share/completions/git.fish | sed -e "s/git \(_git_aliases\)/git \1 $major $minor/g"

abbr k kubectl
abbr g gcloud
abbr kg kubectl get
abbr kd kubectl describe
abbr kdel kubectl delete
abbr kail kubectl logs -f
abbr ka kubectl apply
abbr kgn kubectl get nodes
abbr kgp kubectl get pod
abbr kcon kubectl config
abbr kctx kubectl config current-context

# Add gcloud path
source "$HOME/.local/google-cloud-sdk/path.fish.inc"
