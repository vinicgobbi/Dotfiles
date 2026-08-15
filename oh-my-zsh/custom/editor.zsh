# Verifica se o VSCode está no PATH e define como editor padrão
if command -v code &> /dev/null; then
    export EDITOR="code --wait"
    export VISUAL="code --wait"
fi
