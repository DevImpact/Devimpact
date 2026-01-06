#!/bin/sh

set -eu

DOCS_DIR="docs"
TMP_LAW="/tmp/docs_law.txt"
TMP_ACTUAL="/tmp/actual_paths.txt"

echo "⚖️ Enforcing docs as absolute law (zero interpretation)"

# 1. docs إلزامي
if [ ! -d "$DOCS_DIR" ]; then
  echo "❌ docs directory is mandatory"
  exit 1
fi

# 2. كل سطر = قانون
echo "📖 Reading ALL lines from docs (no parsing, no assumptions)..."

> "$TMP_LAW"

find "$DOCS_DIR" -type f | while read -r file; do
  # نأخذ كل سطر غير فارغ حرفيًا
  sed '/^[[:space:]]*$/d' "$file" >> "$TMP_LAW"
done

if [ ! -s "$TMP_LAW" ]; then
  echo "❌ docs contain no enforceable laws"
  exit 1
fi

sort -u "$TMP_LAW" -o "$TMP_LAW"

# 3. استخراج كل المسارات الفعلية (مجلدات فقط)
echo "📂 Scanning repository paths..."

find . \
  -type d \
  ! -path "./.git*" \
  ! -path "./docs*" \
  | sed 's|^\./||' \
  | sed '/^$/d' \
  | sort > "$TMP_ACTUAL"

# 4. تحقق: كل قانون موجود
echo "🔍 Verifying every documented line exists..."

while read -r law; do
  if ! grep -Fxq "$law" "$TMP_ACTUAL"; then
    echo "❌ Law violated: path does not exist → '$law'"
    exit 1
  fi
done < "$TMP_LAW"

# 5. تحقق عكسي: لا شيء خارج القانون
echo "🚫 Checking for illegal structures..."

while read -r actual; do
  case "$actual" in
    .) continue ;;
  esac

  if ! grep -Fxq "$actual" "$TMP_LAW"; then
    echo "❌ Illegal structure detected (not documented): '$actual'"
    exit 1
  fi
done < "$TMP_ACTUAL"

echo "✅ Repository is 100% compliant with docs laws"

# 6. تنظيف
rm -f "$TMP_LAW" "$TMP_ACTUAL"
