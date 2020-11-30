typeset ssh_environment
typeset plugin_path

function start_ssh_agent() {
    local lifetime
    local -a identities
    local pass_path
    local passphrase

    zstyle -s :plugins:ssh-agent lifetime lifetime

    ssh-agent -s ${lifetime:+-t} ${lifetime} | sed 's/^echo/#echo/' >! $ssh_environment
    chmod 600 $ssh_environment
    source $ssh_environment > /dev/null
    
    zstyle -s :plugins:ssh-agent pass_path pass_path
    secret=$(pass ${pass_path} | head -n 1) 

    zstyle -a :plugins:ssh-agent identities identities

    echo starting ssh-agent...
    SSH_ASKPASS="${plugin_path}/ssh-agent-ask-pass-echo.zsh" ssh-add $HOME/.ssh/${^identities} <<< "${secret}"
}

ssh_environment="$HOME/.ssh/environment-$HOST"

plugin_path=${0:a:h}

if [[ -f "$ssh_environment" ]]; then
    source $ssh_environment > /dev/null
    ps x | grep ssh-agent | grep -q $SSH_AGENT_PID || {
	start_ssh_agent
    }
else
    start_ssh_agent
fi

unset ssh_environment
unset plugin_path
unfunction start_ssh_agent

