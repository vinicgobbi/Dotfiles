#!/usr/bin/env bash
# Instala as dependências do tema Zsh deste repo (plugins + zoxide) e
# habilita tudo no ~/.zshrc. Idempotente: pode rodar quantas vezes quiser.
set -euo pipefail

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSHRC="$HOME/.zshrc"
DESIRED_PLUGINS="plugins=(git zsh-autosuggestions zoxide zsh-syntax-highlighting)"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Oh My Zsh não encontrado em ~/.oh-my-zsh. Instale primeiro: https://ohmyz.sh" >&2
  exit 1
fi

clone_plugin() {
  local name="$1"
  local url="$2"
  local dest="$ZSH_CUSTOM/plugins/$name"
  if [[ -d "$dest" ]]; then
    echo "  - $name já instalado, pulando"
  else
    echo "  - clonando $name"
    git clone --depth 1 "$url" "$dest"
  fi
}

echo "==> Plugins do Zsh"
clone_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
clone_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"

echo "==> zoxide"
if command -v zoxide >/dev/null 2>&1; then
  echo "  - zoxide já instalado, pulando"
else
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

echo "==> Configurando ~/.zshrc"
if [[ ! -f "$ZSHRC" ]]; then
  echo "  - ~/.zshrc não encontrado, pulando (ajuste manualmente depois)"
else
  cp "$ZSHRC" "$ZSHRC.bak"

  if grep -qF "$DESIRED_PLUGINS" "$ZSHRC"; then
    echo "  - plugins já configurados"
  elif grep -q '^plugins=(' "$ZSHRC"; then
    sed -i "s/^plugins=(.*)/$DESIRED_PLUGINS/" "$ZSHRC"
    echo "  - linha plugins=() atualizada"
  else
    echo "  - linha plugins=() não encontrada, adicione manualmente:"
    echo "    $DESIRED_PLUGINS"
  fi

  if grep -qF "$PATH_LINE" "$ZSHRC"; then
    echo "  - PATH do ~/.local/bin já configurado"
  elif grep -q '^export ZSH=' "$ZSHRC"; then
    # precisa vir ANTES do "source \$ZSH/oh-my-zsh.sh", senão o plugin zoxide
    # não encontra o binário na hora de carregar
    sed -i "/^export ZSH=/a\\
\\
$PATH_LINE" "$ZSHRC"
    echo "  - PATH do ~/.local/bin adicionado"
  else
    echo "  - não achei 'export ZSH=' no ~/.zshrc, adicione manualmente antes do 'source \$ZSH/oh-my-zsh.sh':"
    echo "    $PATH_LINE"
  fi

  if diff -q "$ZSHRC" "$ZSHRC.bak" >/dev/null 2>&1; then
    rm -f "$ZSHRC.bak"
  else
    echo "  - backup do ~/.zshrc original salvo em $ZSHRC.bak"
  fi
fi

echo
echo "Tudo pronto. Reinicie o shell com: exec zsh"
