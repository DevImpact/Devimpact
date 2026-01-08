#!/bin/bash

DOCS_DIR="docs"
MATERIALS_DIR="Assets/Materials"
OUTPUT_MD="MISSING_MATERIALS_AUDIT.md"

TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

echo "# Unity Materials Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Materials Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 1️⃣ استخراج أسماء Materials المطلوبة من Markdown
# نفترض أي كلمة تحتوي على Mat|Material|Texture|Background|UI تشير لاسم Material
echo "[+] Extracting required materials from markdown..."
cat "$DOCS_DIR"/*.md \
 | grep -Eo "\b[A-Za-z]+(Mat|Material|Texture|Background|UI)\b" \
 | sort -u > "$TMP_REQ"

# 2️⃣ جمع أسماء Materials الموجودة فعليًا
echo "[+] Collecting existing materials from Assets/Materials..."
find "$MATERIALS_DIR" -name "*.mat" \
 | sed 's#.*/##' \
 | sed 's/.mat//' \
 | sort -u > "$TMP_EXISTING"

echo "| Material Name | Status | Evidence |" >> "$OUTPUT_MD"
echo "|---------------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

while IFS= read -r material; do
  ((TOTAL++))

  if grep -qx "$material" "$TMP_EXISTING"; then
    echo "| $material | ✅ Present | Material file exists in Assets/Materials |" >> "$OUTPUT_MD"
  else
    echo "| $material | ❌ MISSING | Material not found in Assets/Materials |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi
done < "$TMP_REQ"

echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required materials detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing materials: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] Materials audit completed"
echo "Markdown report generated: $OUTPUT_MD"
