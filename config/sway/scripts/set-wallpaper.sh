#!/usr/bin/env bash
# Resolve o wallpaper a partir do diretório de Fotos do XDG (xdg-user-dirs)
# em vez de um caminho fixo dentro da home, para funcionar em qualquer
# máquina/idioma (ex: ~/Pictures em en_US, ~/Imagens em pt_BR).
set -euo pipefail

if command -v xdg-user-dir >/dev/null 2>&1; then
    PICTURES_DIR="$(xdg-user-dir PICTURES)"
else
    PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
fi

WALLPAPER_DIR="$PICTURES_DIR/Wallpapers"
PREFERRED="$WALLPAPER_DIR/jinx-arcane-season-2-4k.jpg"

if [[ -f "$PREFERRED" ]]; then
    WALLPAPER="$PREFERRED"
else
    WALLPAPER="$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        2>/dev/null | sort | head -n1)"
fi

if [[ -n "${WALLPAPER:-}" ]]; then
    swaymsg output '*' bg "\"$WALLPAPER\"" fill
fi
