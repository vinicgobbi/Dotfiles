# Equivalente ao oh-my-zsh/custom/editor.zsh

# Verifica se o VSCode está no PATH e define como editor padrão
if (Get-Command code -ErrorAction SilentlyContinue) {
    $env:EDITOR = "code --wait"
    $env:VISUAL = "code --wait"
}
