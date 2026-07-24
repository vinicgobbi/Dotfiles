# Equivalente ao oh-my-zsh/custom/aliases.zsh

# Verifica se bat existe e cria o alias para cat
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -ErrorAction SilentlyContinue
    function cat { bat @args }
}

# Verifica se eza existe antes de criar aliases para ls e tree
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -ErrorAction SilentlyContinue
    function ls { eza --icons --sort=type @args }
    function tree { eza --icons --sort=type --tree @args }
}

# cls já é um alias nativo do PowerShell para Clear-Host, nada a fazer aqui
