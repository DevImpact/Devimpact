#!/bin/bash

DOCS_DIR="docs"
SCRIPTS_DIR="Assets/Scripts"
OUTPUT_MD="MISSING_SCRIPTS_AUDIT.md"

TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

echo "# Unity Scripts Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Scripts Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 1️⃣ استخراج أسماء Scripts المطلوبة من Markdown
# نفترض أن أي كلمة تحتوي على "Manager|Controller|Handler|UI|Input" تشير لاسم Script
echo "[+] Extracting required scripts from markdown..."
cat "$DOCS_DIR"/*.md \
 | grep -Eo "\b[A-Za-z]+(Manager|Controller|Handler|UI|Input)\b" \
 | sort -u > "$TMP_REQ"

# 2️⃣ جمع أسماء Scripts الموجودة فعليًا
echo "[+] Collecting existing scripts from Assets/Scripts..."
find "$SCRIPTS_DIR" -name "*.cs" \
 | sed 's#.*/##' \
 | sed 's/.cs//' \
 | sort -u > "$TMP_EXISTING"

echo "| Script Name | Status | Evidence |" >> "$OUTPUT_MD"
echo "|------------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

while IFS= read -r script; do
  ((TOTAL++))

  if grep -qx "$script" "$TMP_EXISTING"; then
    echo "| $script | ✅ Present | Script file exists in Assets/Scripts |" >> "$OUTPUT_MD"
  else
    echo "| $script | ❌ MISSING | Script not found in Assets/Scripts |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi
done < "$TMP_REQ"

echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required scripts detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing scripts: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] Scripts audit completed"
echo "Markdown report generated: $OUTPUT_MD"
