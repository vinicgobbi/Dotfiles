# Verifica se bat ou batcat existem e cria o alias para cat
if command -v bat &> /dev/null; then
    alias cat="bat"
elif command -v batcat &> /dev/null; then
    alias cat="batcat"
fi

# Verifica se eza existe antes de criar aliases para ls e tree
if command -v eza &> /dev/null; then
    alias ls="eza --icons --sort=type"
    alias tree="eza --icons --sort=type --tree"
fi

alias cls="clear"
alias vencord='sh -c "$(curl -sS https://vencord.dev/install.sh)"'
