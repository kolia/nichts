set -gx PATH /home/kolia/julia-1.6.0-beta1/bin $PATH /home/kolia/.cargo/bin

alias k 'kak -c global'

set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /run/current-system/sw/lib

fish_vi_key_bindings

if test -z (pgrep ssh-agent)
   eval (ssh-agent -c) > /dev/null
   set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
   set -Ux SSH_AGENT_PID $SSH_AGENT_PID
end
