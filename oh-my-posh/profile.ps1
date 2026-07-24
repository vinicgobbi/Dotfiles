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

# Easter egg: toca um som quando o último comando falha (equivalente a custom/faah.zsh).
# Envolve a função "prompt" que o oh-my-posh acabou de definir, tocando o som ANTES
# de delegar para o prompt original do oh-my-posh (mesma ideia do precmd_functions do zsh).
if (Get-Command ffplay -ErrorAction SilentlyContinue) {
    $global:FaahMp3 = Join-Path $ohMyPoshRoot "faaah.mp3"
    $script:OmpPrompt = $function:prompt

    function global:prompt {
        if ($LASTEXITCODE -ne 0) {
            Start-Process ffplay -ArgumentList "-nodisp -autoexit -loglevel quiet `"$global:FaahMp3`"" -WindowStyle Hidden
        }
        & $script:OmpPrompt
    }
}
