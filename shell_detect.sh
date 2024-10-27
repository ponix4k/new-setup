
if [ -n "$BASH_VERSION" ]; then
    echo "You are using Bash version $BASH_VERSION."
elif [ -n "$ZSH_VERSION" ]; then
    echo "You are using Zsh version $ZSH_VERSION."
else
    echo "Unknown shell."
fi
