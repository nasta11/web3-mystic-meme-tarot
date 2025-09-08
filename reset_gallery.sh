#!/bin/bash
set -euo pipefail

REPO_ROOT="$(pwd)"
SRC="../cards"          # откуда берём исходники карт
DEST="images/witch"     # куда кладём в репозитории

[ -d "$SRC" ] || { echo "❌ Не найдена папка с картами: $SRC"; exit 1; }

rm -rf images
mkdir -p "$DEST"

copied=0
shopt -s nullglob
for f in "$SRC"/*.jpg "$SRC"/*.jpeg "$SRC"/*.JPG" "$SRC"/*.JPEG; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  name="${base%.*}"
  name="$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | sed -E 's/-+/-/g')"
  out="$DEST/$name.jpg"
  cp -f "$f" "$out"
  size=$(wc -c < "$out")
  if [ "$size" -lt 1024 ]; then
    echo "⚠️ Пропущен подозрительный файл: $out ($size байт)"
    rm -f "$out"
    continue
  fi
  echo "✔ $base → $out ($size байт)"
  copied=$((copied+1))
done

if [ "$copied" -eq 0 ]; then
  echo "❌ Не удалось скопировать изображения"
  exit 1
fi

STAMP="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
{
  echo "> Updated: $STAMP"
  echo
  echo "# Web3 Witch — Tarot Deck"
  echo
  echo "## 🌙 Галерея"
  echo
  echo "<p align=\"center\">"
  for img in $(ls -1 "$DEST"/*.jpg | sort); do
    base="$(basename "$img" .jpg)"
    caption="$(echo "$base" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2)}; print}')"
    echo "  <figure style=\"display:inline-block;margin:6px;text-align:center;\">"
    echo "    <img src=\"$img\" width=\"140\"><figcaption style=\"font-size:12px;\">$caption</figcaption>"
    echo "  </figure>"
  done
  echo "</p>"
} > README.md

echo "✅ Готово: скопировано $copied файлов в $DEST, создан README.md"

