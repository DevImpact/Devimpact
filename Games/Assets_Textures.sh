#!/bin/bash

DOCS_DIR="docs"
TEXTURES_DIR="Assets/Textures"
OUTPUT_MD="MISSING_TEXTURES_AUDIT.md"

TMP_REQ=$(mktemp)
TMP_EXISTING=$(mktemp)

echo "# Unity Textures Compliance Audit" > "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "## ❗ Missing Textures Report" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"

# 1️⃣ استخراج أسماء Textures المطلوبة من Markdown
# نفترض أي كلمة تحتوي على Texture|Tex|Background|UI تشير لاسم Texture
echo "[+] Extracting required textures from markdown..."
cat "$DOCS_DIR"/*.md \
 | grep -Eo "\b[A-Za-z]+(Texture|Tex|Background|UI)\b" \
 | sort -u > "$TMP_REQ"

# 2️⃣ جمع أسماء Textures الموجودة فعليًا
echo "[+] Collecting existing textures from Assets/Textures..."
find "$TEXTURES_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.tga" -o -iname "*.psd" \) \
 | sed 's#.*/##' \
 | sed -E 's/\.(png|jpg|jpeg|tga|psd)$//' \
 | sort -u > "$TMP_EXISTING"

echo "| Texture Name | Status | Evidence |" >> "$OUTPUT_MD"
echo "|--------------|--------|----------|" >> "$OUTPUT_MD"

TOTAL=0
MISSING=0

while IFS= read -r texture; do
  ((TOTAL++))

  if grep -qx "$texture" "$TMP_EXISTING"; then
    echo "| $texture | ✅ Present | Texture file exists in Assets/Textures |" >> "$OUTPUT_MD"
  else
    echo "| $texture | ❌ MISSING | Texture not found in Assets/Textures |" >> "$OUTPUT_MD"
    ((MISSING++))
  fi
done < "$TMP_REQ"

echo "" >> "$OUTPUT_MD"
echo "## 📊 Summary" >> "$OUTPUT_MD"
echo "" >> "$OUTPUT_MD"
echo "- Total required textures detected: **$TOTAL**" >> "$OUTPUT_MD"
echo "- Missing textures: **$MISSING**" >> "$OUTPUT_MD"
echo "- Compliance rate: **$(( (TOTAL - MISSING) * 100 / TOTAL ))%**" >> "$OUTPUT_MD"

rm "$TMP_REQ" "$TMP_EXISTING"

echo "[✓] Textures audit completed"
echo "Markdown report generated: $OUTPUT_MD"
