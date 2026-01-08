#!/bin/bash

DOCS_DIR="docs"
RESOURCES_DIR="Assets/Resources"
OUTPUT_MD="MISSING_RESOURCES_AUDIT.md"

TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

echo "# Unity Resources Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Resources Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 1️⃣ استخراج أسماء Resources المطلوبة من Markdown
# نفترض أي كلمة تبدأ بحروف كبيرة وتشير لاسم Resource (Prefab, Material, Texture, Audio, Asset)
echo "[+] Extracting required resources from markdown..."
cat "$DOCS_DIR"/*.md \
 | grep -Eo "\b[A-Za-z0-9_]+(Prefab|Mat|Material|Texture|Audio|Asset|ScriptableObject|UI|Player|Enemy|Level)\b" \
 | sort -u > "$TMP_REQ"

# 2️⃣ جمع أسماء Resources الموجودة فعليًا
echo "[+] Collecting existing resources from Assets/Resources..."
find "$RESOURCES_DIR" -type f \
 | sed 's#.*/##' \
 | sed -E 's/\.[^.]+$//' \
 | sort -u > "$TMP_EXISTING"

echo "| Resource Name | Status | Evidence |" >> "$OUTPUT_MD"
echo "|---------------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

while IFS= read -r res; do
  ((TOTAL++))

  if grep -qx "$res" "$TMP_EXISTING"; then
    echo "| $res | ✅ Present | Resource file exists in Assets/Resources |" >> "$OUTPUT_MD"
  else
    echo "| $res | ❌ MISSING | Resource not found in Assets/Resources |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi
done < "$TMP_REQ"

echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required resources detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing resources: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] Resources audit completed"
echo "Markdown report generated: $OUTPUT_MD"
