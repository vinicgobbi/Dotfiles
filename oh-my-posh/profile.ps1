# Snippet para incluir no $PROFILE do PowerShell.
# Equivalente a como o oh-my-zsh carrega tema + custom/*.zsh no .zshrc.
#
# Uso: adicione ao final do seu $PROFILE:
#   . "<caminho-para-este-repo>\oh-my-posh\profile.ps1"

$ohMyPoshRoot = $PSScriptRoot

# Tema (equivalente a ZSH_THEME="detail")
oh-my-posh init pwsh --config "$ohMyPoshRoot\themes\detail.omp.json" | Invoke-Expression

# Aliases (equivalente a oh-my-zsh/custom/aliases.zsh)
. "$ohMyPoshRoot\aliases.ps1"

# Editor padrão (equivalente a oh-my-zsh/custom/editor.zsh)
. "$ohMyPoshRoot\editor.ps1"
