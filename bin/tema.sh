#!/usr/bin/env bash
set -euo pipefail

TEMAS="$HOME/.local/share/temas"
ESTILOS="$HOME/.local/share/plasma/desktoptheme"
NOMBRE="${1:-}"

if [ -z "$NOMBRE" ]; then
  echo "Uso: tema.sh NOMBRE"
  echo "Temas disponibles:"
  ls "$TEMAS"
  exit 1
fi

DIR="$TEMAS/$NOMBRE"
if [ ! -f "$DIR/tema.conf" ]; then
  echo "No existe el tema: $NOMBRE"
  exit 1
fi

# shellcheck disable=SC1091
source "$DIR/tema.conf"

echo "Aplicando tema: $NOMBRE"

mkdir -p "$HOME/.local/share/color-schemes"
cp "$DIR/$COLOR_FILE" "$HOME/.local/share/color-schemes/"

# Estilo de Plasma: crearlo desde la base si no existe
if [ -n "${STYLE_BASE:-}" ] && [ ! -d "$ESTILOS/$DESKTOP_THEME" ]; then
  mkdir -p "$ESTILOS"
  cp -r "/usr/share/plasma/desktoptheme/$STYLE_BASE" "$ESTILOS/$DESKTOP_THEME"
fi

# Color de la barra: se escribe en el estilo para que no vuelva a negro
if [ -n "${PANEL_BG:-}" ] && [ -d "$ESTILOS/$DESKTOP_THEME" ]; then
  kwriteconfig6 --file "$ESTILOS/$DESKTOP_THEME/colors" \
    --group Colors:Window --key BackgroundNormal "$PANEL_BG"
fi

plasma-apply-colorscheme "$COLOR_SCHEME"
plasma-apply-desktoptheme "$DESKTOP_THEME"
plasma-apply-wallpaperimage "$DIR/$WALLPAPER"
plasma-apply-cursortheme --size "$CURSOR_SIZE" "$CURSOR"

if [ -n "${FOLDER_COLOR:-}" ]; then
  echo "Cambiando color de carpetas (pedirá tu contraseña)..."
  sudo papirus-folders -C "$FOLDER_COLOR" --theme Papirus-Dark
fi

kquitapp6 plasmashell 2>/dev/null || true
kstart plasmashell >/dev/null 2>&1 &

echo "Listo: $NOMBRE"
