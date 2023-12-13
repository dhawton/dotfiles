# Golang
GO_BIN_PATH="/usr/local/go/bin"
WEBI_GO="$([ -d $HOME/.local/opt/ ] && ls $HOME/.local/opt/ | grep go-v)"
[ -n "${WEBI_GO}" ] && GO_BIN_PATH="$HOME/.local/opt/${WEBI_GO}/bin"
export PATH="$PATH:$GO_BIN_PATH"
export PATH="$PATH:$HOME/go/bin"
export GOPATH="$HOME/go"