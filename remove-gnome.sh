#!/usr/bin/env bash
# Remove o GNOME e os resíduos dele que não são usados pela config deste
# repo (config/sway, config/swaylock, install-sway.sh) no Arch Linux, mas
# mantém nautilus, gvfs* e gnome-keyring, que continuam em uso fora do
# GNOME. Só
# age se detectar que a sessão atual já é o Sway, pra nunca remover o
# GNOME enquanto ele ainda está em uso. Pede confirmação antes de mexer em
# qualquer pacote.
set -euo pipefail

if [[ "$EUID" -eq 0 ]]; then
  echo "Não rode este script como root. Rode como seu usuário normal;" >&2
  echo "o sudo será pedido quando necessário." >&2
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "Este script é para Arch Linux (ou derivadas com pacman)." >&2
  exit 1
fi

echo "==> Checando se a sessão atual é o Sway"
if [[ -n "${SWAYSOCK:-}" ]] || pgrep -x sway >/dev/null 2>&1; then
  echo "  - Sway detectado, prosseguindo"
else
  echo "Não detectei o Sway rodando (nem \$SWAYSOCK nem processo 'sway')." >&2
  echo "Rode este script de dentro de uma sessão Sway." >&2
  exit 1
fi

# Pacotes dos grupos gnome/gnome-extra que a config deste repo usa mesmo
# fora do GNOME (ver install-sway.sh) e por isso nunca devem ser removidos
KEEP_PKGS=(
  gnome-keyring             # exec gnome-keyring-daemon na config do sway
  gsettings-desktop-schemas # schema org.gnome.desktop.interface (gsettings set ... na config)
  nautilus                  # gerenciador de arquivos usado fora do GNOME
  xdg-user-dirs-gtk
)

# Padrões de pacotes mantidos por prefixo (ex: todos os backends gvfs,
# necessários pro nautilus montar dispositivos/rede)
KEEP_PATTERNS=(
  'gvfs*'
)

echo "==> Procurando pacotes do GNOME instalados (grupos gnome/gnome-extra)"
mapfile -t GROUP_PKGS < <(pacman -Qg gnome gnome-extra 2>/dev/null | awk '{print $2}' | sort -u)

if [[ ${#GROUP_PKGS[@]} -eq 0 ]]; then
  echo "  - nenhum pacote dos grupos gnome/gnome-extra instalado, nada a fazer"
  exit 0
fi

REMOVE_PKGS=()
for pkg in "${GROUP_PKGS[@]}"; do
  keep=false
  for k in "${KEEP_PKGS[@]}"; do
    [[ "$pkg" == "$k" ]] && keep=true && break
  done
  if ! "$keep"; then
    for p in "${KEEP_PATTERNS[@]}"; do
      [[ "$pkg" == $p ]] && keep=true && break
    done
  fi
  "$keep" || REMOVE_PKGS+=("$pkg")
done

if [[ ${#REMOVE_PKGS[@]} -eq 0 ]]; then
  echo "  - só pacotes usados pela config do Sway estão instalados (${KEEP_PKGS[*]}, ${KEEP_PATTERNS[*]}), nada a remover"
  exit 0
fi

echo "  - candidatos à remoção (${#REMOVE_PKGS[@]}):"
printf '      %s\n' "${REMOVE_PKGS[@]}"
echo "  - mantidos por serem usados pela config do Sway: ${KEEP_PKGS[*]}, ${KEEP_PATTERNS[*]}"

GDM_ENABLED=false
if printf '%s\n' "${REMOVE_PKGS[@]}" | grep -qx gdm && systemctl is-enabled gdm.service >/dev/null 2>&1; then
  GDM_ENABLED=true
  echo
  echo "  AVISO: o gdm está habilitado como display manager e está na lista"
  echo "  de remoção. Depois disso não vai existir tela de login gráfica;"
  echo "  inicie o Sway a partir de um TTY (ex: 'exec sway' no ~/.zprofile)"
  echo "  ou instale outro display manager antes de reiniciar."
fi

echo
reply=""
read -r -p "Remover os ${#REMOVE_PKGS[@]} pacotes acima com 'pacman -Rns'? [y/N] " reply || reply=""
case "$reply" in
  [yY]|[yY][eE][sS]) ;;
  *)
    echo "Cancelado."
    exit 0
    ;;
esac

if [[ "$GDM_ENABLED" == true ]]; then
  echo "==> Desabilitando gdm.service antes de remover"
  sudo systemctl disable gdm.service
fi

echo "==> Removendo pacotes"
sudo pacman -Rns "${REMOVE_PKGS[@]}"

echo
echo "Pronto. Configs por usuário que sobraram (ex: ~/.config/dconf,"
echo "~/.cache/gnome-*) não foram tocadas — remova manualmente se quiser."
echo "Reinicie ou faça logout/login pra confirmar que o Sway continua"
echo "subindo normalmente."
