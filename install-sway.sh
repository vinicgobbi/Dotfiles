#!/usr/bin/env bash
# Instala o Sway e todas as dependências necessárias para a config deste repo
# (config/sway e config/swaylock) funcionar corretamente no Arch Linux:
# compositor, barra, launcher, lock/idle, autostart (autotiling, keyring,
# polkit), temas Adwaita/Yaru, portais XDG, compat Qt/X11 e permissões de
# brilho. Também copia as configs para ~/.config. Idempotente: pode rodar
# quantas vezes quiser.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$EUID" -eq 0 ]]; then
  echo "Não rode este script como root. Rode como seu usuário normal;" >&2
  echo "o sudo será pedido quando necessário." >&2
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "Este script é para Arch Linux (ou derivadas com pacman)." >&2
  exit 1
fi

# Pacotes oficiais (repo extra), todos referenciados direta ou indiretamente
# em config/sway/config e config/swaylock/config
PACMAN_PKGS=(
  # Compositor e utilitários usados em bindsym/exec da config
  sway swaybg swaylock swayidle
  waybar fuzzel alacritty flameshot
  playerctl brightnessctl
  # Áudio (pactl usado nas teclas de volume)
  pipewire pipewire-pulse pipewire-alsa wireplumber
  # Autenticação, keyring e autotiling exec'ados no startup do sway
  gnome-keyring polkit-gnome autotiling-rs
  # Temas Adwaita usados na config (gtk-theme e fonte)
  adw-gtk-theme adwaita-fonts
  # Compatibilidade Wayland (apps X11/Qt) e portais (screenshot, file picker)
  xorg-xwayland qt5-wayland qt6-wayland
  xdg-desktop-portal xdg-desktop-portal-wlr
  # Diálogos e rede usados nas regras for_window da config
  yad networkmanager nm-connection-editor
)

# Pacotes que só existem no AUR
AUR_PKGS=(
  wlogout        # menu de logout ($mod+Shift+e / XF86PowerOff)
  yaru-icon-theme # ícones/cursor Yaru-blue-dark usados no fuzzel e no gsettings
)

missing() {
  local pkg
  for pkg in "$@"; do
    pacman -Qi "$pkg" >/dev/null 2>&1 || echo "$pkg"
  done
}

echo "==> Pacotes oficiais (pacman)"
MISSING_PACMAN=($(missing "${PACMAN_PKGS[@]}"))
if [[ ${#MISSING_PACMAN[@]} -eq 0 ]]; then
  echo "  - todos já instalados, pulando"
else
  echo "  - instalando: ${MISSING_PACMAN[*]}"
  sudo pacman -S --needed "${MISSING_PACMAN[@]}"
fi

echo "==> Helper de AUR (yay)"
if command -v yay >/dev/null 2>&1; then
  echo "  - yay já instalado, pulando"
else
  echo "  - yay não encontrado, instalando"
  sudo pacman -S --needed base-devel git
  BUILD_DIR="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/yay.git "$BUILD_DIR/yay"
  (cd "$BUILD_DIR/yay" && makepkg -si)
  rm -rf "$BUILD_DIR"
fi

echo "==> Pacotes do AUR"
MISSING_AUR=($(missing "${AUR_PKGS[@]}"))
if [[ ${#MISSING_AUR[@]} -eq 0 ]]; then
  echo "  - todos já instalados, pulando"
else
  echo "  - instalando com yay: ${MISSING_AUR[*]}"
  yay -S --needed "${MISSING_AUR[@]}"
fi

echo "==> Grupos para controle de brilho (brightnessctl)"
for grp in video input; do
  if id -nG "$USER" | tr ' ' '\n' | grep -qx "$grp"; then
    echo "  - usuário já está no grupo $grp"
  else
    sudo usermod -aG "$grp" "$USER"
    echo "  - usuário adicionado ao grupo $grp (relogin necessário)"
  fi
done

echo "==> Serviços de áudio (PipeWire, usuário)"
AUDIO_UNITS=(pipewire pipewire-pulse wireplumber)
PENDING_UNITS=()
for unit in "${AUDIO_UNITS[@]}"; do
  systemctl --user is-active --quiet "$unit" 2>/dev/null || PENDING_UNITS+=("$unit")
done
if [[ ${#PENDING_UNITS[@]} -eq 0 ]]; then
  echo "  - pipewire/pipewire-pulse/wireplumber já ativos, pulando"
elif systemctl --user enable --now "${PENDING_UNITS[@]}" 2>/dev/null; then
  echo "  - habilitados: ${PENDING_UNITS[*]}"
else
  echo "  - não deu pra habilitar ${PENDING_UNITS[*]} via systemctl --user agora"
  echo "    (normal fora de uma sessão gráfica); eles sobem sozinhos ao entrar no Sway"
fi

echo "==> Copiando config deste repo para ~/.config"
mkdir -p "$HOME/.config/sway" "$HOME/.config/swaylock"
if diff -rq "$SCRIPT_DIR/config/sway" "$HOME/.config/sway" >/dev/null 2>&1; then
  echo "  - config/sway já atualizada, pulando"
else
  cp -r "$SCRIPT_DIR/config/sway/"* "$HOME/.config/sway/"
  echo "  - config/sway copiada"
fi
if diff -rq "$SCRIPT_DIR/config/swaylock" "$HOME/.config/swaylock" >/dev/null 2>&1; then
  echo "  - config/swaylock já atualizada, pulando"
else
  cp -r "$SCRIPT_DIR/config/swaylock/"* "$HOME/.config/swaylock/"
  echo "  - config/swaylock copiada"
fi

echo
echo "Tudo pronto. Faça logout/login (ou reinicie) para os grupos"
echo "video/input terem efeito, e selecione 'Sway' na tela de login"
echo "(ou rode 'sway' a partir de um TTY)."
