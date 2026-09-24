# --- Ollama commit message generator ---
# function _my_ollama_commit_msg_generator
#     set -l msg (bash git-ai-commit-msg.sh 2>/dev/null; or echo "")
#     commandline -i -- "$msg"
#     commandline -f repaint
# end

# --- fzf commit message picker ---
function my_past_commit_msgs
    set -l msg (fzf-my-commit-messages.sh 2>/dev/null; or echo "")
    commandline -i -- "$msg"
    commandline -f repaint
end

# --- Key bindings ---
# bind \cga _my_ollama_commit_msg_generator
bind \cbc my_past_commit_msgs
