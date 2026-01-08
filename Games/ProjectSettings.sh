#!/bin/bash

DOCS_DIR="docs"
SETTINGS_DIR="ProjectSettings"
OUTPUT_MD="MISSING_PROJECTSETTINGS_AUDIT.md"

TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

echo "# Unity ProjectSettings Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Project Settings Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

echo "[+] Extracting required project settings from markdown..."

# 1️⃣ استخراج الإعدادات المطلوبة من النصوص
cat "$DOCS_DIR"/*.md \
 | tr '[:upper:]' '[:lower:]' \
 | grep -Eo "quality|input|graphics|render|player|physics|time|audio|layer|tag|build|xr" \
 | sort -u > "$TMP_REQ"

echo "[+] Collecting existing ProjectSettings files..."

# 2️⃣ استخراج الإعدادات الموجودة فعليًا
ls "$SETTINGS_DIR" \
 | tr '[:upper:]' '[:lower:]' \
 | sed 's/settings\.asset//g' \
 | sed 's/\.asset//g' \
 > "$TMP_EXISTING"

echo "| Project Setting | Status | Evidence |" >> "$OUTPUT_MD"
echo "|----------------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

while IFS= read -r req; do
  ((TOTAL++))

  FOUND=0
  for existing in $(cat "$TMP_EXISTING"); do
    if echo "$existing" | grep -q "$req"; then
      FOUND=1
      break
    fi
  done

  if [ "$FOUND" -eq 1 ]; then
    echo "| $req | ✅ Present | Corresponding .asset file exists |" >> "$OUTPUT_MD"
  else
    echo "| $req | ❌ MISSING | No matching file in ProjectSettings/ |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi

done < "$TMP_REQ"

echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required settings detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing settings: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] ProjectSettings audit completed"
echo "Markdown report generated: $OUTPUT_MD"
