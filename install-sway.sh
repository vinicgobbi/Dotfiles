#!/usr/bin/env bash
# Instala o Sway e todas as dependências necessárias para a config deste repo
# (config/sway, config/swaylock, config/waybar, config/flameshot, config/fuzzel,
# config/wlogout, config/dunst, config/cava, config/gtk-3.0, config/gtk-4.0,
# config/gtkrc-2.0, config/qt5ct, config/qt6ct e config/environment.d)
# funcionar corretamente no Arch Linux: compositor, barra, launcher, lock/idle,
# notificações, autostart (autotiling, keyring, polkit), tema Dracula completo
# (GTK2/GTK3/GTK4 via dracula-gtk-theme + ícones/cursor Dracula, e Qt5/Qt6 via
# qt5ct/qt6ct), portais XDG, compat Qt/X11, permissões de brilho e os
# módulos/scripts do waybar (bluetooth, power-profiles-daemon, mediaplayer).
# Também copia as configs para ~/.config, resolvendo caminhos como o
# wallpaper, o savePath do flameshot (via xdg-user-dirs) e o color_scheme_path
# do qt5ct/qt6ct, em vez de caminho fixo na home.
# Idempotente: pode rodar quantas vezes quiser.
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
  # Fonte usada na config (Adwaita Sans)
  adwaita-fonts
  # Compatibilidade Wayland (apps X11/Qt) e portais (screenshot, file picker)
  xorg-xwayland qt5-wayland qt6-wayland
  xdg-desktop-portal xdg-desktop-portal-wlr
  # Configuradores de tema Qt5/Qt6 (tema Dracula aplicado via
  # config/qt5ct e config/qt6ct)
  qt5ct qt6ct
  # xdg-user-dir usado por scripts/set-wallpaper.sh para achar o dir de Fotos
  xdg-user-dirs
  # Diálogos e rede usados nas regras for_window da config
  yad networkmanager nm-connection-editor
  # Módulos do waybar: bluetooth, perfis de energia, volume e notificações
  bluez bluez-utils blueman pavucontrol power-profiles-daemon
  python-gobject libnotify
  # Daemon de notificações (exec'ado no startup do sway) e visualizador de áudio
  dunst cava
)

# Pacotes que só existem no AUR
AUR_PKGS=(
  wlogout               # menu de logout ($mod+Shift+e / XF86PowerOff)
  dracula-gtk-theme      # tema GTK2/GTK3/GTK4 "Dracula" (gsettings, gtkrc-2.0, settings.ini)
  dracula-icons-theme    # ícones "Dracula" usados no fuzzel e no gsettings
  dracula-cursors-git    # cursor "Dracula" usado no gsettings
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

sync_config() {
  local name="$1"
  mkdir -p "$HOME/.config/$name"
  if diff -rq "$SCRIPT_DIR/config/$name" "$HOME/.config/$name" >/dev/null 2>&1; then
    echo "  - config/$name já atualizada, pulando"
  else
    cp -r "$SCRIPT_DIR/config/$name/"* "$HOME/.config/$name/"
    echo "  - config/$name copiada"
  fi
}

echo "==> Copiando config deste repo para ~/.config"
for name in sway swaylock waybar fuzzel wlogout dunst cava alacritty gtk-3.0 gtk-4.0 environment.d qt5ct qt6ct; do
  sync_config "$name"
done
# Garante o bit de execução independente do umask no destino
chmod +x "$HOME/.config/sway/scripts/"*.sh
chmod +x "$HOME/.config/waybar/scripts/"*.py "$HOME/.config/waybar/scripts/"*.sh
chmod +x "$HOME/.config/wlogout/scripts/"*.sh

echo "==> Copiando config do flameshot (savePath resolvido via XDG Pictures)"
mkdir -p "$HOME/.config/flameshot"
if command -v xdg-user-dir >/dev/null 2>&1; then
  PICTURES_DIR="$(xdg-user-dir PICTURES)"
else
  PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
fi
mkdir -p "$PICTURES_DIR/Screenshots"
sed "s#__PICTURES_DIR__#${PICTURES_DIR}#" \
  "$SCRIPT_DIR/config/flameshot/flameshot.ini" > "$HOME/.config/flameshot/flameshot.ini"
echo "  - config/flameshot copiada (savePath=$PICTURES_DIR/Screenshots)"

echo "==> Tema GTK2 (~/.gtkrc-2.0, GTK2 não lê gsettings)"
cp "$SCRIPT_DIR/config/gtkrc-2.0" "$HOME/.gtkrc-2.0"
echo "  - ~/.gtkrc-2.0 copiado"

echo "==> Tema Qt5/Qt6 (qt5ct/qt6ct apontando para config/qt5ct e config/qt6ct)"
for qtct in qt5ct qt6ct; do
  sed "s#__HOME__#${HOME}#" \
    "$SCRIPT_DIR/config/$qtct/$qtct.conf" > "$HOME/.config/$qtct/$qtct.conf"
  echo "  - config/$qtct/$qtct.conf copiado (color_scheme_path resolvido)"
done

echo "==> Conferindo nomes reais dos temas de ícone/cursor Dracula instalados"
ICON_THEME_NAME="$(pacman -Ql dracula-icons-theme 2>/dev/null | grep -oP '/usr/share/icons/\K[^/]+(?=/index\.theme)' | head -n1)"
CURSOR_THEME_NAME="$(pacman -Ql dracula-cursors-git 2>/dev/null | grep -oP '/usr/share/icons/\K[^/]+(?=/(index|cursor)\.theme)' | head -n1)"
if [[ -n "$ICON_THEME_NAME" && "$ICON_THEME_NAME" != "Dracula" ]]; then
  echo "  - AVISO: pacote de ícones instalou o tema como '$ICON_THEME_NAME', não 'Dracula'."
  echo "    Ajuste manualmente config/sway/config (gsettings icon-theme e --icon-theme"
  echo "    do fuzzel) e config/gtkrc-2.0 / config/gtk-3.0 / config/gtk-4.0 (gtk-icon-theme-name)."
fi
if [[ -n "$CURSOR_THEME_NAME" && "$CURSOR_THEME_NAME" != "Dracula-cursors" ]]; then
  echo "  - AVISO: pacote de cursor instalou o tema como '$CURSOR_THEME_NAME', não 'Dracula-cursors'."
  echo "    Ajuste manualmente config/sway/config (gsettings cursor-theme) e"
  echo "    config/gtkrc-2.0 / config/gtk-3.0 / config/gtk-4.0 (gtk-cursor-theme-name)."
fi

echo "==> Serviços de sistema (bluetooth, power-profiles-daemon)"
for svc in bluetooth power-profiles-daemon; do
  if systemctl is-active --quiet "$svc"; then
    echo "  - $svc já ativo"
  else
    sudo systemctl enable --now "$svc"
    echo "  - $svc habilitado"
  fi
done

echo
echo "Tudo pronto. Faça logout/login (ou reinicie) para os grupos"
echo "video/input terem efeito, e selecione 'Sway' na tela de login"
echo "(ou rode 'sway' a partir de um TTY)."
