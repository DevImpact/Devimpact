#!/bin/bash

DOCS_DIR="docs"
SCENES_DIR="Assets/Scenes"
OUTPUT_MD="MISSING_SCENES_AUDIT.md"

TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

echo "# Unity Scenes Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Scenes Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 1️⃣ استخراج أسماء المشاهد المطلوبة من Markdown
# نفترض أي كلمة تحتوي على Main|Level|Menu|GameOver|Credits تشير لاسم Scene
echo "[+] Extracting required scenes from markdown..."
cat "$DOCS_DIR"/*.md \
 | grep -Eo "\b[A-Za-z]+(Main|Level|Menu|GameOver|Credits)\b" \
 | sort -u > "$TMP_REQ"

# 2️⃣ جمع أسماء المشاهد الموجودة فعليًا
echo "[+] Collecting existing scenes from Assets/Scenes..."
find "$SCENES_DIR" -name "*.unity" \
 | sed 's#.*/##' \
 | sed 's/.unity//' \
 | sort -u > "$TMP_EXISTING"

echo "| Scene Name | Status | Evidence |" >> "$OUTPUT_MD"
echo "|------------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

while IFS= read -r scene; do
  ((TOTAL++))

  if grep -qx "$scene" "$TMP_EXISTING"; then
    echo "| $scene | ✅ Present | Scene file exists in Assets/Scenes |" >> "$OUTPUT_MD"
  else
    echo "| $scene | ❌ MISSING | Scene not found in Assets/Scenes |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi
done < "$TMP_REQ"

echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required scenes detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing scenes: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] Scenes audit completed"
echo "Markdown report generated: $OUTPUT_MD"
