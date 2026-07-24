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

    $global:FaahLastHistoryId = (Get-History -ErrorAction Ignore -Count 1 | Select-Object -ExpandProperty Id)

    function global:prompt {
        # $? precisa ser a primeiríssima coisa lida na função: qualquer statement
        # antes disso já a sobrescreve. Cobre tanto comando inexistente quanto
        # executável nativo com código de saída != 0 — não precisa de $LASTEXITCODE:
        # ele é "grudento" (só muda quando outro executável nativo roda), então usá-lo
        # como sinal independente falsamente marcaria como erro qualquer comando
        # bem-sucedido rodado logo depois de uma falha nativa anterior.
        $success = $?

        # $? sozinho ainda é um falso positivo em potencial: o próprio oh-my-posh roda
        # comandos internos (git, ruby etc.) DURANTE a renderização do prompt, e se
        # o usuário só der Enter numa linha vazia, "prompt" é chamado de novo sem
        # nenhum comando novo ter rodado — nesse caso $? pode refletir ruído interno
        # da renderização anterior, não um comando real. Por isso só reavaliamos
        # sucesso/falha quando o Id do histórico realmente mudou desde a última vez
        # que "prompt" rodou, ou seja, quando um comando novo de fato foi executado.
        $lastHistoryId = Get-History -ErrorAction Ignore -Count 1 | Select-Object -ExpandProperty Id
        if ($lastHistoryId -ne $global:FaahLastHistoryId) {
            $global:FaahLastHistoryId = $lastHistoryId
            $global:FaahLastCommandFailed = -not $success
        } else {
            $global:FaahLastCommandFailed = $false
        }

        if ($global:FaahLastCommandFailed) {
            Start-Process ffplay -ArgumentList "-nodisp -autoexit -loglevel quiet `"$global:FaahMp3`"" -WindowStyle Hidden
        }
        & $script:OmpPrompt
    }
}
