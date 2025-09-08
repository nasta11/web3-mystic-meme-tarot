#!/bin/bash
set -euo pipefail

REPO="$(pwd)"
DESK="$HOME/Desktop"

# 1) найти источник для каждой масти: сначала папки, потом ZIP
find_src_dir_or_zip() {
  local cat="$1"
  # Ищем директорию по имени масти (в т.ч. "копия" и вариант внутри папки images)
  local d
  d="$(find "$DESK" -maxdepth 2 -type d \( -iname "$cat" -o -iname "*$cat*" -o -ipath "*/images/*$cat*" \) 2>/dev/null | head -n1 || true)"
  if [ -n "${d:-}" ]; then
    echo "DIR::$d"
    return 0
  fi
  # Ищем zip-архив
  local z
  z="$(find "$DESK" -maxdepth 2 -type f \( -iname "*$cat*.zip" -o -iname "images-$cat*.zip" \) 2>/dev/null | head -n1 || true)"
  if [ -n "${z:-}" ]; then
    echo "ZIP::$z"
    return 0
  fi
  echo "NONE::" ; return 1
}

# 2) распаковать ZIP во временную папку
unzip_to_tmp() {
  local zip="$1"
  local tmp="$2"
  mkdir -p "$tmp"
  unzip -oq "$zip" -d "$tmp"
}

# 3) нормализовать имя файла: lower + пробелы/_ -> -
normalize_name() {
  local base="$1"
  local name="${base%.*}"
  name="$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | sed -E 's/-+/-/g')"
  echo "${name}.jpg"
}

# 4) скопировать картинки из src в DEST (только jpg/jpeg), нормализуя имена
copy_category() {
  local cat="$1"
  local dest="$REPO/images/$cat"
  mkdir -p "$dest"

  local srcinfo
  srcinfo="$(find_src_dir_or_zip "$cat" || true)"
  local kind="${srcinfo%%::*}"
  local path="${srcinfo##*::}"

  echo ">>> [$cat] source: $kind $path"

  if [ "$kind" = "ZIP" ]; then
    tmp="$(mktemp -d)"
    unzip_to_tmp "$path" "$tmp"
    src_dir="$tmp"
  elif [ "$kind" = "DIR" ]; then
    src_dir="$path"
  else
    echo "⚠️  Не найден источник для '$cat' на Desktop — пропускаю"
    return 0
  fi

  shopt -s nullglob
  local copied=0
  for f in "$src_dir"/* "$src_dir"/*/*; do
    [ -f "$f" ] || continue
    case "${f,,}" in
      *.jpg|*.jpeg) ;;
      *) continue ;;
    esac
    local base="$(basename "$f")"
    local norm="$(normalize_name "$base")"
    cp -f "$f" "$dest/$norm"
    # отбросим подозрительно мелкие
    local size
    size=$(wc -c < "$dest/$norm")
    if [ "$size" -lt 1024 ]; then
      echo "  – пропуск пустышки: $norm ($size байт)"
      rm -f "$dest/$norm"
      continue
    fi
    echo "  + $base → images/$cat/$norm ($size байт)"
    copied=$((copied+1))
  done

  # чистим tmp, если был ZIP
  [ "${tmp:-}" ] && rm -rf "$tmp" || true

  echo "<<< [$cat] скопировано: $copied файл(ов)"
}

# --- выполнение ---
echo "Репозиторий: $REPO"
rm -rf images/witch 2>/dev/null || true
mkdir -p images/meme images/mystic images/coder

copy_category meme
copy_category mystic
copy_category coder

# Сгенерируем README
STAMP="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
{
  echo "> Updated: $STAMP"
  echo
  echo "# Web3 Mystic Meme Tarot"
  echo
  echo "Три масти по 7 карт: **Meme**, **Mystic**, **Coder**. Картинки из \`images/<масть>/\`."
  echo
  for cat in meme mystic coder; do
    case "$cat" in
      meme)   title="🐸 Meme (7)";;
      mystic) title="🔮 Mystic (7)";;
      coder)  title="👩‍💻 Coder (7)";;
    esac
    echo "## $title"
    echo ""
    echo "| Карта | Превью |"
    echo "|---|---|"
    for img in $(ls -1 "images/$cat/"*.jpg 2>/dev/null | sort); do
      cap="$(basename "$img" .jpg | tr '-' ' ' | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2)}; print}')"
      echo "| **$cap** | <img src=\"$img\" width=\"200\"> |"
    done
    echo ""
  done
} > README.md

echo "✅ Импорт завершён. Проверь ниже краткую сводку."
echo
for d in images/meme images/mystic images/coder; do
  echo "== $d =="; ls -1 "$d" 2>/dev/null | wc -l || true
done

