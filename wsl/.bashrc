# ~/.bashrc

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


# Add homedir bin folder
[ -d "$HOME/.local/bin" ] && [ `echo $PATH | grep -c "$HOME/.local/bin"` -eq 0 ] && PATH="$HOME/.local/bin:$PATH"

# Relay conf
GPG_RELAY_ENABLED=1
SSH_RELAY_ENABLED=1

WIN_USER="z"

# Binary conf
# https://github.com/jstarks/npiperelay
NPIPERELAY="/mnt/c/Users/${WIN_USER}/bin/npiperelay.exe"
# https://github.com/Lexicality/wsl-relay
WSL_RELAY="/mnt/c/Users/${WIN_USER}/bin/wsl-relay.exe"

# pipe windows gpg socket
WSL_GPG_SOCKET="${HOME}/.gnupg/S.gpg-agent"
GPG_RELAY_COMMAND="$WSL_RELAY --input-closes --pipe-closes --gpg"

GPG_PIPE_STATUS=$(ps -auxww | grep "${GPG_RELAY_COMMAND}" | grep -vq "grep --colour=auto ${GPG_RELAY_COMMAND}"; echo $?)

if [ $GPG_PIPE_STATUS -eq 1 ] && [ $GPG_RELAY_ENABLED -eq 1 ]; then
	echo "Starting GPG relay"
	socat UNIX-LISTEN:$WSL_GPG_SOCKET,fork EXEC:"${GPG_RELAY_COMMAND}",nofork & > /dev/null
fi

# for ssh socket
# Based on https://stuartleeks.com/posts/wsl-ssh-key-forward-to-windows/
WIN_SSH_PIPE="//./pipe/openssh-ssh-agent"
WSL_SSH_DIR="${HOME}/.ssh"
export SSH_AUTH_SOCK="${WSL_SSH_DIR}/agent.sock"

SSH_PIPE_STATUS=$(ps -auxww | grep "$NPIPERELAY" | grep -q "$WIN_SSH_PIPE"; echo $?)

if [ $SSH_PIPE_STATUS -eq 1 ] && [ $SSH_RELAY_ENABLED -eq 1 ]; then
	echo "Starting SSH relay"
	socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"${NPIPERELAY} -ei -s ${WIN_SSH_PIPE}",nofork & > /dev/null
fi
