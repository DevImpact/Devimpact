#!/bin/bash

DOCS_DIR="docs"
PREFABS_DIR="Assets/Prefabs"
OUTPUT_MD="MISSING_PREFABS_AUDIT.md"

TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

echo "# Unity Prefabs Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Prefabs Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 1️⃣ استخراج أسماء Prefabs المطلوبة من Markdown
# نفترض أي كلمة تحتوي على Player|Enemy|Power|UI تشير لاسم Prefab
echo "[+] Extracting required prefabs from markdown..."
cat "$DOCS_DIR"/*.md \
 | grep -Eo "\b[A-Za-z]+(Player|Enemy|Power|UI)\b" \
 | sort -u > "$TMP_REQ"

# 2️⃣ جمع أسماء Prefabs الموجودة فعليًا
echo "[+] Collecting existing prefabs from Assets/Prefabs..."
find "$PREFABS_DIR" -name "*.prefab" \
 | sed 's#.*/##' \
 | sed 's/.prefab//' \
 | sort -u > "$TMP_EXISTING"

echo "| Prefab Name | Status | Evidence |" >> "$OUTPUT_MD"
echo "|-------------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

while IFS= read -r prefab; do
  ((TOTAL++))

  if grep -qx "$prefab" "$TMP_EXISTING"; then
    echo "| $prefab | ✅ Present | Prefab file exists in Assets/Prefabs |" >> "$OUTPUT_MD"
  else
    echo "| $prefab | ❌ MISSING | Prefab not found in Assets/Prefabs |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi
done < "$TMP_REQ"

echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required prefabs detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing prefabs: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] Prefabs audit completed"
echo "Markdown report generated: $OUTPUT_MD"
