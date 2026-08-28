# oh-my-posh

Réplica do setup do [`oh-my-zsh/custom/`](../oh-my-zsh/custom/) para PowerShell + [oh-my-posh](https://ohmyposh.dev/), usada como prompt no Windows.

## Estrutura

- `themes/detail.omp.json` — porte do tema `detail.zsh-theme`
- `aliases.ps1` — porte de `custom/aliases.zsh`
- `editor.ps1` — porte de `custom/editor.zsh`
- `profile.ps1` — snippet para o `$PROFILE`, carrega tema + aliases + editor

## Instalação

1. Instale o oh-my-posh: `winget install JanDeDobbeleer.OhMyPosh`
2. Adicione ao final do seu `$PROFILE`:

   ```powershell
   . "C:\caminho\para\Dotfiles\oh-my-posh\profile.ps1"
   ```

## Mapeamento tema `detail` → `detail.omp.json`

| zsh (`detail.zsh-theme`) | oh-my-posh | Observação |
|---|---|---|
| `%n` (usuário, verde) | segmento `session` verde | idêntico |
| `get_context` (host colorido por contexto) | segmento `session` com `foreground_templates` | ver "Diferenças" abaixo |
| `%~` (path, amarelo) | segmento `path` (`style: full`, `home_icon: ~`) | idêntico |
| `ruby_prompt_info` (`‹›` vermelho) | segmento `ruby` | idêntico |
| `git_prompt_info` (`‹›` vermelho) | segmento `git` | idêntico |
| `>` azul | segmento `text` | idêntico |
| `RPROMPT` com `%?` e `↵` | bloco `rprompt` com segmento `exit` | idêntico, some sozinho quando o comando tem sucesso |

## Diferenças conscientes (Linux vs Windows)

A função `get_context` do tema original detecta 3 cenários que não têm equivalente direto no Windows/PowerShell. A adaptação usa o sinal mais próximo disponível:

- **Container** (`/.dockerenv`, cgroups) → no Windows isso vira "estou dentro do WSL": checa `$env:WSL_DISTRO_NAME` (ciano, igual ao original)
- **Domínio AD via `realm`** → no Windows o equivalente nativo é a variável `$env:USERDNSDOMAIN`, setada automaticamente quando a máquina está em um domínio Active Directory (magenta, igual ao original) — testado nesta máquina e funcionou
- **Hostname puro** → fallback padrão (azul, igual ao original)

`rehash.zsh` (completions do zsh) e `sshaskpass.zsh` (askpass do `ssh-agent` via `ksshaskpass`) não foram portados: são específicos de mecanismos do zsh/Linux sem equivalente direto e razoável no PowerShell.

Os aliases de `cat`→`bat` e `ls`/`tree`→`eza` foram portados como funções em `aliases.ps1`, com a mesma checagem condicional (só ativa se a ferramenta existir no `PATH`). `cls` não precisa de porte: já é alias nativo do PowerShell para `Clear-Host`. O alias `vencord` (instala o Vencord num Discord vanilla via `curl | sh`) também não foi portado: no Windows o Vencord já vem embutido no Vesktop instalado pelo `post_windows` — não existe um Discord "vanilla" pra remendar.

O easter egg de som em erro (`faah.zsh`/`faaah.mp3`) existiu nos dois lados, mas foi removido do oh-my-zsh — por consequência, também foi removido daqui para manter os dois em paridade.
