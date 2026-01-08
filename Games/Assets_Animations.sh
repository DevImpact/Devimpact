#!/bin/bash

DOCS_DIR="docs"
ANIMATIONS_DIR="Assets/Animations"
OUTPUT_MD="MISSING_ANIMATIONS_AUDIT.md"

TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

echo "# Unity Animations Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Animations Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 1️⃣ استخراج أسماء Animations المطلوبة من Markdown
# نفترض أي كلمة تحتوي على Walk|Run|Jump|Attack|Idle|Click|UI تشير لاسم Animation
echo "[+] Extracting required animations from markdown..."
cat "$DOCS_DIR"/*.md \
 | grep -Eo "\b[A-Za-z]+(Walk|Run|Jump|Attack|Idle|Click|UI)\b" \
 | sort -u > "$TMP_REQ"

# 2️⃣ جمع أسماء Animations الموجودة فعليًا
echo "[+] Collecting existing animations from Assets/Animations..."
find "$ANIMATIONS_DIR" -name "*.anim" \
 | sed 's#.*/##' \
 | sed 's/.anim//' \
 | sort -u > "$TMP_EXISTING"

echo "| Animation Name | Status | Evidence |" >> "$OUTPUT_MD"
echo "|----------------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

while IFS= read -r anim; do
  ((TOTAL++))

  if grep -qx "$anim" "$TMP_EXISTING"; then
    echo "| $anim | ✅ Present | Animation file exists in Assets/Animations |" >> "$OUTPUT_MD"
  else
    echo "| $anim | ❌ MISSING | Animation not found in Assets/Animations |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi
done < "$TMP_REQ"

echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required animations detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing animations: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] Animations audit completed"
echo "Markdown report generated: $OUTPUT_MD"

