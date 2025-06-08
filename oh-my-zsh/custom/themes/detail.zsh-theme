# ZSH Theme - Preview: https://i.gyazo.com/8becc8a7ed5ab54a0262a470555c3eed.png
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

PROMPT='%{$fg[green]%}%n%{$fg[red]%} at %{$fg[blue]%}%M
%{$fg[yellow]%}%~$(ruby_prompt_info) $(git_prompt_info)%{$fg[blue]%}>%{$reset_color%} '
RPROMPT="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[red]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"


ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg[red]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="› %{$reset_color%}"
