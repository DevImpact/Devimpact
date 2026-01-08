#!/bin/bash

DOCS_DIR="docs"
MANIFEST="Packages/manifest.json"
OUTPUT_MD="MISSING_PACKAGES_AUDIT.md"

TMP_REQ=$(mktemp)
TMP_INSTALLED=$(mktemp)

echo "# Unity Packages Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Packages Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 1️⃣ استخراج Packages المطلوبة من ملفات md
echo "[+] Extracting required packages from markdown..."

cat "$DOCS_DIR"/*.md \
 | tr '[:upper:]' '[:lower:]' \
 | grep -Eo "textmeshpro|input system|urp|hdrp|universal render pipeline|high definition render pipeline|cinemachine|addressables|post processing|netcode|xr|shader graph" \
 | sort -u > "$TMP_REQ"

# 2️⃣ استخراج Packages المثبتة فعليًا
echo "[+] Reading installed packages from manifest.json..."

grep -Eo '"com\.unity\.[^"]+"' "$MANIFEST" \
 | sed 's/"//g' \
 | sed 's/com\.unity\.//' \
 | tr '[:upper:]' '[:lower:]' \
 | sort -u > "$TMP_INSTALLED"

echo "| Package | Status | Evidence |" >> "$OUTPUT_MD"
echo "|--------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

while IFS= read -r pkg; do
  ((TOTAL++))

  # تطبيع الاسم
  normalized=$(echo "$pkg" \
    | sed 's/ /-/g' \
    | sed 's/universal render pipeline/urp/' \
    | sed 's/high definition render pipeline/hdrp/')

  if grep -q "$normalized" "$TMP_INSTALLED"; then
    echo "| $pkg | ✅ Present | Found in manifest.json |" >> "$OUTPUT_MD"
  else
    echo "| $pkg | ❌ MISSING | Not declared in manifest.json |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi

done < "$TMP_REQ"

echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required packages detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing packages: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

rm "$TMP_REQ" "$TMP_INSTALLED"

echo "[✓] Package audit completed"
echo "Markdown report generated: $OUTPUT_MD"
