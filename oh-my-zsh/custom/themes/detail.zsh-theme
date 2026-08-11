# Carrega módulo de cores
autoload -U colors && colors

# Configuração do código de retorno (Seta direita para status)
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# Função para identificar Contexto (Container vs AD/Realmd vs Local)
function get_context() {
  # 1. Verifica se está em Container (Docker/.dockerenv ou cgroups)
  if [[ -f /.dockerenv ]] || grep -qE '(docker|lxc|kubepods)' /proc/1/cgroup 2>/dev/null; then
    echo "%{$fg[cyan]%}%m%{$reset_color%}"
    return
  fi

  # 2. Verifica AD via realmd (lista domínio ativo se existir)
  if command -v realm > /dev/null; then
    local ad_domain=$(realm list --name-only 2>/dev/null | head -n1)
    if [[ -n "$ad_domain" ]]; then
      echo "%{$fg[magenta]%}$ad_domain%{$reset_color%} on %{$fg[blue]%}%M%{$reset_color%}"
      return
    fi
  fi

  # 3. Padrão: Apenas o Hostname em Azul
  echo "%{$fg[blue]%}%M%{$reset_color%}"
}

# Prompt Principal: Chama get_context para definir o host/ambiente
PROMPT='%{$fg[green]%}%n%{$fg[red]%} at $(get_context)
%{$fg[yellow]%}%~$(ruby_prompt_info) $(git_prompt_info)%{$fg[blue]%}>%{$reset_color%} '

# Prompt Direito: Exibe código de erro se houver
RPROMPT="${return_code}"

# Prefixos e Sufixos do Git
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[red]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"

# Prefixos e Sufixos do Ruby
ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg[red]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="› %{$reset_color%}"
